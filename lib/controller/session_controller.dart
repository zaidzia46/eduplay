import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/supabase_client.dart';
import '../fns/image_picker_service.dart';
import '../routes/app_routes.dart';
import '../screens/profile/create_child_profile/models/standard_model.dart';
import '../screens/profile/profile_switcher/models/child_profile_model.dart';

class SessionController extends GetxController {
  var currentStandard = Rxn<StandardModel>();
  var activeChild = Rxn<ChildProfileModel>();

  var parentName = Rxn<String>();
  var childAvatar = Rxn<String>();

  static const _standardKey = 'currentStandard';
  static const _activeChildKey = 'activeChild';
  static const _parentNameKey = 'parentName';
  static const _childAvatarKey = 'childAvatar';

  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    final savedStandard = _box.read(_standardKey);
    if (savedStandard != null) {
      currentStandard.value = StandardModel.fromJson(
        Map<String, dynamic>.from(savedStandard),
      );
    }

    final savedChild = _box.read(_activeChildKey);
    if (savedChild != null) {
      activeChild.value = ChildProfileModel.fromCacheJson(
        Map<String, dynamic>.from(savedChild),
      );
    }

    final savedParentName = _box.read(_parentNameKey);
    if (savedParentName != null) {
      parentName.value = savedParentName;
    }
  }

  Future<void> setParentName(String name) async {
    parentName.value = name;
    await _box.write(_parentNameKey, name);
  }

  // Future<void> setChildAvatar() async {
  //   final imagePath = await ImagePickerService.pickImage(ImageSource.gallery);
  //   if (imagePath != null) {
  //     childAvatar.value = imagePath;
  //     await _box.write(_childAvatarKey, imagePath);
  //   }
  // }

  Future<void> setActiveChild(ChildProfileModel child) async {
    activeChild.value = child;
    if (child.standard != null) {
      await setCurrentStandard(child.standard!);
    }
    await _box.write(_activeChildKey, child.toCacheJson());
  }

  Future<void> updateActiveChildStars(int totalStars) async {
    final current = activeChild.value;
    if (current == null) return;
    final updated = current.copyWithStars(totalStars: totalStars);
    activeChild.value = updated;
    await _box.write(_activeChildKey, updated.toCacheJson());
  }

  Future<void> addActiveChildStars(int earnedStars) async {
    final current = activeChild.value;
    if (current == null) return;
    final updated = current.copyWithStars(
      totalStars: current.totalStars + earnedStars,
    );
    activeChild.value = updated;
    await _box.write(_activeChildKey, updated.toCacheJson());
  }

  /// Re-read the server-maintained gamification counters for the active child
  /// (a trigger on quiz_attempts keeps stars, streak and overall_progress
  /// current) and mirror them onto the cached active child. Watched by
  /// ProgressController, so calling this after a quiz also refreshes the
  /// Progress tab.
  Future<void> refreshActiveChildCounters() async {
    final current = activeChild.value;
    if (current == null) return;

    final row = await supabase
        .from('children')
        .select('total_stars, current_streak, longest_streak, overall_progress')
        .eq('id', current.id)
        .single();

    final updated = current.copyWithCounters(
      totalStars: row['total_stars'] as int? ?? current.totalStars,
      currentStreak: row['current_streak'] as int? ?? current.currentStreak,
      longestStreak: row['longest_streak'] as int? ?? current.longestStreak,
      overallPercent: row['overall_progress'] as int? ?? current.overallPercent,
    );
    activeChild.value = updated;
    await _box.write(_activeChildKey, updated.toCacheJson());
  }

  Future<void> clearActiveChild() async {
    activeChild.value = null;
    currentStandard.value = null;
    await _box.remove(_activeChildKey);
    await _box.remove(_standardKey);
  }

  Future<void> setCurrentStandard(StandardModel standard) async {
    currentStandard.value = standard;
    await _box.write(_standardKey, {
      'id': standard.id,
      'name': standard.name,
      'sort_order': standard.sortOrder,
    });
  }

  int? get currentStandardId => currentStandard.value?.id;

  /// True while the signed-in user is an anonymous (guest) account. Read
  /// straight off supabase.auth — the same convention the auth layer uses for
  /// currentSession — so there's no separate flag to keep in sync. Every guest
  /// UI gate (add-child, avatar upload, change password, logout copy) reads
  /// this, and the Phase A RLS cap enforces it server-side.
  bool get isGuest => supabase.auth.currentUser?.isAnonymous ?? false;

  /// Nudge a guest to turn their anonymous session into a real account.
  /// Centralised so every guarded surface (child/parent avatar uploads, the
  /// add-child card, …) shows the same prompt and routes to the same convert
  /// flow (register in convert mode → updateUser on the same UUID, so progress
  /// carries over losslessly).
  void promptSignUp([String message = 'Sign up to save your progress.']) {
    Get.snackbar(
      'Create an account',
      message,
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: () {
          if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
          Get.toNamed(AppRoutes.register, arguments: {'convert': true});
        },
        child: const Text('Sign up'),
      ),
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    await clearActiveChild();
    parentName.value = null;
    await _box.remove(_parentNameKey);
  }
}

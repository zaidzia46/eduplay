// session_controller.dart
import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_client.dart';
import '../fns/image_picker_service.dart';
import '../models/child_profile_model.dart';
import '../models/standards_model.dart';
import '../screens/parent_settings/parent_settings_repo.dart';

class SessionController extends GetxController {
  var currentStandard = Rxn<StandardModel>();
  var activeChild = Rxn<ChildProfileModel>();

  var parentName = Rxn<String>();
  // var parentAvatar = Rxn<String>();
  var childAvatar = Rxn<String>();

  var authToken = Rxn<String>();

  static const _standardKey = 'currentStandard';
  static const _authKey = 'isParentLoggedIn';
  static const _activeChildKey = 'activeChild';
  static const _parentNameKey = 'parentName';
  // static const _parentAvatarKey = 'parentAvatar';
  static const _childAvatarKey = 'childAvatar';
  static const _authTokenKey = 'authToken';

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
      activeChild.value = ChildProfileModel.fromJson(
        Map<String, dynamic>.from(savedChild),
      );
    }

    final savedParentName = _box.read(_parentNameKey);
    if (savedParentName != null) {
      parentName.value = savedParentName;
    }

    // final savedParentAvatar = _box.read(_parentAvatarKey);
    // if (savedParentAvatar != null) {
    //   parentAvatar.value = savedParentAvatar;
    // }

    final savedToken = _box.read(_authTokenKey);
    if (savedToken != null) {
      authToken.value = savedToken;
    }
  }

  Future<void> setParentLoggedIn(bool value) async {
    await _box.write(_authKey, value);
  }

  bool get isParentLoggedIn => _box.read(_authKey) ?? false;

  Future<void> setParentName(String name) async {
    parentName.value = name;
    await _box.write(_parentNameKey, name);
  }

  Future<void> setAuthToken(String token) async {
    authToken.value = token;
    await _box.write(_authTokenKey, token);
  }

  Future<void> clearAuthToken() async {
    authToken.value = null;
    await _box.remove(_authTokenKey);
  }

  //
  Future<void> setChildAvatar() async {
    final imagePath = await ImagePickerService.pickImage(ImageSource.gallery);
    if (imagePath != null) {
      childAvatar.value = imagePath;
      await _box.write(_childAvatarKey, imagePath);
    }
  }

  Future<void> setActiveChild(ChildProfileModel child) async {
    activeChild.value = child;
    await setCurrentStandard(child.standard);
    await _box.write(_activeChildKey, child.toJson());
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
      'standard': standard.standard,
    });
  }

  int? get currentStandardId => currentStandard.value?.id;

  Future<void> logout() async {
    await clearActiveChild();
    await clearAuthToken();
    await setParentLoggedIn(false);
  }
}

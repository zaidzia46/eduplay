import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/child_profile_model.dart';
import '../models/standards_model.dart';

class SessionController extends GetxController {
  var currentStandard = Rxn<StandardModel>();
  var activeChild = Rxn<ChildProfileModel>();

  static const _key = 'currentStandard';
  static const _authKey = 'isParentLoggedIn';
  static const _activeChildKey = 'activeChild';

  @override
  void onInit() {
    super.onInit();
    final saved = GetStorage().read(_key);
    if (saved != null) currentStandard.value = StandardModel.fromJson(saved);

    final savedChild = GetStorage().read(_activeChildKey);
    if (savedChild != null) {
      activeChild.value = ChildProfileModel.fromJson(
        Map<String, dynamic>.from(savedChild),
      );
    }
  }

  Future<void> setCurrentStandard(StandardModel standard) async {
    currentStandard.value = standard;
    await GetStorage().write(_key, {
      'id': standard.id,
      'standard': standard.standard,
    });
  }

  Future<void> setParentLoggedIn(bool value) async {
    await GetStorage().write(_authKey, value);
  }

  bool get isParentLoggedIn => GetStorage().read(_authKey) ?? false;

  // Future<void> setActiveChild(ChildProfileModel child) async {
  //   activeChild.value = child;
  //   await setCurrentStandard(child.standard);
  //   await GetStorage().write(_activeChildKey, child.toJson());
  // }

  Future<void> clearActiveChild() async {
    activeChild.value = null;
    currentStandard.value = null;
    await GetStorage().remove(_activeChildKey);
    await GetStorage().remove(_key);
  }

  int? get currentStandardId => currentStandard.value?.id;
}

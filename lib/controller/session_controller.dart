// session_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/child_profile_model.dart';
import '../models/standards_model.dart';

class SessionController extends GetxController {
  var currentStandard = Rxn<StandardModel>();
  var activeChild = Rxn<ChildProfileModel>();

  // Minimal for now — just the name, since that's all the "Welcome back"
  // greeting needs. Replace with a full ParentModel (id, name, email)
  // once real backend auth returns a parent object on login/register.
  var parentName = Rxn<String>();

  static const _standardKey = 'currentStandard';
  static const _authKey = 'isParentLoggedIn';
  static const _activeChildKey = 'activeChild';
  static const _parentNameKey = 'parentName';

  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();

    // Restore standard
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
  }

  Future<void> setParentLoggedIn(bool value) async {
    await _box.write(_authKey, value);
  }

  bool get isParentLoggedIn => _box.read(_authKey) ?? false;

  // Called once, right after registration — a real login later should
  // instead read this from the backend's response, not rely on what
  // was cached locally at signup time.
  Future<void> setParentName(String name) async {
    parentName.value = name;
    await _box.write(_parentNameKey, name);
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
    await setParentLoggedIn(false);
    // Parent name is intentionally kept even after logout — a returning
    // parent on the same device should still see their name pre-filled/
    // greeted next time, same reasoning as most apps not forgetting who
    // last used them locally. Clear explicitly elsewhere if you'd rather
    // wipe it on logout.
  }
}

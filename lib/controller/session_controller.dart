import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/supabase_client.dart';
import '../fns/image_picker_service.dart';
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

  Future<void> setChildAvatar() async {
    final imagePath = await ImagePickerService.pickImage(ImageSource.gallery);
    if (imagePath != null) {
      childAvatar.value = imagePath;
      await _box.write(_childAvatarKey, imagePath);
    }
  }

  Future<void> setActiveChild(ChildProfileModel child) async {
    activeChild.value = child;
    if (child.standard != null) {
      await setCurrentStandard(child.standard!);
    }
    await _box.write(_activeChildKey, child.toCacheJson());
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

  Future<void> logout() async {
    await supabase.auth.signOut();
    await clearActiveChild();
    parentName.value = null;
    await _box.remove(_parentNameKey);
  }
}

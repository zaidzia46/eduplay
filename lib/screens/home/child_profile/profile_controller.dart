import 'dart:developer';

import 'package:eduplay/screens/profile/create_child_profile/repo/create_child_profile_repo.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controller/session_controller.dart';
import '../../../fns/image_picker_service.dart';
import '../../profile/profile_switcher/models/child_profile_model.dart';
import '../../profile/profile_switcher/profile_switcher_controller.dart';

class ProfileViewModel extends GetxController {
  final ChildProfileRepository _childRepo = ChildProfileRepository();
  final SessionController _session = Get.find<SessionController>();

  final Rx<ChildProfileModel?> child = Rx<ChildProfileModel?>(null);
  final Rx<String?> avatarUrl = Rx<String?>(null);

  final Rx<String?> localPreviewPath = Rx<String?>(null);
  final RxBool isUploadingAvatar = false.obs;

  final RxBool avatarChanged = false.obs;

  final RxBool isSavingProfile = false.obs;
  final Rx<String?> profileUpdateError = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    child.value = _session.activeChild.value;
    _loadAvatarUrl();
  }

  Future<void> _loadAvatarUrl() async {
    final path = child.value?.avatar;
    avatarUrl.value = path != null
        ? await _childRepo.getAvatarSignedUrl(path)
        : null;
  }

  Future<void> changeAvatar() async {
    final currentChild = child.value;
    if (currentChild == null) return;

    final pickedPath = await ImagePickerService.pickImage(ImageSource.gallery);
    if (pickedPath == null) return;
    avatarChanged.value = !avatarChanged.value;

    localPreviewPath.value = pickedPath;
    isUploadingAvatar.value = true;

    try {
      final storagePath = await _childRepo.uploadAvatar(
        currentChild.id,
        pickedPath,
      );

      final updatedChild = currentChild.copyWith(avatarPath: storagePath);
      child.value = updatedChild;
      await _session.setActiveChild(updatedChild);
      final freshUrl = await _childRepo.getAvatarSignedUrl(storagePath);
      avatarUrl.value = freshUrl;

      if (Get.isRegistered<ProfileSwitcherViewModel>()) {
        Get.find<ProfileSwitcherViewModel>().updateChild(
          updatedChild,
          avatarUrl: freshUrl,
        );
      }
    } catch (e) {
      log('Avatar upload failed: $e');
      localPreviewPath.value = null;
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  /// Updates the active child's display name and username.
  /// Returns true on success so the UI can close its edit sheet.
  Future<bool> updateNameAndUsername({
    required String name,
    required String username,
  }) async {
    final currentChild = child.value;
    if (currentChild == null) return false;

    final trimmedName = name.trim();
    final trimmedUsername = username.trim();

    if (trimmedName.isEmpty) {
      profileUpdateError.value = 'Name cannot be empty';
      return false;
    }
    if (trimmedUsername.isEmpty) {
      profileUpdateError.value = 'Username cannot be empty';
      return false;
    }

    // No-op if nothing actually changed.
    if (trimmedName == currentChild.name &&
        trimmedUsername == currentChild.username) {
      return true;
    }

    profileUpdateError.value = null;
    isSavingProfile.value = true;

    try {
      // NOTE: assumes ChildProfileRepository exposes an update method with
      // this signature. Rename to match your actual repo method if different.
      await _childRepo.updateChildProfile(
        currentChild.id,
        name: trimmedName,
        username: trimmedUsername,
      );

      final updatedChild = currentChild.copyWith(
        name: trimmedName,
        username: trimmedUsername,
      );
      child.value = updatedChild;
      await _session.setActiveChild(updatedChild);

      if (Get.isRegistered<ProfileSwitcherViewModel>()) {
        Get.find<ProfileSwitcherViewModel>().updateChild(
          updatedChild,
          avatarUrl: avatarUrl.value,
        );
      }
      return true;
    } catch (e) {
      log('Profile update failed: $e');
      profileUpdateError.value = 'Could not update profile. Try again.';
      return false;
    } finally {
      isSavingProfile.value = false;
    }
  }
}

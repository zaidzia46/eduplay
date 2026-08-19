import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/parent_settings/parent_settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../routes/app_routes.dart';
import '../../core/supabase_client.dart';
import '../../fns/image_picker_service.dart';
import '../profile/create_child_profile/repo/create_child_profile_repo.dart';
import '../profile/profile_switcher/profile_switcher_controller.dart';

class ParentSettingsController extends GetxController {
  final session = Get.find<SessionController>();
  final _parentRepo = ParentRepository();
  var profileImagePath = Rxn<String>();
  final Rx<String?> localPreviewPath = Rx<String?>(null);
  final RxBool isUploadingAvatar = false.obs;

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isChangingPassword = false.obs;
  var passwordErrorMessage = ''.obs;
  var isLoadingAvatar = true.obs;

  late Future<void> loadingParentAvatar;

  @override
  void onInit() {
    super.onInit();
    loadingParentAvatar = _loadParentAvatar();
  }

  Future<void> _loadParentAvatar() async {
    final parentId = supabase.auth.currentUser!.id;
    final path = '$parentId/parent.png';

    try {
      final url = await _parentRepo.getAvatarSignedUrl(path);
      profileImagePath.value = url;
      log('Loaded parent avatar');
    } catch (e) {
      log('No parent avatar yet, or failed to load: $e');
    } finally {
      isLoadingAvatar.value = false;
    }
  }

  Future<void> setParentAvatar() async {
    final imagePath = await ImagePickerService.pickImage(ImageSource.gallery);
    if (imagePath == null) return;
    profileImagePath.value = imagePath;

    localPreviewPath.value = imagePath;
    isUploadingAvatar.value = true;

    try {
      final storagePath = await _parentRepo.uploadAvatar(imagePath);
      profileImagePath.value = await _parentRepo.getAvatarSignedUrl(
        storagePath,
      );
    } catch (e) {
      log('Avatar upload failed: $e');
      localPreviewPath.value = null;
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  bool _validatePasswordForm() {
    if (currentPasswordController.text.isEmpty) {
      passwordErrorMessage.value = 'Enter your current password.';
      return false;
    }
    if (newPasswordController.text.length < 6) {
      passwordErrorMessage.value =
          'New password must be at least 6 characters.';
      return false;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      passwordErrorMessage.value = 'Passwords do not match.';
      return false;
    }
    return true;
  }

  Future<void> changePassword() async {
    passwordErrorMessage.value = '';
    if (!_validatePasswordForm()) return;

    try {
      isChangingPassword.value = true;

      final email = supabase.auth.currentUser?.email;
      if (email == null) {
        passwordErrorMessage.value =
            'Could not verify your account. Try logging in again.';
        return;
      }

      // Supabase's updateUser() doesn't ask for the current password itself
      // (you're already authenticated) — so to actually verify it, we
      // re-authenticate with it first. Wrong current password fails here
      // with an AuthException before anything changes.
      await supabase.auth.signInWithPassword(
        email: email,
        password: currentPasswordController.text,
      );

      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.back();
      Get.snackbar('Success', 'Password updated.');
    } on AuthException catch (e) {
      passwordErrorMessage.value =
          e.message.toLowerCase().contains('invalid login credentials')
          ? 'Current password is incorrect.'
          : e.message;
    } catch (e) {
      passwordErrorMessage.value = 'Could not update password. Try again.';
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> logout() async {
    await session.logout();
    Get.delete<ProfileSwitcherViewModel>(force: true);
    ChildProfileRepository.clearCache();
    ParentRepository.clearCache();

    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

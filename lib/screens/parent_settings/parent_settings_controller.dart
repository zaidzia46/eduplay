import 'dart:developer';

import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/parent_settings/parent_settings_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../routes/app_routes.dart';
import '../../core/api_client.dart';
import '../../fns/image_picker_service.dart';

class ParentSettingsController extends GetxController {
  final session = Get.find<SessionController>();
  final _parentRepo = ParentRepository();
  var profileImagePath = Rxn<String>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isChangingPassword = false.obs;
  var passwordErrorMessage = ''.obs;

  Future<void> setParentAvatar() async {
    final imagePath = await ImagePickerService.pickImage(ImageSource.gallery);
    if (imagePath == null) return;
    profileImagePath.value = imagePath;

    try {
      final relativePath = await _parentRepo.uploadAvatar(imagePath);
      final fullUrl = ApiClient.resolveMediaUrl(relativePath);
      profileImagePath.value = fullUrl;
    } catch (e) {
      log('Avatar upload failed: $e');
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
      // TODO: replace with a real API call, e.g.
      // await authRepo.changePassword(current, newPassword);
      await Future.delayed(const Duration(seconds: 1));

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.back(); // close the change-password sheet/dialog
      Get.snackbar('Success', 'Password updated.');
    } catch (e) {
      passwordErrorMessage.value = 'Could not update password. Try again.';
    } finally {
      isChangingPassword.value = false;
    }
  }

  Future<void> logout() async {
    await session.logout();
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

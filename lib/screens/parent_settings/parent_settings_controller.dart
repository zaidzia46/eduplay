import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class ParentSettingsController extends GetxController {
  final session = Get.find<SessionController>();

  final avatars = [
    'assets/images/boy1.png',
    'assets/images/boy2.png',
    'assets/images/boy3.png',
    'assets/images/boy4.png',
    'assets/images/girl1.png',
    'assets/images/girl2.png',
    'assets/images/girl3.png',
    'assets/images/girl4.png',
  ];

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isChangingPassword = false.obs;
  var passwordErrorMessage = ''.obs;

  void selectAvatar(String path) {
    session.setParentAvatar(path);
    Get.back();
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

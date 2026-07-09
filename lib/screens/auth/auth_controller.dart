// viewmodels/auth_viewmodel.dart
import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class AuthViewModel extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final session = Get.find<SessionController>();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;
  var errorMessage = ''.obs;

  void togglePassword() => isPasswordHidden.toggle();

  Future<void> login() async {
    if (!_validateLoginForm()) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      // Mark parent as logged in
      await session.setParentLoggedIn(true);

      Get.offAllNamed(AppRoutes.profileSwitcher);
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!_validateRegisterForm()) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      await session.setParentLoggedIn(true);

      Get.offAllNamed(AppRoutes.profileSwitcher);
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter your email.';
      return false;
    }
    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Please enter your password.';
      return false;
    }
    return true;
  }

  bool _validateRegisterForm() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter your name.';
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Please enter a valid email.';
      return false;
    }
    if (passwordController.text.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters.';
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

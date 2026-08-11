import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:eduplay/controller/session_controller.dart';
import '../../core/supabase_client.dart';
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

      final response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _handleAuthSuccess(response);

      Get.offAllNamed(AppRoutes.profileSwitcher);
    } on AuthException catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    } catch (e) {
      errorMessage.value = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Login failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!_validateRegisterForm()) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        data: {'name': nameController.text.trim()},
      );

      await _handleAuthSuccess(response);

      Get.offAllNamed(AppRoutes.profileSwitcher);
    } on AuthException catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    } catch (e) {
      errorMessage.value = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleAuthSuccess(AuthResponse response) async {
    final user = response.user!;
    final accessToken = response.session?.accessToken;

    String parentName = (user.userMetadata?['name'] as String?) ?? '';
    if (parentName.isEmpty) {
      final row = await supabase
          .from('parents')
          .select('name')
          .eq('id', user.id)
          .single();
      parentName = (row['name'] as String?) ?? '';
    }
    await session.setParentName(parentName);
    await session.setParentLoggedIn(true);
  }

  String _extractErrorMessage(AuthException e) {
    return e.message;
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

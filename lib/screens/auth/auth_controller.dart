import 'package:dio/dio.dart';
import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api_client.dart';
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

      final response = await ApiClient.instance.post(
        '/api/v1/auth/login',
        data: {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      await _handleAuthSuccess(response.data['data']);

      Get.offAllNamed(AppRoutes.profileSwitcher);
    } on DioException catch (e) {
      errorMessage.value = _extractErrorMessage(e);
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

      final response = await ApiClient.instance.post(
        '/api/v1/auth/register',
        data: {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      await _handleAuthSuccess(response.data['data']);

      Get.offAllNamed(AppRoutes.profileSwitcher);
    } on DioException catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    final parent = data['parent'];
    final token = data['token'];

    await session.setAuthToken(token);
    await session.setParentName(parent['name']);
    await session.setParentLoggedIn(true);
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'];
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach the server. Check your connection and try again.';
    }
    return 'Something went wrong. Please try again.';
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

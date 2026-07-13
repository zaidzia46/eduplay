import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'auth_controller.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/auth_bg.png', fit: BoxFit.cover),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 100,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Text('Welcome back!', style: AppTextStyles.h1),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue your child\'s learning journey.',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 32),

                          // Email
                          _buildLabel('Email'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: vm.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'parent@email.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildLabel('Password'),
                          const SizedBox(height: 6),
                          Obx(
                            () => TextField(
                              controller: vm.passwordController,
                              obscureText: vm.isPasswordHidden.value,
                              decoration: InputDecoration(
                                hintText: '123456',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: GestureDetector(
                                  onTap: vm.togglePassword,
                                  child: Icon(
                                    vm.isPasswordHidden.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password?'),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Error message
                          Obx(
                            () => vm.errorMessage.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            vm.errorMessage.value,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 20),

                          // Login button
                          Obx(
                            () => ElevatedButton(
                              onPressed: vm.isLoading.value ? null : vm.login,
                              child: vm.isLoading.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Register link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.register),
                                  child: Text(
                                    'Sign Up',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: AppTextStyles.label);
}

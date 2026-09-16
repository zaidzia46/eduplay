import 'package:eduplay/screens/auth/widgets/auth_bg.dart';
import 'package:eduplay/screens/auth/widgets/auth_widgets.dart';
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
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 92,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeSlideIn(
                          delayMs: 80,
                          child: AuthTabs(
                            isLoginSelected: true,
                            onLogin: () {},
                            onRegister: () => Get.offNamed(AppRoutes.register),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delayMs: 160,
                          child: GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AuthHeading(
                                  title: 'Welcome back!',
                                  subtitle:
                                      "Sign in to continue your child's learning journey.",
                                ),
                                const SizedBox(height: 26),

                                AuthField(
                                  label: 'Email',
                                  hint: 'parent@email.com',
                                  icon: Icons.email_outlined,
                                  controller: vm.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),

                                Obx(
                                  () => AuthField(
                                    label: 'Password',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    controller: vm.passwordController,
                                    obscureText: vm.isPasswordHidden.value,
                                    textInputAction: TextInputAction.done,
                                    suffix: IconButton(
                                      onPressed: vm.togglePassword,
                                      icon: Icon(
                                        vm.isPasswordHidden.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.primaryDark,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot password?',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primaryDark,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),

                                Obx(
                                  () =>
                                      AuthError(message: vm.errorMessage.value),
                                ),
                                const SizedBox(height: 20),

                                Obx(
                                  () => AuthButton(
                                    label: 'Sign In',
                                    isLoading: vm.isLoading.value,
                                    onPressed: vm.login,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const AuthDivider(text: 'Or'),
                                const SizedBox(height: 12),
                                Obx(
                                  () => AuthButton(
                                    label: 'Explore as guest',
                                    isLoading: vm.isLoadingGuest.value,
                                    onPressed: vm.continueAsGuest,
                                  ),
                                ),
                                const SizedBox(height: 22),

                                const AuthDivider(),
                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    SocialButton(
                                      label: 'Google',
                                      icon: const Icon(
                                        Icons.g_mobiledata,
                                        size: 26,
                                        color: AppColors.primaryDark,
                                      ),
                                      onTap: () {},
                                    ),
                                    const SizedBox(width: 12),
                                    SocialButton(
                                      label: 'Apple',
                                      icon: const Icon(
                                        Icons.apple,
                                        size: 22,
                                        color: AppColors.textPrimary,
                                      ),
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                AuthFooterLink(
                                  text: "Don't have an account? ",
                                  actionText: 'Sign Up',
                                  onTap: () => Get.offNamed(AppRoutes.register),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

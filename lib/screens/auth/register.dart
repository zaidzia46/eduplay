import 'package:eduplay/screens/auth/widgets/auth_bg.dart';
import 'package:eduplay/screens/auth/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/circle_back_button.dart';
import 'auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();

    return Scaffold(
      // No AppBar: there's no back button (the form has its own dismiss
      // affordances via the tabs / footer link), and the empty AppBar was
      // still nudging the Hero logo's landing position down. Matching
      // login's plain SafeArea-on-body structure keeps the Hero flight
      // purely a fade/slide with no vertical drift.
      body: AuthBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 92,
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeSlideIn(
                        delayMs: 80,
                        child: AuthTabs(
                          isLoginSelected: false,
                          onLogin: () => Get.offNamed(AppRoutes.login),
                          onRegister: () {},
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
                                title: 'Create Account',
                                subtitle:
                                    "Sign up to start your child's learning adventure.",
                              ),
                              const SizedBox(height: 24),

                              AuthField(
                                label: 'Full Name',
                                hint: 'Your full name',
                                icon: Icons.person_outline,
                                controller: vm.nameController,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),

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

                              Obx(
                                () => AuthError(message: vm.errorMessage.value),
                              ),
                              const SizedBox(height: 22),

                              Obx(
                                () => AuthButton(
                                  label: 'Create Account',
                                  isLoading: vm.isLoading.value,
                                  onPressed: vm.register,
                                ),
                              ),
                              const SizedBox(height: 22),

                              const AuthDivider(text: 'Or sign up with'),
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
                                text: 'Already have an account? ',
                                actionText: 'Sign In',
                                onTap: () => Get.offNamed(AppRoutes.login),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 10,
                  child: CircleBackButton(onTap: () => Get.back()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:eduplay/screens/auth/widgets/auth_bg.dart';
import 'package:eduplay/screens/auth/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'auth_controller.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AuthViewModel>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: AuthBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(
                    child: Center(
                      child: Hero(
                        tag: 'auth-logo',
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 76,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeSlideIn(
                    delayMs: 80,
                    child: AuthTabs(
                      isLoginSelected: false,
                      onLogin: () => Get.back(),
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

                          Obx(() => AuthError(message: vm.errorMessage.value)),
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
                            onTap: () => Get.back(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

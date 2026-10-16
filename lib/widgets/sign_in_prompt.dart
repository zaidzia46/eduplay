import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Asks a logged-out user to sign in before opening an account-only screen.
///
/// Used by the Parent shell, whose bottom-nav tabs sit inside a *public* route
/// (`/parent-home`) and so can't be guarded by `AuthGuard` — the gate has to
/// happen at the tap instead. Offers both ways in, then returns the user to
/// whatever they were looking at (the app dashboard) if they decline.
///
/// Styling follows the app's existing dialog — see the logout confirmation in
/// `parent_settings_screen.dart`.
Future<void> showSignInPrompt() {
  // Tapping a gated tab twice shouldn't stack dialogs.
  if (Get.isDialogOpen ?? false) return Future.value();

  return Get.dialog<void>(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Sign in required', style: AppTextStyles.h3),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign in or create an account to open your family dashboard and '
            'manage your children.',
            style: AppTextStyles.bodySecondary.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.register);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Create an Account',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class SignInPlaceholder extends StatelessWidget {
  const SignInPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 54,
                color: AppColors.primary.withOpacity(0.35),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 8),
              Text(
                'This area is available once you sign in to your account.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: showSignInPrompt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

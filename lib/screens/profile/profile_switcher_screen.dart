// views/profile_switcher/profile_switcher_view.dart
import 'package:eduplay/screens/profile/profile_switcher_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/child_profile_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ProfileSwitcherView extends StatelessWidget {
  const ProfileSwitcherView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ProfileSwitcherViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text("Who's learning\ntoday? 👋", style: AppTextStyles.h1),
              const SizedBox(height: 6),
              Text(
                'Select a profile to continue.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 32),

              // Profile grid
              Expanded(
                child: Obx(() {
                  if (vm.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('😕', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            vm.errorMessage.value,
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: vm.fetchChildren,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Build grid of profiles + add button
                  final items = [...vm.children, null]; // null = add button

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final child = items[index];
                      if (child == null) {
                        return _AddProfileCard(onTap: vm.goToCreateProfile);
                      }
                      return _ProfileCard(
                        child: child,
                        onTap: () => vm.selectChild(child),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final ChildProfileModel child;
  final VoidCallback onTap;

  const _ProfileCard({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primarySurface,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: child.avatar != null
                  ? ClipOval(
                      child: Image.asset(
                        child.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.person,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              child.name,
              style: AppTextStyles.h4,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Standard
            Text(child.standard.standard, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ── Add profile card ──────────────────────────────────────────────────────────
class _AddProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: const Icon(Icons.add, size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Add Profile',
              style: AppTextStyles.h4.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

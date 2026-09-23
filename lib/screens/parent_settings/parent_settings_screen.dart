import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/routes/app_routes.dart';
import 'package:eduplay/screens/parent_settings/parent_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/action_tile.dart';
import '../../widgets/parent_welcome_bg.dart';
import '../auth/auth_controller.dart';
import '../profile/widgets/skeleton_avatar_loader.dart';

class ParentSettingsView extends StatelessWidget {
  const ParentSettingsView({super.key});

  static const double _avatarSize = 96;
  static const double _headerExtraHeight =
      130; // space under app bar, above the avatar

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ParentSettingsController>();
    final session = vm.session;
    final topPadding = MediaQuery.of(context).padding.top;
    const appBarHeight = kToolbarHeight;

    // Total gradient header height = status bar + app bar + extra space +
    // half of the avatar (which overlaps into the content below).
    final headerHeight =
        topPadding + appBarHeight + _headerExtraHeight + _avatarSize / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Guardian Settings',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      body: Stack(
        children: [
          // Gradient header — height adapts to the device's status bar.
          WelcomeBackgroundContainer(
            child: SizedBox(height: headerHeight, width: double.infinity),
          ),

          // Content starts exactly where the header's flat part ends,
          // so the avatar half-overlaps the gradient on every screen size.
          Padding(
            padding: EdgeInsets.only(top: topPadding + appBarHeight),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  const SizedBox(height: _headerExtraHeight - 24),

                  // ---- Avatar ----
                  GestureDetector(
                    onTap: vm.setParentAvatar,
                    child: Obx(() {
                      final localPath = vm.localPreviewPath.value;
                      final url = vm.profileImagePath.value;
                      final isLoading = vm.isLoadingAvatar.value;

                      ImageProvider? imageProvider;
                      if (localPath != null) {
                        imageProvider = FileImage(File(localPath));
                      } else if (url != null) {
                        imageProvider = CachedNetworkImageProvider(url);
                      }

                      final showSkeleton = isLoading && imageProvider == null;

                      return Stack(
                        children: [
                          Container(
                            width: _avatarSize,
                            height: _avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: showSkeleton
                                ? const SkeletonAvatarLoader(
                                    avatarSize: _avatarSize,
                                  )
                                : CircleAvatar(
                                    radius: _avatarSize / 2,
                                    backgroundColor: AppColors.primaryDark,
                                    backgroundImage: imageProvider,
                                    child: imageProvider == null
                                        ? const Icon(
                                            Icons.person_rounded,
                                            size: _avatarSize * 0.5,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // ---- Name pill (lives fully below the gradient) ----
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(.08),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        session.parentName.value ?? 'Guardian',
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ---- Actions ----
                  Obx(() {
                    session.parentName.value; // reactive trigger
                    if (session.isGuest) {
                      return _PremiumTile(
                        child: ActionTile(
                          icon: Icons.person_add_alt_1_outlined,
                          label: 'Sign up to save your account',
                          subtitle: 'Keep your stars and progress forever',
                          color: AppColors.primary,
                          onTap: () => Get.toNamed(
                            AppRoutes.register,
                            arguments: {'convert': true},
                          ),
                        ),
                      );
                    }
                    return _PremiumTile(
                      child: ActionTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        subtitle: 'Update your account password',
                        color: AppColors.primary,
                        onTap: () => _showChangePasswordSheet(context, vm),
                      ),
                    );
                  }),
                  const SizedBox(height: 14),
                  _PremiumTile(
                    child: ActionTile(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      subtitle: 'Sign out of your guardian account',
                      color: AppColors.error,
                      onTap: () => _showLogoutDialog(context, vm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- sheets & dialogs (unchanged logic, polished visuals) ----------

  void _showChangePasswordSheet(
    BuildContext context,
    ParentSettingsController vm,
  ) {
    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Change Password', style: AppTextStyles.h4),
                const SizedBox(height: 16),
                TextField(
                  controller: vm.currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vm.newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    prefixIcon: const Icon(Icons.password_rounded),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vm.confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => vm.passwordErrorMessage.isNotEmpty
                      ? Text(
                          vm.passwordErrorMessage.value,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(.35),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: vm.isChangingPassword.value
                            ? null
                            : vm.changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: vm.isChangingPassword.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Update Password',
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ParentSettingsController vm) {
    // A guest's session is the only handle to their account: signing out
    // orphans the child + stars + progress with no way back. Warn them and
    // offer conversion first, but still allow a deliberate "log out anyway".
    final isGuest = vm.session.isGuest;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isGuest ? 'Leave without saving?' : 'Log Out?',
          style: AppTextStyles.h3,
        ),
        content: Text(
          isGuest
              ? "You're exploring as a guest. Log out now and your stars and "
                    'progress are gone for good — sign up to keep them.'
              : 'You\'ll need to sign in again to access EduPlay.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          if (isGuest)
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.register, arguments: {'convert': true});
              },
              child: const Text('Sign Up & Save'),
            ),
          Obx(
            () => ElevatedButton(
              onPressed: vm.isLoggingOut.value ? null : vm.logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: vm.isLoggingOut.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isGuest ? 'Log out anyway' : 'Log Out',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft elevated card wrapper that gives the action tiles a premium feel.
class _PremiumTile extends StatelessWidget {
  const _PremiumTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(20), child: child),
    );
  }
}

import 'dart:developer';

import 'package:eduplay/screens/parent_settings/parent_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/action_tile.dart';

class ParentSettingsView extends StatelessWidget {
  const ParentSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ParentSettingsController>();
    final session = vm.session;
    const double avatarSize = 84;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Parent Settings',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.asset('assets/images/profile_bg.png'),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(height: 90),
                Obx(() {
                  final avatar = session.parentAvatar.value;
                  return GestureDetector(
                    onTap: () => _imagePicker(context, vm),
                    child: Stack(
                      children: [
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xffFFD84E),
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/pak_mom2.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.textPrimary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(
                  () => Text(
                    session.parentName.value ?? 'Parent',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),
                ),

                const SizedBox(height: 60),

                ActionTile(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  subtitle: 'Update your account password',
                  color: AppColors.primary,
                  onTap: () => _showChangePasswordSheet(context, vm),
                ),
                const SizedBox(height: 12),
                ActionTile(
                  icon: Icons.logout_outlined,
                  label: 'Log Out',
                  subtitle: 'Sign out of your parent account',
                  color: AppColors.error,
                  onTap: () => _showLogoutDialog(context, vm),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _imagePicker(BuildContext context, ParentSettingsController vm) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose an avatar', style: AppTextStyles.h4),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => _pickAndSetImage(vm, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => _pickAndSetImage(vm, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSetImage(
    ParentSettingsController vm,
    ImageSource source,
  ) async {
    final picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85, // compress a bit, optional
      maxWidth: 1024, // avoid huge files, optional
    );
    log("Picked Path${picked?.path}");

    if (picked == null) return; // user cancelled

    vm.selectAvatar(picked.path);
  }

  void _showChangePasswordSheet(
    BuildContext context,
    ParentSettingsController vm,
  ) {
    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change Password', style: AppTextStyles.h4),
                const SizedBox(height: 16),
                TextField(
                  controller: vm.currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current password',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vm.newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: vm.confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm new password',
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
                  () => ElevatedButton(
                    onPressed: vm.isChangingPassword.value
                        ? null
                        : vm.changePassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
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
                        : const Text('Update Password'),
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
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out?', style: AppTextStyles.h3),
        content: Text(
          'You\'ll need to sign in again to access EduPlay.',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await vm.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/home/child_profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/action_tile.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final session = Get.find<SessionController>();
    final vm = Get.find<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FE),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(.14),
                    const Color(0xFFF8F7FF),
                    const Color(0xFFF7F5FE),
                  ],
                  stops: const [0.0, 0.38, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            top: -70,
            left: -70,
            child: _Bubble(
              size: 210,
              color: AppColors.primary.withOpacity(.12),
            ),
          ),

          Positioned(
            top: 90,
            right: -70,
            child: _Bubble(
              size: 170,
              color: AppColors.primary.withOpacity(.09),
            ),
          ),

          Positioned(
            bottom: 130,
            left: -55,
            child: _Bubble(
              size: 130,
              color: AppColors.primary.withOpacity(.07),
            ),
          ),

          Positioned(
            bottom: 30,
            right: 30,
            child: _Bubble(size: 80, color: AppColors.primary.withOpacity(.08)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    _buildHeader(),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Obx(() {
                              final child = session.activeChild.value;

                              if (child == null) {
                                return const SizedBox.shrink();
                              }

                              return _buildProfileCard(child, vm);
                            }),

                            const SizedBox(height: 22),

                            Obx(() {
                              final child = session.activeChild.value;

                              if (child == null) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                children: [
                                  _buildInfoTile(
                                    category: 'Standard / Grade',
                                    title:
                                        child.standard?.name ?? 'No standard',
                                    icon: Icons.menu_book_rounded,
                                    iconColor: AppColors.primary,
                                  ),

                                  const SizedBox(height: 12),

                                  _buildInfoTile(
                                    category: 'Institution',
                                    title:
                                        child.institution?.name ??
                                        'No institution',
                                    icon: Icons.account_balance_rounded,
                                    iconColor: const Color(0xFF10B981),
                                  ),
                                ],
                              );
                            }),

                            const SizedBox(height: 22),

                            _buildSwitchProfile(),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: Text(
            'Profile',
            style: AppTextStyles.h1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic child, ProfileViewModel vm) {
    const double avatarSize = 104;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.92, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, childWidget) {
        return Transform.scale(scale: value, child: childWidget);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.94),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.10),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: vm.changeAvatar,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(.55),
                          const Color(0xFFC4B5FD),
                          AppColors.primary,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(.25),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Obx(() {
                        final localPath = vm.localPreviewPath.value;

                        final url = vm.avatarUrl.value;

                        // Local image
                        if (localPath != null) {
                          return ClipOval(
                            child: Image.file(
                              File(localPath),
                              width: avatarSize,
                              height: avatarSize,
                              fit: BoxFit.cover,
                            ),
                          );
                        }

                        // Network image
                        if (url != null && url.isNotEmpty) {
                          return ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: avatarSize,
                              height: avatarSize,
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                return _defaultAvatar(avatarSize);
                              },
                              errorWidget: (context, url, error) {
                                return _defaultAvatar(avatarSize);
                              },
                            ),
                          );
                        }

                        // Default avatar
                        return _defaultAvatar(avatarSize);
                      }),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    child.name,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showEditProfileSheet(context, child, vm),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary.withOpacity(.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 7),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '@${child.username}',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet(
    BuildContext context,
    dynamic child,
    ProfileViewModel vm,
  ) {
    final nameController = TextEditingController(text: child.name);
    final usernameController = TextEditingController(text: child.username);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E1FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Name cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixText: '@',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Username cannot be empty'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final error = vm.profileUpdateError.value;
                    if (error == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    );
                  }),
                  Obx(() {
                    final saving = vm.isSavingProfile.value;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              final success = await vm.updateNameAndUsername(
                                name: nameController.text,
                                username: usernameController.text,
                              );
                              if (success && sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _defaultAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF1EDFF),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * .45,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoTile({
    required String category,
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EEFA), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchProfile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EEFA), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ActionTile(
        icon: Icons.switch_account_rounded,
        label: 'Switch Profile',
        subtitle: 'Change to a different child',
        color: AppColors.primary,
        onTap: () {
          Get.toNamed(
            AppRoutes.profileSwitcher,
            arguments: {'showBackButton': true},
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

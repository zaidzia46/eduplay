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
import '../../../widgets/info_chip.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final session = Get.find<SessionController>();
    final vm = Get.find<ProfileViewModel>();
    const double avatarSize = 90;
    final media = MediaQuery.of(context);
    final size = media.size;
    final bannerWidth = size.width - 24;
    final bannerHeight = bannerWidth * 841 / 1871;
    final topBackgroundHeight = (media.padding.top + 97 + bannerHeight).clamp(
      250.0,
      size.height * 0.45,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 0.85, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/images/profile_bg2.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  Obx(() {
                    final child = session.activeChild.value;
                    if (child == null) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/profile_card_bg.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: vm.changeAvatar,
                            child: Stack(
                              children: [
                                Obx(() {
                                  final localPath = vm.localPreviewPath.value;
                                  final url = vm.avatarUrl.value;

                                  ImageProvider? imageProvider;
                                  if (localPath != null) {
                                    imageProvider = FileImage(File(localPath));
                                  } else if (url != null) {
                                    imageProvider = CachedNetworkImageProvider(
                                      url,
                                    );
                                  }
                                  return Container(
                                    width: avatarSize,
                                    height: avatarSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xffFFD84E),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: avatarSize / 2,
                                      backgroundColor: AppColors.primaryDark,
                                      backgroundImage: imageProvider,
                                      child: url == null
                                          ? Icon(
                                              Icons.person,
                                              size: avatarSize * 0.5,
                                            )
                                          : null,
                                    ),
                                  );
                                }),
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
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            child.name,
                            style: AppTextStyles.h2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),

                          // Username
                          Text(
                            '@${child.username}',
                            style: AppTextStyles.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InfoChip(
                                icon: Icons.school_outlined,
                                label: child.standard?.name ?? 'No standard',
                              ),
                              const SizedBox(height: 8),
                              InfoChip(
                                icon: Icons.location_city_outlined,
                                label:
                                    child.institution?.name ?? 'No institution',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  ActionTile(
                    icon: Icons.switch_account_outlined,
                    label: 'Switch Profile',
                    subtitle: 'Change to a different child',
                    color: AppColors.primary,
                    onTap: () async {
                      Get.toNamed(AppRoutes.profileSwitcher);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

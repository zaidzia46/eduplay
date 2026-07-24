import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/action_tile.dart';
import '../../widgets/info_chip.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();
    const double avatarSize = 70;
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
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h1.copyWith(color: AppColors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              'assets/images/profile_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
              child: Column(
                children: [
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
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(.25),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: avatarSize / 2,
                              backgroundColor: const Color(0xffFFD84E),
                              child: ClipOval(
                                child: child.avatar != null
                                    ? Image.asset(
                                        child.avatar!,
                                        fit: BoxFit.cover,
                                        width: avatarSize,
                                        height: avatarSize,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(
                                              Icons.person,
                                              size: 45,
                                              color: AppColors.primary,
                                            ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: AppColors.primary,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Name
                          Text(child.name, style: AppTextStyles.h2),
                          const SizedBox(height: 4),

                          // Username
                          Text(
                            '@${child.username}',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 12),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              InfoChip(
                                icon: Icons.school_outlined,
                                label: child.standard.standard,
                              ),
                              const SizedBox(height: 8),
                              InfoChip(
                                icon: Icons.location_city_outlined,
                                label: child.institution.name,
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

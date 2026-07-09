// views/profile_switcher/profile_switcher_view.dart
import 'package:eduplay/screens/profile/profile_switcher/profile_switcher_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/add_profile_card.dart';
import '../../../widgets/circular_loader.dart';
import '../../../widgets/profile_card.dart';

class ProfileSwitcherView extends StatelessWidget {
  const ProfileSwitcherView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ProfileSwitcherViewModel>();
    final media = MediaQuery.of(context);
    final size = media.size;
    final bannerWidth = size.width - 24;
    final bannerHeight = bannerWidth * 841 / 1871;
    final topBackgroundHeight = (media.padding.top + 97 + bannerHeight).clamp(
      250.0,
      size.height * 0.45,
    );
    // const double avatarSize = 60;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                'assets/images/profile_sec_banner.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Obx(() {
                if (vm.isLoading.value) {
                  return Center(child: CircularLoader());
                }

                if (vm.errorMessage.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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

                final items = [...vm.children, null];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final child = items[index];
                      if (child == null) {
                        return AddProfileCard(onTap: vm.goToCreateProfile);
                      }
                      return ProfileCard(
                        child: child,
                        onTap: () => vm.selectChild(child),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

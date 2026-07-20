import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/profile/profile_switcher/profile_switcher_controller.dart';
import 'package:eduplay/widgets/parent_welcome.dart';
import 'package:eduplay/widgets/staggered_anime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/add_profile_card.dart';
import '../../../widgets/circular_loader.dart';
import '../../../widgets/profile_card.dart';
import '../../../widgets/welcome_bg_parent_dashboard.dart';

class ProfileSwitcherView extends StatefulWidget {
  const ProfileSwitcherView({super.key});

  @override
  State<ProfileSwitcherView> createState() => _ProfileSwitcherViewState();
}

class _ProfileSwitcherViewState extends State<ProfileSwitcherView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Worker _worker;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    final vm = Get.find<ProfileSwitcherViewModel>();

    _worker = ever(vm.children, (_) {
      _controller
        ..reset()
        ..forward();
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _worker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<ProfileSwitcherViewModel>();
    final session = Get.find<SessionController>();
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
      body: Column(
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
                stops: [0.0, 0.5, 0.9, 1.0],
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              'assets/images/profile_switch_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 13),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Obx(() {
                return WelcomeBackground(
                  welcomeText: 'Welcome',
                  subtitleText:
                      "You're doing a wonderful job supporting your children's journey.",
                  childrenCount: vm.children.length,
                  starsCount: vm.totalStars.value,
                  userName: session.parentName.value ?? 'User',
                );
              }),
            ),
          ),

          SizedBox(height: 12),

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

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final child = items[index];

                  return StaggeredAnimation(
                    controller: _controller,
                    index: index,
                    child: child == null
                        ? AddProfileCard(onTap: vm.goToCreateProfile)
                        : ProfileCard(
                            child: child,
                            stars: vm.starsByChild[child.id] ?? 0,
                            streak: vm.streakByChild[child.id] ?? 0,
                            onTap: () => vm.selectChild(child),
                          ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

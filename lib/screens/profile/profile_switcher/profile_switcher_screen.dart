import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/controller/session_controller.dart';
import 'package:eduplay/screens/profile/profile_switcher/profile_switcher_controller.dart';
import 'package:eduplay/widgets/staggered_anime.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_text_styles.dart';
import '../../../widgets/add_profile_card.dart';
import '../../../widgets/welcome_bg_parent_dashboard.dart';
import '../../parent_settings/parent_settings_bin.dart';
import '../../parent_settings/parent_settings_screen.dart';
import '../widgets/profile_card.dart';
import '../widgets/skeleton_card_loader.dart';

class ProfileSwitcherView extends StatefulWidget {
  const ProfileSwitcherView({super.key});

  @override
  State<ProfileSwitcherView> createState() => _ProfileSwitcherViewState();
}

class _ProfileSwitcherViewState extends State<ProfileSwitcherView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Worker _worker;

  // Tracks which set of (childId -> avatarUrl) pairs we last kicked off
  // precaching for, so we don't redo it on every unrelated Obx rebuild.
  String? _precachedKey;
  Future<void>? _precacheFuture;

  /// Warms Flutter's image cache for every visible child's avatar so that
  /// by the time ProfileCard actually builds, CachedNetworkImage resolves
  /// from cache instantly instead of showing its own placeholder/skeleton.
  Future<void> _precacheAvatars(ProfileSwitcherViewModel vm) {
    final urls = vm.children
        .map((c) => vm.avatarUrlByChild[c.id])
        .whereType<String>()
        .toSet();

    return Future.wait(
      urls.map(
        (url) => precacheImage(CachedNetworkImageProvider(url), context)
            .catchError((_) {
              // Swallow individual failures (bad url/offline) so one broken
              // avatar can't hold up the rest of the list forever.
            }),
      ),
    );
  }

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
          OpenContainer(
            transitionDuration: const Duration(milliseconds: 600),
            transitionType: ContainerTransitionType.fade,

            closedElevation: 0,
            openElevation: 0,

            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            openShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),

            closedBuilder: (context, openContainer) {
              return Padding(
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
              );
            },

            openBuilder: (context, _) {
              ParentSettingsBinding().dependencies();

              return ParentSettingsView();
            },
          ),

          SizedBox(height: 12),

          Expanded(
            child: Obx(() {
              if (vm.isLoading.value) {
                return const ProfileCardSkeletonList();
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

              // Recompute only when the actual (child, avatarUrl) pairs
              // change, so this doesn't fire on every Obx rebuild.
              final key = vm.children
                  .map((c) => '${c.id}:${vm.avatarUrlByChild[c.id]}')
                  .join(',');
              if (_precachedKey != key) {
                _precachedKey = key;
                _precacheFuture = _precacheAvatars(vm);
              }

              return FutureBuilder<void>(
                future: _precacheFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const ProfileCardSkeletonList();
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
                                avatarUrl: vm.avatarUrlByChild[child.id],
                                onTap: () => vm.selectChild(child),
                              ),
                      );
                    },
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

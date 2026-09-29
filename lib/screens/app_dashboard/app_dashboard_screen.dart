import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/fns/image_constant.dart';
import 'package:eduplay/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/expanded_avatar.dart';
import '../../widgets/title_row.dart';
import '../parent_dashboard/widgets/classified_ad_card.dart';
import '../parent_settings/parent_settings_controller.dart';
import '../profile/widgets/skeleton_avatar_loader.dart';

class AppDashboardView extends StatefulWidget {
  const AppDashboardView({super.key});

  @override
  State<AppDashboardView> createState() => _AppDashboardViewState();
}

class _AppDashboardViewState extends State<AppDashboardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _viewAllClassifieds() {
    Get.snackbar(
      'Classifieds',
      'The full classifieds marketplace is coming soon.',
      backgroundColor: AppColors.primary,
      barBlur: 12.0,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SoftBackground(
        child: Stack(
          children: [
            // const _DashboardBackdrop(),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _Entrance(
                      animation: _entrance,
                      interval: const Interval(
                        0.00,
                        0.45,
                        curve: Curves.easeOutCubic,
                      ),
                      child: Center(
                        child: Image.asset(ImageConstant.logo, height: 84),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _Entrance(
                        animation: _entrance,
                        interval: const Interval(
                          0.12,
                          0.60,
                          curve: Curves.easeOutCubic,
                        ),
                        child: const _ParentEntryCard(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _Entrance(
                        animation: _entrance,
                        interval: const Interval(
                          0.24,
                          0.72,
                          curve: Curves.easeOutCubic,
                        ),
                        child: const _PromoBanner(),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _Entrance(
                      animation: _entrance,
                      interval: const Interval(
                        0.36,
                        0.85,
                        curve: Curves.easeOutCubic,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TitleRow(
                              title: 'Classified Ads',
                              onTap: _viewAllClassifieds,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Find tutors, books, school essentials and more.',
                              style: AppTextStyles.caption,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 180,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: kClassifiedAds.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) =>
                                  ClassifiedAdCard(ad: kClassifiedAds[index]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF8EF), // soft warm cream
              Color(0xFFF6F1FB), // gentle lavender
              Color(0xFFF3F5FB), // cool finish
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _glow(
                220,
                const Color(0xFF7A35C9).withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              top: 260,
              left: -90,
              child: _glow(
                260,
                const Color(0xFFF6C544).withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: _glow(
                200,
                const Color(0xFF4B1F8C).withValues(alpha: 0.07),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
    ),
  );
}

class _Entrance extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  const _Entrance({
    required this.animation,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B1F8C).withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          ImageConstant.appDashboard,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

class _ParentEntryCard extends StatelessWidget {
  const _ParentEntryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B1F8C).withOpacity(0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4B1F8C),
                  Color(0xFF7A35C9),
                  Color(0xFFE7A23D),
                  Color(0xFFF6C544),
                ],
                stops: [0.0, 0.4, 0.78, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Decorative glass circles for depth.
                Positioned(top: -34, right: -24, child: _deco(120, 0.10)),
                Positioned(bottom: -46, left: -18, child: _deco(140, 0.08)),
                InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.parentDashboard,
                    arguments: {'convert': true},
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Glassy avatar bubble.
                            _buildAvatar(),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Guardian',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Continue to your family',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Circular chevron badge.
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Hairline separator between the header and actions.
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.22),
                        ),
                        const SizedBox(height: 16),
                        _CardButton(
                          label: 'Login / Register',
                          filled: true,
                          onTap: () => Get.toNamed(AppRoutes.login),
                        ),
                      ],
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

  Widget _buildAvatar() {
    final vm = Get.find<ParentSettingsController>();
    double avatarSize = 65;

    return Obx(() {
      final localPath = vm.localPreviewPath.value;
      final url = vm.profileImagePath.value;
      final isLoading = vm.isLoadingAvatar.value;

      Widget avatarContent;

      if (localPath != null) {
        avatarContent = ExpandableAvatar(
          avatarSize: avatarSize,
          localPreviewPath: localPath,
          collapsedChild: CircleAvatar(
            radius: avatarSize / 2,
            backgroundColor: AppColors.primaryDark,
            backgroundImage: FileImage(File(localPath)),
          ),
        );
      } else if (isLoading) {
        avatarContent = SkeletonAvatarLoader(avatarSize: avatarSize);
      } else if (url != null) {
        avatarContent = ExpandableAvatar(
          imageUrl: url,
          avatarSize: avatarSize,
          collapsedChild: ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  SkeletonAvatarLoader(avatarSize: avatarSize),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: AppColors.primaryDark,
                child: Icon(Icons.person, size: avatarSize * 0.5),
              ),
            ),
          ),
        );
      } else {
        avatarContent = CircleAvatar(
          radius: avatarSize / 2,
          backgroundColor: AppColors.primaryDark,
          child: Icon(Icons.person, size: avatarSize * 0.5),
        );
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF6C544),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.crown,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _deco(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );
}

class _CardButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _CardButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.white : Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled
                ? null
                : Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.buttonMedium.copyWith(
              color: filled ? AppColors.primary : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

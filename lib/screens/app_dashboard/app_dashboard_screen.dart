import 'package:carousel_slider/carousel_slider.dart';
import 'package:eduplay/fns/image_constant.dart';
import 'package:eduplay/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/title_row.dart';
import 'controllers/classified_ads_controller.dart';
import 'controllers/promo_banner_controller.dart';
import 'widgets/classified_ad_card.dart';

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

  final ClassifiedAdsController _adsController =
      Get.find<ClassifiedAdsController>();

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

  /// The Classified Ads section, driven by [ClassifiedAdsController]. While
  /// loading it shows skeleton cards; once loaded it renders the real ads. If
  /// there are no ads (empty table or a fetch error), the whole section is
  /// hidden so the logged-out landing stays clean.
  Widget _buildClassifieds() {
    return Obx(() {
      final loading = _adsController.isLoading.value;
      final ads = _adsController.ads;

      if (!loading && ads.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: TitleRow(
              title: 'Classified Ads',
              onTap: _viewAllClassifieds,
            ),
          ),
          const SizedBox(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Find tutors, books, school essentials and more.',
              style: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 12.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;
              final imageHeight =
                  cardWidth * 10 / 16; // matches the card's 16/10 ratio
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final textArea = 100 * textScale;

              final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent:
                    imageHeight + textArea, // replaces childAspectRatio
              );

              if (loading) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  gridDelegate: gridDelegate,
                  itemBuilder: (context, index) =>
                      const ClassifiedAdCardSkeleton(),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ads.length,
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) =>
                    ClassifiedAdCard(ad: ads[index]),
              );
            },
          ),
        ],
      );
    });
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
                      padding: const EdgeInsets.symmetric(horizontal: 14),
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
                    const SizedBox(height: 14),
                    _Entrance(
                      animation: _entrance,
                      interval: const Interval(
                        0.24,
                        0.72,
                        curve: Curves.easeOutCubic,
                      ),
                      child: const _PromoBanner(),
                    ),
                    const SizedBox(height: 9),
                    _Entrance(
                      animation: _entrance,
                      interval: const Interval(
                        0.36,
                        0.85,
                        curve: Curves.easeOutCubic,
                      ),
                      child: _buildClassifieds(),
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

/// The promo carousel. All of its state (banner list + active page) lives in
/// [PromoBannerController], so this is a plain [StatelessWidget] — the dot
/// indicator rebuilds via [Obx] instead of `setState`.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PromoBannerController>();

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: controller.banners.length,
          options: CarouselOptions(
            aspectRatio: 16 / 7, // match your banner image ratio
            viewportFraction: 0.88, // <1 makes neighbours peek at the edges
            enlargeCenterPage: false,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => controller.onPageChanged(index),
          ),
          itemBuilder: (context, index, _) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  controller.banners[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(controller.banners.length, (i) {
              final active = i == controller.currentIndex.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF4B1F8C)
                      : const Color(0xFF4B1F8C).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ParentEntryCard extends StatelessWidget {
  const _ParentEntryCard();

  void _login() => Get.toNamed(AppRoutes.login);

  void _register() => Get.toNamed(AppRoutes.register);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B1F8C).withOpacity(0.26),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
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
              Positioned(top: -34, right: -24, child: _deco(110, 0.10)),
              Positioned(bottom: -46, left: -18, child: _deco(120, 0.08)),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildEmblem(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to EduPlay',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Sign in to manage your children and track their progress.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Actions: side by side, same height
                          Row(
                            children: [
                              Expanded(
                                child: _CardButton(
                                  label: 'Login',
                                  icon: Icons.arrow_forward_rounded,
                                  filled: true,
                                  onTap: _login,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _CardButton(
                                  label: 'Register',
                                  filled: false,
                                  onTap: _register,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A static emblem for the logged-out card — no user/avatar data is read here.
  Widget _buildEmblem() {
    const double size = 56;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: const Icon(
        Icons.family_restroom_rounded,
        color: Colors.white,
        size: 30,
      ),
    );
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
  final IconData? icon; // optional trailing icon
  final bool filled;
  final VoidCallback onTap;

  const _CardButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.primary : AppColors.white;

    return Material(
      color: filled ? AppColors.white : Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(12),
      elevation: filled ? 2 : 0,
      shadowColor: Colors.black.withOpacity(0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: Colors.white.withOpacity(0.75), width: 1.2),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: fg,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4),
                  Icon(icon, size: 15, color: fg),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

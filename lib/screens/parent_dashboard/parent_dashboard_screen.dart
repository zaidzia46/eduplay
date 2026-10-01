import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eduplay/widgets/bg.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/action_tile.dart';
import '../../widgets/recent_act_tile.dart';
import '../../widgets/staggered_anime.dart';
import '../../widgets/title_row.dart';
import '../parent_settings/parent_settings_bin.dart';
import '../parent_settings/parent_settings_screen.dart';
import '../profile/widgets/skeleton_card_loader.dart';
import '../profile/widgets/welcome_bg_parent_dashboard.dart';
import 'parent_dashboard_controller.dart';
import 'widgets/parent_child_card.dart';

class ParentDashboardView extends StatefulWidget {
  const ParentDashboardView({super.key});

  @override
  State<ParentDashboardView> createState() => _ParentDashboardViewState();
}

class _ParentDashboardViewState extends State<ParentDashboardView>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<ParentDashboardController>();

  late final AnimationController _staggerController;
  late final Worker _worker;

  String? _precachedKey;
  Future<void>? _precacheFuture;

  // Roster signature (child ids) the stagger animation last played for. A
  // background refresh re-emits `children` with the same roster but updated
  // counters; replaying the entrance animation on that just flickers the list
  // (fade out / fade in), so we only re-stagger when the roster really changes.
  String _rosterKey = '';

  String get _currentRosterKey =>
      controller.children.map((c) => c.id).join(',');

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _rosterKey = _currentRosterKey;
    _worker = ever(controller.children, (_) {
      final key = _currentRosterKey;
      if (key == _rosterKey) return;
      _rosterKey = key;
      _staggerController
        ..reset()
        ..forward();
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _worker.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _precacheAvatars() {
    final urls = controller.children
        .map((c) => controller.avatarUrlByChild[c.id])
        .whereType<String>()
        .toSet();

    return Future.wait(
      urls.map(
        (url) => precacheImage(
          CachedNetworkImageProvider(url),
          context,
        ).catchError((_) {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.primaryDark,
      body: SoftBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildHeader(),
                const SizedBox(height: 10),
                _buildChildrenSection(),
                const SizedBox(height: 4),
                _buildManageSection(),
                const SizedBox(height: 12),
                _buildRecentActivity(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OpenContainer(
            transitionDuration: const Duration(milliseconds: 600),
            transitionType: ContainerTransitionType.fade,
            closedElevation: 0,
            openElevation: 0,
            closedColor: Colors.transparent,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            openShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            closedBuilder: (context, openContainer) {
              return Obx(() {
                return WelcomeBackground(
                  welcomeText: 'Welcome',
                  userName: controller.session.parentName.value ?? 'Guardian',
                  subtitleText: "Here's how your family is doing today.",
                );
              });
            },
            openBuilder: (context, _) {
              ParentSettingsBinding().dependencies();
              return ParentSettingsView();
            },
          ),
          const SizedBox(height: 12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                    value: '${controller.children.length}',
                    label: 'Children',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryTile(
                    icon: Icons.star_rounded,
                    color: AppColors.star,
                    value: '${controller.totalStars.value}',
                    label: 'Total Stars',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleRow(title: 'Your Children', onTap: controller.manageChildren),
          const SizedBox(height: 2),
          Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox(
                height: 300,
                child: ProfileCardSkeletonList(),
              );
            }

            if (controller.errorMessage.isNotEmpty) {
              return _buildChildrenError();
            }

            if (controller.children.isEmpty) {
              return const SizedBox.shrink();
            }

            // Recompute only when the (child, avatarUrl) pairs actually change.
            final key = controller.children
                .map((c) => '${c.id}:${controller.avatarUrlByChild[c.id]}')
                .join(',');
            if (_precachedKey != key) {
              _precachedKey = key;
              _precacheFuture = _precacheAvatars();
            }

            return FutureBuilder<void>(
              future: _precacheFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 300,
                    child: ProfileCardSkeletonList(),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.children.length,
                    itemBuilder: (context, index) {
                      final child = controller.children[index];
                      return StaggeredAnimation(
                        controller: _staggerController,
                        index: index,
                        child: ParentChildCard(
                          child: child,
                          stars: controller.starsByChild[child.id] ?? 0,
                          streak: controller.streakByChild[child.id] ?? 0,
                          avatarUrl: controller.avatarUrlByChild[child.id],
                          onContinue: () => controller.continueLearning(child),
                          onViewProgress: () => controller.viewProgress(child),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChildrenError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            controller.errorMessage.value,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: controller.switcher.fetchChildren,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          ActionTile(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add a Child',
            subtitle: 'Create a new learner profile',
            color: AppColors.primary,
            onTap: controller.addChild,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      if (controller.recentActivity.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...controller.recentActivity.map(
              (item) => _FamilyActivityTile(item: item),
            ),
          ],
        ),
      );
    });
  }
}

/// A recent-activity row tagged with the child's name. Reuses the existing
/// [RecentActivityTile] verbatim and prepends a small child-name label, since
/// the shared tile has no per-child field.
class _FamilyActivityTile extends StatelessWidget {
  final FamilyActivity item;

  const _FamilyActivityTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.childName,
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
        ),
        RecentActivityTile(activity: item.activity),
      ],
    );
  }
}

/// A single family-summary stat, shown below the header card. Matches the app's
/// white card aesthetic (rounded, bordered) with a tinted leading icon.
class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _SummaryTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

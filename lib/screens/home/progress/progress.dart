import 'package:eduplay/screens/home/progress/progress_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/activity_breakdown_card.dart';
import '../../../widgets/morphing_progress_indicator.dart';
import '../../../widgets/recent_act_tile.dart';
import '../../../widgets/staggered_anime.dart';
import '../../../widgets/stat_chip.dart';
import '../../../routes/app_routes.dart';
import '../subjects/subjects_model.dart';
import 'widgets/progress_skeleton.dart';
import 'widgets/subject_progress_tile.dart';
import '../bottom_nav/bottomNavigation_controller.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late final ScrollController _scrollController;
  final ValueNotifier<double> _morphT = ValueNotifier(0);
  late final Worker _tabWorker;
  late final Worker _loadingWorker;
  bool _hasAnimated = false;

  static const double _maxMorphDistance = 140;

  double get _effectiveMorphDistance {
    if (!_scrollController.hasClients) return _maxMorphDistance;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return _maxMorphDistance;
    return maxExtent < _maxMorphDistance ? maxExtent : _maxMorphDistance;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final vm = Get.find<ProgressController>();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _controller.forward();
    _scrollController = ScrollController()..addListener(_handleScroll);

    _loadingWorker = ever(vm.isLoading, (isLoading) {
      if (!isLoading && !_hasAnimated) {
        _controller.forward(from: 0);
        _hasAnimated = true;
      }
    });

    if (!vm.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasAnimated) {
          _controller.forward(from: 0);
          _hasAnimated = true;
        }
      });
    }

    _tabWorker = ever(Get.find<BottomNavController>().currentIndex, (index) {
      if (index == 2) {
        vm.reload();
        _controller.forward(from: 0);
      }
    });
  }

  void _handleScroll() {
    final distance = _effectiveMorphDistance;
    if (distance <= 0) {
      _morphT.value = 0;
      return;
    }
    final offset = _scrollController.offset.clamp(0.0, distance);
    _morphT.value = offset / distance;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _morphT.dispose();
    _tabWorker.dispose();
    _loadingWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = Get.find<ProgressController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // An error only blocks the whole screen when there's nothing to show
        // yet; background-refresh failures keep existing data (see controller).
        if (vm.errorMessage.isNotEmpty && vm.overview.value == null) {
          return Center(
            child: Text(vm.errorMessage.value, style: AppTextStyles.body),
          );
        }

        // First load: the page chrome and the Stars / Day Streak tiles render
        // for real (instant from the cached child); only the fetched sections
        // — ring, breakdown, subjects, recent activity — show skeletons.
        final loading = vm.isLoading.value;
        final overview = vm.overview.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: Image.asset('assets/images/progress_bg.png'),
                ),
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Overall Progress',
                                style: AppTextStyles.sectionHeader,
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  loading
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: ProgressRingSkeleton(),
                                        )
                                      : ValueListenableBuilder<double>(
                                          valueListenable: _morphT,
                                          builder: (context, t, _) {
                                            return Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                MorphingProgressIndicator(
                                                  percent:
                                                      (overview?.overallPercent ??
                                                              0)
                                                          .toDouble(),
                                                  t: t,
                                                  circleDiameter: 100,
                                                  strokeWidth: 10,
                                                  trackColor:
                                                      AppColors.primarySurface,
                                                  progressColor:
                                                      AppColors.primary,
                                                  bubbleColor:
                                                      AppColors.primaryDark,
                                                ),
                                                Opacity(
                                                  opacity: (1 - t * 2).clamp(
                                                    0.0,
                                                    1.0,
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '${overview?.overallPercent ?? 0}%',
                                                        style: AppTextStyles.h2,
                                                      ),
                                                      Text(
                                                        'Overall',
                                                        style: AppTextStyles
                                                            .caption,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                  const SizedBox(height: 20),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: StatChip.stars(
                                              value: '${vm.starsEarned}',
                                              label: 'Stars Earned',
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: StatChip.streak(
                                              value: '${vm.dayStreak}',
                                              label: 'Day Streak',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      loading
                          ? const ActivityBreakdownSkeleton()
                          : ActivityBreakdownCard(
                              categories: vm.activityBreakdown,
                            ),

                      if (loading) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Subjects',
                            style: AppTextStyles.sectionHeader,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SubjectListSkeleton(),
                      ] else if (overview != null &&
                          overview.subjects.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Subjects',
                            style: AppTextStyles.sectionHeader,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(overview.subjects.length, (index) {
                          final subject = overview.subjects[index];
                          return StaggeredAnimation(
                            controller: _controller,
                            index: index,
                            child: SubjectProgressTile(
                              subject: subject,
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.chapters,
                                  arguments: {
                                    'subject': SubjectModel(
                                      id: subject.subjectId,
                                      standardSubjectId:
                                          subject.standardSubjectId,
                                      name: subject.name,
                                      colorHex: subject.color,
                                      iconPath: subject.iconPath,
                                      progressPercent: subject.percent,
                                    ),
                                  },
                                );
                              },
                            ),
                          );
                        }),
                      ],

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Activity',
                            style: AppTextStyles.sectionHeader,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (loading)
                        const RecentActivityListSkeleton()
                      else
                        ...List.generate(
                          vm.recentActivity.length,
                          (index) => StaggeredAnimation(
                            controller: _controller,
                            index: index,
                            child: RecentActivityTile(
                              activity: vm.recentActivity[index],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

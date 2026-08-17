import 'package:eduplay/screens/home/subjects/widgets/subject_progress_row_skeleton.dart';
import 'package:eduplay/widgets/circular_loader.dart';
import 'package:eduplay/widgets/subject_progress_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/empty_search.dart';
import '../../../widgets/staggered_anime.dart';
import '../bottom_nav/bottomNavigation_controller.dart';
import '../dashboard/dashboard_controller.dart';

class SubjectView extends StatefulWidget {
  const SubjectView({super.key});

  @override
  State<SubjectView> createState() => _SubjectViewState();
}

class _SubjectViewState extends State<SubjectView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late final Worker _tabWorker;
  late final Worker _loadingWorker;
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final vm = Get.find<DashboardController>();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // fire once data finishes loading (covers first load)
    _loadingWorker = ever(vm.isSubjectsLoading, (isLoading) {
      if (!isLoading && !_hasAnimated) {
        _controller.forward(from: 0);
        _hasAnimated = true;
      }
    });

    // if data was already loaded before this screen was built, catch that case
    if (!vm.isSubjectsLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasAnimated) {
          _controller.forward(from: 0);
          _hasAnimated = true;
        }
      });
    }

    // replay stagger every time user comes back to this tab
    _tabWorker = ever(Get.find<BottomNavController>().currentIndex, (index) {
      if (index == 1 && !vm.isSubjectsLoading.value) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _tabWorker.dispose();
    _loadingWorker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final vm = Get.find<DashboardController>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Image.asset('assets/images/subjects_bg.png'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: vm.searchController,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search subjects...',
                        hintStyle: AppTextStyles.bodySecondary,
                        filled: true,
                        fillColor: AppColors.primarySurface,
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primary,
                        ),
                        // Show clear button when typing
                        suffixIcon: Obx(
                          () => vm.searchQuery.value.isNotEmpty
                              ? GestureDetector(
                                  onTap: vm.clearSearch,
                                  child: Icon(
                                    Icons.close,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Obx(() {
                  final isActive = vm.activeFilter.value != SubjectFilter.all;
                  return GestureDetector(
                    onTap: vm.showFilterSheet,
                    child: Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primarySurface
                                : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.filter_alt_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        if (isActive)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subjects', style: AppTextStyles.sectionHeader),
                Obx(
                  () => vm.filteredSubjects.length > 1
                      ? Text(
                          '${vm.filteredSubjects.length} Subjects',
                          style: AppTextStyles.sectionLink,
                        )
                      : Text(
                          '${vm.filteredSubjects.length} Subject',
                          style: AppTextStyles.sectionLink,
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Obx(() {
              if (vm.isSubjectsLoading.value) {
                return Center(child: SubjectProgressRowSkeleton());
              }

              if (vm.filteredSubjects.isEmpty) {
                return EmptySearch(
                  query: vm.searchQuery.value,
                  filter: vm.activeFilter.value,
                );
              }

              return ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: vm.filteredSubjects.length,
                itemBuilder: (context, index) {
                  final subject = vm.filteredSubjects[index];
                  return StaggeredAnimation(
                    controller: _controller,
                    index: index,
                    child: SubjectProgressRow(
                      subject: subject,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.topics,
                          arguments: {'subject': subject},
                        );
                      },
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

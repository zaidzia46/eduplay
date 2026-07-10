import 'dart:developer';

import 'package:eduplay/widgets/circular_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../models/subjects_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/empty_search.dart';
import '../../../widgets/staggered_anime.dart';
import '../../../widgets/subject_tile.dart';
import '../bottom_nav/bottomNavigation_controller.dart';
import '../dashboard/dashboard_controller.dart';

class SubjectView extends StatefulWidget {
  const SubjectView({super.key});

  @override
  State<SubjectView> createState() => _SubjectViewState();
}

class _SubjectViewState extends State<SubjectView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    ever(Get.find<BottomNavController>().currentIndex, (index) {
      if (index == 1) {
        _controller.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Image.asset('assets/images/subjects_banner.png'),
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
                      decoration: InputDecoration(
                        hintText: 'Search subjects...',
                        hintStyle: AppTextStyles.bodySecondary,
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

                // Filter button
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Subjects', style: AppTextStyles.sectionHeader),
                Obx(
                  () => Text(
                    '${vm.filteredSubjects.length} Subjects',
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
                return Center(child: CircularLoader());
              }

              if (vm.filteredSubjects.isEmpty) {
                return EmptySearch(query: vm.searchQuery.value);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: vm.filteredSubjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return StaggeredAnimation(
                    controller: _controller,
                    index: index,
                    child: SubjectTile(subject: vm.filteredSubjects[index]),
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

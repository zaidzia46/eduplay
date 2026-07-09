import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/subjects_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../dashboard/dashboard_controller.dart';

class SubjectView extends StatelessWidget {
  const SubjectView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Purple header ─────────────────────────────────
          _SubjectHeader(),

          // ── Search bar ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: Container(
                    height: 50,
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

          // ── Section title ─────────────────────────────────
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
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.filteredSubjects.isEmpty) {
                return _EmptySearch(query: vm.searchQuery.value);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: vm.filteredSubjects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _SubjectTile(subject: vm.filteredSubjects[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Purple header ─────────────────────────────────────────────────────────────
class _SubjectHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subjects',
                      style: AppTextStyles.display.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Explore, learn and grow\nwith your favourite subjects',
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              // Illustration
              Image.asset(
                'assets/images/subjects_header.png',
                height: 120,
                errorBuilder: (_, __, ___) => const SizedBox(height: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subject tile ──────────────────────────────────────────────────────────────
class _SubjectTile extends StatelessWidget {
  final SubjectsModel subject;

  const _SubjectTile({required this.subject});

  @override
  Widget build(BuildContext context) {
    // Check if subject has progress (comes from continueLearning list)
    // For now progress is 0 — wire to real data later
    final int progress = subject.progressPercent ?? 0;
    final bool hasStarted = progress > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Subject image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: subject.buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                subject.imageUrl,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.book_rounded,
                  color: subject.buttonColor,
                  size: 32,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Title + lessons + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject.title, style: AppTextStyles.h4),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 13,
                      color: subject.buttonColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${subject.lessonCount} Lessons',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: subject.buttonColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subject.description ?? '',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Progress bar — only if started
                if (hasStarted) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 5,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              subject.buttonColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$progress%',
                        style: AppTextStyles.caption.copyWith(
                          color: subject.buttonColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Start / Continue button
          Column(
            children: [
              SizedBox(
                width: 90,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subject.buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    hasStarted ? 'Continue' : 'Start',
                    style: AppTextStyles.buttonMedium.copyWith(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Empty search state ────────────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No results for "$query"', style: AppTextStyles.h4),
          const SizedBox(height: 6),
          Text(
            'Try searching with a different word.',
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ),
    );
  }
}

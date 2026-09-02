import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../widgets/topic_card.dart';
import '../../../../widgets/topics_banner_background.dart';
import '../widgets/chp_skeleton_loader.dart';
import 'chapter_controller.dart';

class ChapterScreen extends StatelessWidget {
  ChapterScreen({super.key});

  final vm = Get.find<ChapterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: vm.subject.colorHex,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            decoration: BoxDecoration(
                              color: vm.subject.colorHex.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vm.subject.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                                Text(
                                  "Let's start learning!",
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 90,
                            child: vm.subject.iconPath != null
                                ? Image.asset(
                                    'assets/images/${vm.subject.iconPath}',
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: Obx(() {
                        if (vm.isLoading.value) {
                          return ChapterListSkeleton(itemCount: 3);
                        }

                        if (vm.error.value.isNotEmpty) {
                          return Center(child: Text(vm.error.value));
                        }

                        return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: vm.chapters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final chapter = vm.chapters[index];

                            return TopicCard(
                              topic: chapter,
                              accentColor: vm.subject.colorHex,
                              onTap: () async {
                                // Wait for the quiz list (and any quiz played
                                // from it) to pop, then refresh just the
                                // progress so this chapter's bar is current.
                                await Get.toNamed(
                                  AppRoutes.quizList,
                                  arguments: {
                                    'chapterId': chapter.id,
                                    'chapterTitle': chapter.title,
                                    'accentColor': vm.subject.colorHex,
                                  },
                                );
                                vm.refreshProgress();
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: TopicBannerBackground(
                startColor: vm.subject.colorHex.withOpacity(0.5),
                endColor: vm.subject.colorHex.withOpacity(0.5),
                starColor: vm.subject.colorHex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

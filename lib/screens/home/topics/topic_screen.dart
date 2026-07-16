import 'package:eduplay/screens/home/topics/topic_controller.dart';
import 'package:eduplay/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../theme/app_text_styles.dart';
import '../../../widgets/circular_loader.dart';
import '../../../widgets/topic_card.dart';
import '../../../widgets/topics_banner_background.dart';

class TopicScreen extends StatelessWidget {
  TopicScreen({super.key});

  final vm = Get.find<TopicController>();

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
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: vm.subject.buttonColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            decoration: BoxDecoration(
                              color: vm.subject.buttonColor.withOpacity(0.5),
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
                                  vm.subject.subjectTitle,
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

                          // Expanded(
                          //   child: RichText(
                          //     text: TextSpan(
                          //       children: [
                          //         TextSpan(
                          //           text: vm.subject.subjectTitle,
                          //           style: AppTextStyles.h2.copyWith(
                          //             color: AppColors.white,
                          //           ),
                          //         ),
                          //         TextSpan(
                          //           text: "\nLet's start learning!",
                          //           style: AppTextStyles.caption.copyWith(
                          //             color: Colors.white,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(width: 10),

                          SizedBox(
                            width: 90,
                            child: Image.asset(
                              'assets/images/${vm.subject.imageUrl}',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Expanded(
                      child: Obx(() {
                        if (vm.isLoading.value) {
                          return Center(child: CircularLoader());
                        }

                        if (vm.error.value.isNotEmpty) {
                          return Center(child: Text(vm.error.value));
                        }

                        return ListView.separated(
                          itemCount: vm.topics.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final topic = vm.topics[index];

                            final colors = [
                              Color(0xffF3E8FF),
                              Color(0xffDCFCE7),
                              Color(0xffDBEAFE),
                              Color(0xffFDE68A),
                              Color(0xffFCE7F3),
                            ];
                            return TopicCard(
                              topic: topic,
                              // CardtColor: colors[index % colors.length],
                              accentColor: vm.subject.buttonColor,
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
                startColor: vm.subject.buttonColor.withOpacity(0.3),
                endColor: vm.subject.buttonColor.withOpacity(0.5),
                starColor: vm.subject.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

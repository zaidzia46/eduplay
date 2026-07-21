// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
//
// import '../../../theme/app_colors.dart';
// import '../../../theme/app_text_styles.dart';
// import '../../../widgets/circular_loader.dart';
// import '../../../widgets/recent_act_tile.dart';
// import '../../../widgets/stat_tile.dart';
// import '../../../widgets/subject_progress_row.dart';
// import 'child_detail_controller.dart';
//
// class ChildDetailView extends StatelessWidget {
//   const ChildDetailView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = Get.find<ChildDetailController>();
//     bool parentDashboard = true;
//
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
//           onPressed: () => Get.back(),
//         ),
//         title: Text("${vm.child.name}'s Progress", style: AppTextStyles.h3),
//       ),
//       body: Obx(() {
//         if (vm.isLoading.value) {
//           return Center(child: CircularLoader());
//         }
//
//         if (vm.errorMessage.isNotEmpty) {
//           return Center(
//             child: Text(vm.errorMessage.value, style: AppTextStyles.body),
//           );
//         }
//
//         final stats = vm.stats.value;
//
//         return SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Overall Progress',
//                       style: AppTextStyles.sectionHeader,
//                     ),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: 100,
//                       height: 100,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           SizedBox(
//                             width: 100,
//                             height: 100,
//                             child: CircularProgressIndicator(
//                               value: (stats?.overallPercent ?? 0) / 100,
//                               strokeWidth: 10,
//                               strokeCap: StrokeCap.round,
//                               backgroundColor: AppColors.primarySurface,
//                               valueColor: const AlwaysStoppedAnimation<Color>(
//                                 AppColors.primary,
//                               ),
//                             ),
//                           ),
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 '${stats?.overallPercent ?? 0}%',
//                                 style: AppTextStyles.h2,
//                               ),
//                               Text('Overall', style: AppTextStyles.caption),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: StatTile(
//                             icon: const FaIcon(
//                               FontAwesomeIcons.solidStar,
//                               size: 20,
//                               color: AppColors.star,
//                             ),
//                             color: AppColors.star,
//                             value: '${stats?.starsEarned ?? 0}',
//                             label: 'Stars Earned',
//                           ),
//                         ),
//                         Expanded(
//                           child: StatTile(
//                             icon: const FaIcon(
//                               FontAwesomeIcons.bookOpen,
//                               size: 20,
//                               color: AppColors.tertiary,
//                             ),
//                             color: AppColors.tertiary,
//                             value: '${stats?.lessonsCompleted ?? 0}',
//                             label: 'Lessons Completed',
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 14),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: StatTile(
//                             icon: const FaIcon(
//                               FontAwesomeIcons.calendarCheck,
//                               size: 20,
//                               color: AppColors.success,
//                             ),
//                             color: AppColors.success,
//                             value: '${stats?.daysActive ?? 0}',
//                             label: 'Days Active',
//                           ),
//                         ),
//                         Expanded(
//                           child: StatTile(
//                             icon: const FaIcon(
//                               FontAwesomeIcons.award,
//                               size: 20,
//                               color: AppColors.error,
//                             ),
//                             color: AppColors.error,
//                             value: '${stats?.badgesEarned ?? 0}',
//                             label: 'Badges Earned',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//               Text('Subject Progress', style: AppTextStyles.sectionHeader),
//               const SizedBox(height: 12),
//               ...vm.subjects.map((s) => SubjectProgressRow(subject: s)),
//
//               const SizedBox(height: 12),
//               Text('Recent Activity', style: AppTextStyles.sectionHeader),
//               const SizedBox(height: 12),
//               ...vm.recentActivity.map((a) => RecentActivityTile(activity: a)),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }

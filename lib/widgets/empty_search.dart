import 'package:flutter/material.dart';

import '../screens/home/dashboard/dashboard_controller.dart';
import '../theme/app_text_styles.dart';

class EmptySearch extends StatelessWidget {
  final String query;
  final SubjectFilter filter;

  const EmptySearch({required this.query, required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: query.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No results for "$query"', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                Text(
                  'Try searching with a different word.',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            )
          : filter == SubjectFilter.all
          ? Text('No subjects yet!', style: AppTextStyles.h4)
          : filter == SubjectFilter.inProgress
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No subjects in progress yet!', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                Text(
                  "Start a subject to see it here.",
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            )
          : filter == SubjectFilter.notStarted
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('All subjects have been started', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                Text("You're doing great.", style: AppTextStyles.bodySecondary),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No subjects completed yet!', style: AppTextStyles.h4),
                const SizedBox(height: 6),
                Text(
                  "Hopefully, you'll complete some soon.",
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
    );
  }
}

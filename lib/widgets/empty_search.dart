import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class EmptySearch extends StatelessWidget {
  final String query;

  const EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

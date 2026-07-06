import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/continue_learning.dart';

class LessonRepository {
  Future<List<ContinueLearningModel>> getContinueLearning({
    int? standard,
  }) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/continue_learning.json',
      );
      final Map<String, dynamic> json = jsonDecode(response);
      final List items = json['data']['items'];
      return items.map((item) => ContinueLearningModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load continue learning: $e');
    }
  }
}

import 'dart:convert';
import 'package:eduplay/controller/session_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../models/activity_category_model.dart';

class ActivityBreakdownRepository {
  // Right now: loads activity_breakdown.json — already organized per
  // child, no client-side computation needed. Later: replace this
  // method body with a single http.get('/progress/activity-breakdown');
  // the backend sends the same shape directly.
  //
  // `childId` defaults to the active session child if not passed.
  Future<List<ActivityCategoryModel>> getBreakdown({int? childId}) async {
    final resolvedChildId =
        childId ?? Get.find<SessionController>().activeChild.value?.id;

    final String response = await rootBundle.loadString(
      'assets/data/activity_breakdown.json',
    );
    final Map<String, dynamic> json = jsonDecode(response);
    final Map<String, dynamic> breakdownByChild = json['data']['breakdown'];
    final List categories = resolvedChildId == null
        ? []
        : (breakdownByChild['$resolvedChildId'] ?? []);

    return categories.map((c) => ActivityCategoryModel.fromJson(c)).toList();
  }

  // When backend is ready, replace with this:
  // Future<List<ActivityCategoryModel>> getBreakdown({int? childId}) async {
  //   final response = await dio.get('/progress/activity-breakdown');
  //   final List categories = response.data['data']['breakdown'];
  //   return categories.map((c) => ActivityCategoryModel.fromJson(c)).toList();
  // }
}

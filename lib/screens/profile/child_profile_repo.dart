import 'dart:convert';
import 'package:flutter/services.dart';

import '../../models/child_profile_model.dart';

class ChildProfileRepository {
  // Right now: loads from local JSON asset.
  // Later: replace this method body with an http.get('/parent/children') —
  // no parentId param needed, the backend infers it from the auth token,
  // same reasoning as standardId being inferred from the active profile.
  Future<List<ChildProfileModel>> getChildren() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/child_profiles.json',
      );
      final Map<String, dynamic> json = jsonDecode(response);
      final List children = json['data']['children'];
      return children.map((item) => ChildProfileModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load child profiles: $e');
    }
  }

  // When backend is ready, replace with this:
  // Future<List<ChildProfileModel>> getChildren() async {
  //   final response = await dio.get('/parent/children');
  //   final List children = response.data['data']['children'];
  //   return children.map((item) => ChildProfileModel.fromJson(item)).toList();
  // }
}

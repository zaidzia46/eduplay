import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/standards_model.dart';

class StandardRepository {
  // ── Right now: loads from local JSON asset ──────────────
  // ── Later: replace this method body with an http.get() ──
  Future<List<StandardModel>> getStandards({int? standard}) async {
    try {
      // Load local JSON
      final String response = await rootBundle.loadString(
        'assets/data/standards.json',
      );
      final Map<String, dynamic> json = jsonDecode(response);

      final List subjects = json['data']['subjects'];
      return subjects.map((item) => StandardModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }
}

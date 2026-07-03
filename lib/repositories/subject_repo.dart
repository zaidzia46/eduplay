import 'dart:convert';
import 'dart:developer';
import 'package:flutter/services.dart';
import '../models/subjects_model.dart';

class SubjectRepository {
  // ── Right now: loads from local JSON asset ──────────────
  // ── Later: replace this method body with an http.get() ──
  Future<List<SubjectsModel>> getSubjects() async {
    try {
      // Load local JSON
      final String response = await rootBundle.loadString(
        'assets/data/subjects.json',
      );
      final Map<String, dynamic> json = jsonDecode(response);

      final List subjects = json['data']['subjects'];
      return subjects.map((item) => SubjectsModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load subjects: $e');
    }
  }

  // ── When backend is ready, replace with this: ───────────
  // Future<List<SubjectModel>> getSubjects() async {
  //   final response = await http.get(Uri.parse('$baseUrl/subjects'));
  //   if (response.statusCode == 200) {
  //     final json = jsonDecode(response.body);
  //     final List subjects = json['data']['subjects'];
  //     return subjects.map((item) => SubjectModel.fromJson(item)).toList();
  //   }
  //   throw Exception('Failed to load subjects');
  // }
}

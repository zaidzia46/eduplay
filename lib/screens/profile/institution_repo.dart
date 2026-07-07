import 'dart:convert';
import 'package:flutter/services.dart';

import '../../models/institution_model.dart';

class InstitutionRepository {
  // Right now: loads from local JSON asset.
  // Later: replace this method body with an http.get(), likely with a
  // `search` param, since a real institutions list is far too large for
  // a wheel picker or a single unfiltered request. Keep it flat until then.
  Future<List<InstitutionModel>> getInstitutions({String? search}) async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/institutions.json',
      );
      final Map<String, dynamic> json = jsonDecode(response);
      final List institutions = json['data']['institutions'];

      var result = institutions
          .map((item) => InstitutionModel.fromJson(item))
          .toList();

      if (search != null && search.trim().isNotEmpty) {
        final query = search.trim().toLowerCase();
        result = result
            .where((i) => i.name.toLowerCase().contains(query))
            .toList();
      }

      return result;
    } catch (e) {
      throw Exception('Failed to load institutions: $e');
    }
  }

  // When backend is ready, replace with this:
  // Future<List<InstitutionModel>> getInstitutions({String? search}) async {
  //   final response = await dio.get(
  //     '/institutions',
  //     queryParameters: search != null ? {'search': search} : null,
  //   );
  //   final List institutions = response.data['data']['institutions'];
  //   return institutions.map((item) => InstitutionModel.fromJson(item)).toList();
  // }
}

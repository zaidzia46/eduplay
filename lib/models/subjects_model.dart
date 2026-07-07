import 'package:flutter/material.dart';

import '../fns/hexToColor.dart';

class SubjectsModel {
  final int id;
  final String subjectTitle;
  final String imageUrl;
  final Color buttonColor;

  SubjectsModel({
    required this.id,
    required this.subjectTitle,
    required this.imageUrl,
    required this.buttonColor,
  });

  factory SubjectsModel.fromJson(Map<String, dynamic> json) {
    return SubjectsModel(
      id: json['id'],
      subjectTitle: json['title'],
      imageUrl: json['image_url'],
      buttonColor: hexToColor(json['button_color']),
    );
  }
}

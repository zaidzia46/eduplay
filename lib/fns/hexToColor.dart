import 'dart:ui';

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', '');
  if (hex.length == 6) hex = 'FF$hex'; // add opacity
  return Color(int.parse(hex, radix: 16));
}

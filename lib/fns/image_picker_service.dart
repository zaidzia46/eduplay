import 'dart:developer';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static Future<String?> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );

    log("Picked Path: ${picked?.path}");

    return picked?.path;
  }
}

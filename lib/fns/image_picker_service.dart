import 'dart:developer';

import 'package:image_picker/image_picker.dart';

import 'image_cropper.dart';

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

  /// Picks an image and then lets the user crop it to a square avatar.
  ///
  /// Returns the cropped file path, or `null` if the user cancels either the
  /// picker or the crop step (both count as "no image chosen", so callers can
  /// keep their existing `if (path == null) return;` guard).
  static Future<String?> pickAndCropImage(ImageSource source) async {
    final pickedPath = await pickImage(source);
    if (pickedPath == null) return null;
    return cropAvatar(pickedPath);
  }
}

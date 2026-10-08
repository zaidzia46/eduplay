import 'package:image_cropper/image_cropper.dart';

Future<String?> cropAvatar(String sourcePath) async {
  final cropped = await ImageCropper().cropImage(
    sourcePath: sourcePath,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // square for a DP
    compressFormat: ImageCompressFormat.png,
    maxWidth: 1024,
    maxHeight: 1024,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop photo',
        lockAspectRatio: true,
        hideBottomControls: false,
      ),
      IOSUiSettings(
        title: 'Crop photo',
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ],
  );
  return cropped?.path; // null if the user taps Cancel
}

import 'package:dio/dio.dart';

import '../../core/api_client.dart';

class ParentRepository {
  Future<String> uploadAvatar(String filePath) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath),
    });

    final response = await ApiClient.instance.post(
      '/api/v1/parent/avatar',
      data: formData,
    );

    return response.data['data']['avatar_path'];
  }
}

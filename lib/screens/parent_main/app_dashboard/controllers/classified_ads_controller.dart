import 'dart:developer';

import 'package:get/get.dart';

import '../models/classified_ad_model.dart';
import '../repo/classified_ads_repo.dart';

class ClassifiedAdsController extends GetxController {
  final ClassifiedAdsRepository _repo = ClassifiedAdsRepository();

  final ads = <ClassifiedAdModel>[].obs;
  final isLoading = true.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  Future<void> fetchAds() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      ads.value = await _repo.getActiveAds();
    } catch (_) {
      errorMessage.value = 'Could not load ads.';
    } finally {
      isLoading.value = false;
    }
  }
}

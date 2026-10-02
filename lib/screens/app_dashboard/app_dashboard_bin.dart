import 'package:get/get.dart';

import 'classified_ads_controller.dart';

/// The App Dashboard is the public, logged-out landing screen. It shows static
/// content (logo, welcome/login card, promo banner) plus the classified ads.
///
/// It must work with no Supabase user, so the only controller registered here
/// fetches PUBLIC, non-user data — the classified ads, via an anon SELECT.
/// Nothing user-specific is created just by opening the app.
class AppDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClassifiedAdsController>(() => ClassifiedAdsController());
  }
}

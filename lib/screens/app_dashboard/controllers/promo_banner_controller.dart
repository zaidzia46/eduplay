import 'package:get/get.dart';

import '../../../fns/image_constant.dart';

/// State for the App Dashboard promo carousel: the banner images and which page
/// is currently showing. Lives outside the widget so the active-dot indicator
/// reacts through GetX instead of `setState`.
class PromoBannerController extends GetxController {
  final List<String> banners = const [
    ImageConstant.appDashboardBanner1,
    ImageConstant.appDashboardBanner2,
    ImageConstant.appDashboardBanner3,
  ];

  final currentIndex = 0.obs;

  void onPageChanged(int index) => currentIndex.value = index;
}

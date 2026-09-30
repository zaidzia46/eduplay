import 'package:get/get.dart';

/// The App Dashboard is the public, logged-out landing screen. It shows only
/// static content (logo, welcome/login card, promo banner, classifieds) and
/// must work with no Supabase user or child profile, so it registers no
/// controllers — nothing user-specific is created just by opening the app.
class AppDashboardBinding extends Bindings {
  @override
  void dependencies() {}
}

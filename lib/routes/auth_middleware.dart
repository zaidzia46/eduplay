import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/supabase_client.dart';
import 'app_routes.dart';

/// Route guard for user-specific screens.
///
/// [redirect] is evaluated by GetX during route resolution — *before* the
/// target page's binding runs (and therefore before any controller `onInit`
/// issues a Supabase read). A logged-out user is bounced to the public shell
/// (its landing tab), so a protected screen can never fire a database request
/// first and only then discover there is no session.
///
/// Note this guards standalone *routes* only. Screens that live inside the
/// public shell (`/parent-home`) are gated per-tab by
/// [ParentBottomNavController] instead — see `sign_in_prompt.dart`.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final loggedIn = supabase.auth.currentSession != null;
    return loggedIn ? null : const RouteSettings(name: AppRoutes.parentHome);
  }
}

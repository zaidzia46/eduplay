import 'package:get/get.dart';

import '../../../core/supabase_client.dart';
import '../../../widgets/sign_in_prompt.dart';

class ParentBottomNavController extends GetxController {
  /// Tabs that need a signed-in user. Index 0 is the App Dashboard — the
  /// public, logged-out landing — and is always reachable.
  static const Set<int> _authRequiredTabs = {1, 2};

  var currentIndex = 0.obs;

  bool get isLoggedIn => supabase.auth.currentSession != null;

  /// Whether [index] may be shown right now. The whole shell lives on a public
  /// route, so `AuthGuard` can't protect it — this is the gate.
  bool canOpen(int index) =>
      !_authRequiredTabs.contains(index) || isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['initialTab'] is int) {
      final tab = args['initialTab'] as int;
      // A gated tab requested while signed out (say a stale deep link) falls
      // back to the public landing tab rather than exposing the screen.
      currentIndex.value = canOpen(tab) ? tab : 0;
    }
  }

  void changePage(int index) {
    if (!canOpen(index)) {
      showSignInPrompt();
      return; // leave the user on the tab they were already viewing
    }
    currentIndex.value = index;
  }
}

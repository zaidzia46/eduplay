import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/standards_model.dart';

class SessionController extends GetxController {
  var currentStandard = Rxn<StandardModel>();
  static const _key = 'currentStandard';

  @override
  void onInit() {
    super.onInit();
    final saved = GetStorage().read(_key);
    if (saved != null) currentStandard.value = StandardModel.fromJson(saved);
  }

  Future<void> setCurrentStandard(StandardModel standard) async {
    currentStandard.value = standard;
    await GetStorage().write(_key, {
      'id': standard.id,
      'standard': standard.standard,
    });
  }

  int? get currentStandardId => currentStandard.value?.id;
}

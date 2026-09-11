import 'package:eduplay/screens/profile/create_child_profile/repo/catalog_repo.dart';
import 'package:eduplay/screens/profile/create_child_profile/repo/create_child_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../controller/session_controller.dart';
import '../../../fns/image_picker_service.dart';
import '../../../routes/app_routes.dart';
import 'models/city_model.dart';
import 'models/curriculam_option_model.dart';
import 'models/institution_model.dart';
import 'models/standard_model.dart';
import '../profile_switcher/models/child_profile_model.dart';

class CreateProfileViewModel extends GetxController {
  final CatalogRepository _catalogRepo = CatalogRepository();
  final ChildProfileRepository _childRepo = ChildProfileRepository();
  final session = Get.find<SessionController>();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  var cities = <CityModel>[].obs;
  var institutions = <InstitutionModel>[].obs;
  var curricula = <CurriculumOptionModel>[].obs;
  var standards = <StandardModel>[].obs;

  var isLoadingCities = false.obs;
  var isLoadingInstitutions = false.obs;
  var isLoadingCurricula = false.obs;
  var isLoadingStandards = false.obs;

  var selectedCity = Rxn<CityModel>();
  var selectedInstitution = Rxn<InstitutionModel>();
  var selectedCurriculum = Rxn<CurriculumOptionModel>();
  var selectedStandard = Rxn<StandardModel>();

  var profileImagePath = Rxn<String>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  /// When true this screen is being used by a guest (anonymous auth) to pick a
  /// grade before exploring. Identity fields (name/username) and the avatar are
  /// hidden and auto-filled; only the City→School→Curriculum→Grade cascade
  /// shows, and on submit we drop straight into `home` rather than the switcher.
  bool isGuest = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    isGuest = args is Map && args['guest'] == true;
    fetchCities();
  }

  Future<void> pickAvatar() async {
    final path = await ImagePickerService.pickImage(ImageSource.gallery);
    if (path != null) {
      profileImagePath.value = path;
    }
  }

  Future<void> fetchCities() async {
    try {
      isLoadingCities.value = true;
      cities.value = await _catalogRepo.getCities();
    } catch (e) {
      errorMessage.value = 'Could not load cities.';
    } finally {
      isLoadingCities.value = false;
    }
  }

  Future<void> selectCity(CityModel? city) async {
    if (city?.id == selectedCity.value?.id) return;
    selectedCity.value = city;
    _resetFrom(afterCity: true);

    if (city == null) return;
    try {
      isLoadingInstitutions.value = true;
      institutions.value = await _catalogRepo.getInstitutesByCity(city.id);
    } catch (e) {
      errorMessage.value = 'Could not load institutions.';
    } finally {
      isLoadingInstitutions.value = false;
    }
  }

  Future<void> selectInstitution(InstitutionModel? inst) async {
    selectedInstitution.value = inst;
    _resetFrom(afterInstitution: true);

    if (inst == null) return;
    try {
      isLoadingCurricula.value = true;
      curricula.value = await _catalogRepo.getCurriculaByInstitute(inst.id);
    } catch (e) {
      errorMessage.value = 'Could not load curricula.';
    } finally {
      isLoadingCurricula.value = false;
    }
  }

  Future<void> selectCurriculum(CurriculumOptionModel? curriculum) async {
    selectedCurriculum.value = curriculum;
    _resetFrom(afterCurriculum: true);

    if (curriculum == null) return;
    try {
      isLoadingStandards.value = true;
      standards.value = await _catalogRepo.getStandardsByInstituteCurricula(
        curriculum.instituteCurriculaId,
      );
    } catch (e) {
      errorMessage.value = 'Could not load grades.';
    } finally {
      isLoadingStandards.value = false;
    }
  }

  void selectStandard(StandardModel? s) => selectedStandard.value = s;

  void _resetFrom({
    bool afterCity = false,
    bool afterInstitution = false,
    bool afterCurriculum = false,
  }) {
    if (afterCity) {
      selectedInstitution.value = null;
      institutions.clear();
    }
    if (afterCity || afterInstitution) {
      selectedCurriculum.value = null;
      curricula.clear();
    }
    selectedStandard.value = null;
    standards.clear();
  }

  Future<void> createProfile() async {
    // Guests never see the name/username fields, so synthesize them: a fixed
    // display name and a timestamp-unique username that can't collide with the
    // `username` UNIQUE constraint (the 23505 handled below).
    final name = isGuest ? 'Explorer' : nameController.text.trim();
    final username = isGuest
        ? 'guest_${DateTime.now().millisecondsSinceEpoch}'
        : usernameController.text.trim();

    if (!_validate(name: name, username: username)) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final childId = await _childRepo.createChild(
        name: name,
        username: username,
        instituteId: selectedInstitution.value!.id,
        curriculumId: selectedCurriculum.value!.curriculumId,
        standardId: selectedStandard.value!.id,
      );

      // Guests skip the avatar step entirely.
      if (!isGuest && profileImagePath.value != null) {
        await _childRepo.uploadAvatar(childId, profileImagePath.value!);
      }

      if (isGuest) {
        // A guest owns exactly this one child, so populate activeChild directly
        // from the cascade values already in hand (no round-trip) and drop into
        // the app — mirroring ProfileSwitcherViewModel.selectChild's
        // precache-then-navigate. setActiveChild also sets currentStandard.
        final model = ChildProfileModel(
          id: childId,
          name: name,
          username: username,
          standard: selectedStandard.value,
          institution: selectedInstitution.value,
          curriculumId: selectedCurriculum.value!.curriculumId,
        );
        await session.setActiveChild(model);
        await _precacheHomeAssets();
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.profileSwitcher);
      }
    } on PostgrestException catch (e) {
      errorMessage.value = e.code == '23505'
          ? 'That username is already taken.'
          : 'Could not create profile. Try again.';
    } catch (e) {
      errorMessage.value = 'Could not create profile. Try again.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Warm the image cache for the home tabs so the guest lands on a fully
  /// painted dashboard, exactly as the profile switcher does on child select.
  Future<void> _precacheHomeAssets() async {
    final context = Get.context;
    if (context == null) return;
    await Future.wait([
      precacheImage(
        const AssetImage('assets/images/dashboard_bg.png'),
        context,
      ),
      precacheImage(const AssetImage('assets/images/subjects_bg.png'), context),
      precacheImage(const AssetImage('assets/images/progress_bg.png'), context),
      precacheImage(
        const AssetImage('assets/images/profile_card_bg.png'),
        context,
      ),
      precacheImage(const AssetImage('assets/images/banner.png'), context),
    ]);
  }

  bool _validate({required String name, required String username}) {
    // Guests don't fill identity fields (they're auto-generated and hidden),
    // so only the cascade is validated for them.
    if (!isGuest) {
      if (name.isEmpty) {
        errorMessage.value = 'Please enter child\'s name.';
        return false;
      }
      if (username.isEmpty) {
        errorMessage.value = 'Please enter a username.';
        return false;
      }
    }
    if (selectedCity.value == null) {
      errorMessage.value = 'Please select a city.';
      return false;
    }
    if (selectedInstitution.value == null) {
      errorMessage.value = 'Please select an institution.';
      return false;
    }
    if (selectedCurriculum.value == null) {
      errorMessage.value = 'Please select a curriculum.';
      return false;
    }
    if (selectedStandard.value == null) {
      errorMessage.value = 'Please select a grade.';
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}

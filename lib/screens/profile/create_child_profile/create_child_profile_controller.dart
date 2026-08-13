import 'dart:developer';

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

  @override
  void onInit() {
    super.onInit();
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
    if (!_validate()) return;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final childId = await _childRepo.createChild(
        name: nameController.text.trim(),
        username: usernameController.text.trim(),
        instituteId: selectedInstitution.value!.id,
        curriculumId: selectedCurriculum.value!.curriculumId,
        standardId: selectedStandard.value!.id,
      );

      if (profileImagePath.value != null) {
        await _childRepo.uploadAvatar(childId, profileImagePath.value!);
      }

      Get.offAllNamed(AppRoutes.profileSwitcher);
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

  bool _validate() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter child\'s name.';
      return false;
    }
    if (usernameController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter a username.';
      return false;
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

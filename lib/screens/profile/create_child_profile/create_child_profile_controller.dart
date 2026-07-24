import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../fns/image_picker_service.dart';
import '../../../models/institution_model.dart';
import '../../../models/standards_model.dart';
import '../../../routes/app_routes.dart';
import '../institution_repo.dart';

class CreateProfileViewModel extends GetxController {
  final InstitutionRepository _institutionRepo = InstitutionRepository();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  // Full list fetched once; filteredInstitutions is derived per selected city.
  var allInstitutions = <InstitutionModel>[].obs;
  var filteredInstitutions = <InstitutionModel>[].obs;
  var cities = <String>[].obs;
  var isLoadingInst = false.obs;

  var selectedCity = Rxn<String>();
  var selectedInstitution = Rxn<InstitutionModel>();
  var selectedStandard = Rxn<StandardModel>();

  var profileImagePath = Rxn<String>(); // local file path from image picker

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Hardcoded standards — replace with API later
  final standards = [
    StandardModel(id: 1, standard: 'Montessori'),
    StandardModel(id: 2, standard: 'Nursery'),
    StandardModel(id: 3, standard: 'Prep'),
    StandardModel(id: 4, standard: 'Grade 1'),
    StandardModel(id: 5, standard: 'Grade 2'),
    StandardModel(id: 6, standard: 'Grade 3'),
    StandardModel(id: 7, standard: 'Grade 4'),
    StandardModel(id: 8, standard: 'Grade 5'),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchInstitutions();
  }

  Future<void> fetchInstitutions() async {
    try {
      isLoadingInst.value = true;
      final result = await _institutionRepo.getInstitutions();
      allInstitutions.value = result;

      cities.value =
          result
              .map((e) => e.city)
              .whereType<String>()
              .where((c) => c.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();
    } catch (e) {
      errorMessage.value = 'Could not load institutions.';
    } finally {
      isLoadingInst.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    final imagePath = await ImagePickerService.pickImage(ImageSource.gallery);
    if (imagePath != null) {
      profileImagePath.value = imagePath;
    }
  }

  void selectCity(String? city) {
    if (city == selectedCity.value) return;
    selectedCity.value = city;
    selectedInstitution.value = null;
    selectedStandard.value = null;

    filteredInstitutions.value = city == null
        ? []
        : allInstitutions.where((inst) => inst.city == city).toList();
  }

  void selectInstitution(InstitutionModel? inst) {
    selectedInstitution.value = inst;
    selectedStandard.value = null;
  }

  void selectStandard(StandardModel? s) => selectedStandard.value = s;

  Future<void> createProfile() async {
    if (!_validate()) return;
    try {
      isLoading.value = true;
      Get.offAllNamed(AppRoutes.profileSwitcher);
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

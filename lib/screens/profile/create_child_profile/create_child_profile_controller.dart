import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/institution_model.dart';
import '../../../models/standards_model.dart';
import '../../../routes/app_routes.dart';
import '../institution_repo.dart';

class CreateProfileViewModel extends GetxController {
  final InstitutionRepository _institutionRepo = InstitutionRepository();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final searchController = TextEditingController();

  var institutions = <InstitutionModel>[].obs;
  var isLoadingInst = false.obs;
  var selectedStandard = Rxn<StandardModel>();
  var selectedInstitution = Rxn<InstitutionModel>();
  var selectedAvatar = ''.obs; // asset path
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

  // Avatar option
  final avatars = [
    'assets/images/boy1.png',
    'assets/images/boy2.png',
    'assets/images/boy3.png',
    'assets/images/boy4.png',
    'assets/images/girl1.png',
    'assets/images/girl2.png',
    'assets/images/girl3.png',
    'assets/images/girl4.png',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchInstitutions();
    searchController.addListener(() {
      fetchInstitutions(search: searchController.text);
    });
  }

  Future<void> fetchInstitutions({String? search}) async {
    try {
      isLoadingInst.value = true;
      institutions.value = await _institutionRepo.getInstitutions(
        search: search,
      );
    } catch (e) {
      errorMessage.value = 'Could not load institutions.';
    } finally {
      isLoadingInst.value = false;
    }
  }

  void selectStandard(StandardModel s) => selectedStandard.value = s;
  void selectInstitution(InstitutionModel i) => selectedInstitution.value = i;
  void selectAvatar(String path) => selectedAvatar.value = path;

  Future<void> createProfile() async {
    if (!_validate()) return;
    try {
      isLoading.value = true;

      // TODO: replace with real API call
      await Future.delayed(const Duration(seconds: 1));

      // Go back to switcher and refresh
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
    if (selectedStandard.value == null) {
      errorMessage.value = 'Please select a grade.';
      return false;
    }
    if (selectedInstitution.value == null) {
      errorMessage.value = 'Please select an institution.';
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    searchController.dispose();
    super.onClose();
  }
}

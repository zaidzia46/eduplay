import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../controller/session_controller.dart';
import '../../../models/institution_model.dart';
import '../../../models/standards_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../widgets/add_child_profile_bg.dart';
import 'create_child_profile_controller.dart';

class CreateProfileView extends StatelessWidget {
  const CreateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<CreateProfileViewModel>();
    final session = Get.find<SessionController>();
    const double avatarSize = 84;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Add Child Profile', style: AppTextStyles.h3),
      ),
      extendBodyBehindAppBar: true,
      body: ProfileBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: session.setChildAvatar,
                    child: Obx(() {
                      final path = vm.profileImagePath.value;
                      return Stack(
                        children: [
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xffFFD84E),
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: avatarSize / 2,
                              backgroundColor: AppColors.primaryDark,
                              backgroundImage: path != null
                                  ? FileImage(File(path))
                                  : null,
                              child: path == null
                                  ? Icon(Icons.person, size: avatarSize * 0.5)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                Text("Child's Name", style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                  controller: vm.nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. John Elijah',
                    prefixIcon: _prefixIcon(FontAwesomeIcons.userGraduate),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Username', style: AppTextStyles.label),
                const SizedBox(height: 6),
                TextField(
                  controller: vm.usernameController,
                  decoration: InputDecoration(
                    hintText: 'e.g. john123',
                    prefixIcon: _prefixIcon(FontAwesomeIcons.at),
                  ),
                ),
                const SizedBox(height: 24),

                Text('City', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: vm.selectedCity.value,
                    decoration: InputDecoration(
                      hintText: vm.isLoadingInst.value
                          ? 'Loading cities...'
                          : 'Select city',
                      prefixIcon: _prefixIcon(FontAwesomeIcons.city),
                    ),
                    items: vm.cities
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: vm.isLoadingInst.value
                        ? null
                        : (value) => vm.selectCity(value),
                  ),
                ),
                const SizedBox(height: 16),

                Text('Institution', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Obx(() {
                  final cityChosen = vm.selectedCity.value != null;
                  return DropdownButtonFormField<InstitutionModel>(
                    value: vm.selectedInstitution.value,
                    decoration: InputDecoration(
                      hintText: cityChosen
                          ? 'Select your school'
                          : 'Select a city first',
                      prefixIcon: _prefixIcon(FontAwesomeIcons.school),
                    ),
                    items: vm.filteredInstitutions
                        .map(
                          (inst) => DropdownMenuItem(
                            value: inst,
                            child: Text(inst.name),
                          ),
                        )
                        .toList(),
                    onChanged: cityChosen
                        ? (value) => vm.selectInstitution(value)
                        : null,
                  );
                }),
                const SizedBox(height: 16),

                // --- Grade / Standard (unlocked after institution) ---
                Text('Grade / Standard', style: AppTextStyles.label),
                const SizedBox(height: 6),
                Obx(() {
                  final institutionChosen =
                      vm.selectedInstitution.value != null;
                  return DropdownButtonFormField<StandardModel>(
                    value: vm.selectedStandard.value,
                    decoration: InputDecoration(
                      hintText: institutionChosen
                          ? 'Select grade'
                          : 'Select a school first',
                      prefixIcon: _prefixIcon(FontAwesomeIcons.graduationCap),
                    ),
                    items: vm.standards
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.standard),
                          ),
                        )
                        .toList(),
                    onChanged: institutionChosen
                        ? (value) => vm.selectStandard(value)
                        : null,
                  );
                }),
                const SizedBox(height: 24),

                Obx(
                  () => vm.errorMessage.isNotEmpty
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.errorSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vm.errorMessage.value,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                Obx(
                  () => ElevatedButton(
                    onPressed: vm.isLoading.value ? null : vm.createProfile,
                    child: vm.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Add Child'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _prefixIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: SizedBox(
        width: 18,
        height: 18,
        child: FittedBox(fit: BoxFit.scaleDown, child: FaIcon(icon, size: 18)),
      ),
    );
  }
}

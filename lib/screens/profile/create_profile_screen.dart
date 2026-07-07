// views/profile_switcher/create_profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'child_profile_controller.dart';

class CreateProfileView extends StatelessWidget {
  const CreateProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<CreateProfileViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Add Child Profile', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar picker ───────────────────────────────
            Text('Pick an avatar', style: AppTextStyles.label),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = vm.avatars[index];
                    final isSelected = vm.selectedAvatar.value == avatar;
                    return GestureDetector(
                      onTap: () => vm.selectAvatar(avatar),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 12),
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 3 : 1.5,
                          ),
                          color: isSelected
                              ? AppColors.primarySurface
                              : Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.person,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Name ────────────────────────────────────────
            Text("Child's Name", style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: vm.nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Ayesha',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // ── Username ─────────────────────────────────────
            Text('Username', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: vm.usernameController,
              decoration: const InputDecoration(
                hintText: 'e.g. ayesha123',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 24),

            // ── Standard picker ──────────────────────────────
            Text('Grade / Standard', style: AppTextStyles.label),
            const SizedBox(height: 12),
            Obx(
              () => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: vm.standards.map((s) {
                  final isSelected = vm.selectedStandard.value?.id == s.id;
                  return GestureDetector(
                    onTap: () => vm.selectStandard(s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        s.standard,
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Institution search ───────────────────────────
            Text('Institution', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: vm.searchController,
              decoration: const InputDecoration(
                hintText: 'Search your school...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),

            Obx(() {
              if (vm.isLoadingInst.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.institutions.isEmpty) {
                return Center(
                  child: Text(
                    'No institutions found.',
                    style: AppTextStyles.bodySecondary,
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vm.institutions.length,
                itemBuilder: (context, index) {
                  final inst = vm.institutions[index];
                  final isSelected =
                      vm.selectedInstitution.value?.id == inst.id;
                  return GestureDetector(
                    onTap: () => vm.selectInstitution(inst),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  inst.name,
                                  style: AppTextStyles.body.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                if (inst.city != null)
                                  Text(
                                    inst.city!,
                                    style: AppTextStyles.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 24),

            // ── Error ────────────────────────────────────────
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

            // ── Submit button ────────────────────────────────
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
                    : const Text('Create Profile 🎉'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

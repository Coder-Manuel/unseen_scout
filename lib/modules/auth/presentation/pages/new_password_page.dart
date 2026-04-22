import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
import 'package:unseen_scout/modules/auth/presentation/controllers/reset_password_controller.dart';
import 'package:unseen_scout/modules/auth/presentation/widgets/auth_widgets.dart';

class NewPasswordPage extends GetView<ResetPasswordController> {
  static const String route = '/new-password';

  const NewPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                24.verticalSpace,

                // ── Back to login ────────────────────────────────────────
                _BackToLoginButton(),

                60.verticalSpace,

                // ── Title ────────────────────────────────────────────────
                const Text(
                  'New Password',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                16.verticalSpace,

                const Text(
                  'Choose a strong password for your UnSeen account.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                40.verticalSpace,

                // ── New password ─────────────────────────────────────────
                Obx(
                  () => AuthTextField(
                    controller: controller.passwordCTRL,
                    hint: 'New Password',
                    obscureText: controller.obscurePassword.value,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.iconColor,
                      size: 20,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: controller.toggleObscurePassword,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Enter a new password';
                      if (v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),
                ),

                16.verticalSpace,

                // ── Confirm password ─────────────────────────────────────
                Obx(
                  () => AuthTextField(
                    controller: controller.confirmCTRL,
                    hint: 'Confirm New Password',
                    obscureText: controller.obscureConfirm.value,
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.iconColor,
                      size: 20,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: controller.toggleObscureConfirm,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(
                          controller.obscureConfirm.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirm your password';
                      if (v != controller.passwordCTRL.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),

                32.verticalSpace,

                // ── Submit ───────────────────────────────────────────────
                PrimaryButton(
                  label: 'Reset Password & Login',
                  onPressed: () => controller.updatePassword(formKey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Back-to-login button ──────────────────────────────────────────────────────

class _BackToLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Get.back,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          SizedBox(width: 4),
          Text(
            'BACK TO LOGIN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

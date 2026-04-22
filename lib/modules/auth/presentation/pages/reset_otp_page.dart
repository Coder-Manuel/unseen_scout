import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:unseen_scout/config/colors.dart';
import 'package:unseen_scout/core/utils/size.util.dart';
import 'package:unseen_scout/modules/auth/presentation/controllers/reset_password_controller.dart';
import 'package:unseen_scout/modules/auth/presentation/widgets/auth_widgets.dart';

class ResetOtpPage extends GetView<ResetPasswordController> {
  static const String route = '/reset-otp';

  const ResetOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              24.verticalSpace,

              // ── Back to login ────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: _BackToLoginButton(),
              ),

              56.verticalSpace,

              // ── Shield icon ──────────────────────────────────────────────
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withAlpha(25),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),

              28.verticalSpace,

              // ── Title ────────────────────────────────────────────────────
              const Text(
                'Security Code',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),

              12.verticalSpace,

              // ── Subtitle with masked email ────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Enter the 6-digit code sent to\n',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: controller.sentToEmail,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              48.verticalSpace,

              // ── OTP boxes ────────────────────────────────────────────────
              _ResetOtpField(controller: controller.otpCTRL),

              36.verticalSpace,

              // ── Verify button ────────────────────────────────────────────
              PrimaryButton(
                label: 'Verify Code',
                onPressed: controller.verifyOtp,
              ),

              20.verticalSpace,

              // ── Resend link ───────────────────────────────────────────────
              GestureDetector(
                onTap: controller.resendCode,
                child: const Text(
                  'Resend Code',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── OTP pin field ─────────────────────────────────────────────────────────────

class _ResetOtpField extends StatelessWidget {
  final TextEditingController controller;
  const _ResetOtpField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final defaultTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    );

    final filledTheme = defaultTheme.copyDecorationWith(
      color: AppColors.surface,
      border: Border.all(color: AppColors.primary.withAlpha(80), width: 1),
      borderRadius: BorderRadius.circular(12),
    );

    return Pinput(
      length: 6,
      controller: controller,
      showCursor: true,
      defaultPinTheme: defaultTheme,
      focusedPinTheme: focusedTheme,
      submittedPinTheme: filledTheme,
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      separatorBuilder: (_) => 10.horizontalSpace,
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

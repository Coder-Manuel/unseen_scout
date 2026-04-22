import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unseen_scout/core/utils/loader.dart';
import 'package:unseen_scout/core/utils/toast.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/domain/usecases/send_reset_email.usecase.dart';
import 'package:unseen_scout/modules/auth/domain/usecases/update_password.usecase.dart';
import 'package:unseen_scout/modules/auth/domain/usecases/verify_reset_otp.usecase.dart';
import 'package:unseen_scout/modules/auth/presentation/pages/login_page.dart';
import 'package:unseen_scout/modules/auth/presentation/pages/new_password_page.dart';
import 'package:unseen_scout/modules/auth/presentation/pages/reset_otp_page.dart';

class ResetPasswordController extends GetxController {
  final SendResetEmailUseCase _sendResetEmailUseCase;
  final VerifyResetOtpUseCase _verifyResetOtpUseCase;
  final UpdatePasswordUseCase _updatePasswordUseCase;

  ResetPasswordController({
    required SendResetEmailUseCase sendResetEmailUseCase,
    required VerifyResetOtpUseCase verifyResetOtpUseCase,
    required UpdatePasswordUseCase updatePasswordUseCase,
  }) : _sendResetEmailUseCase = sendResetEmailUseCase,
       _verifyResetOtpUseCase = verifyResetOtpUseCase,
       _updatePasswordUseCase = updatePasswordUseCase;

  // ── Form controllers ──────────────────────────────────────────────────────

  final emailCTRL = TextEditingController();
  final otpCTRL = TextEditingController();
  final passwordCTRL = TextEditingController();
  final confirmCTRL = TextEditingController();

  // ── Observables ───────────────────────────────────────────────────────────

  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;

  /// The email the code was sent to — persisted across pages.
  String _sentToEmail = '';
  String get sentToEmail => _sentToEmail;

  // ── Step 1: Send reset code ───────────────────────────────────────────────

  Future<void> sendResetCode(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    Loader.show();
    final result = await _sendResetEmailUseCase(
      ForgotPasswordInput(email: emailCTRL.text.trim()),
    );
    Loader.dismiss();

    result.fold((err) => Toast.error(err.message), (_) {
      _sentToEmail = emailCTRL.text.trim();
      Get.toNamed(ResetOtpPage.route);
    });
  }

  // ── Step 2: Verify OTP ────────────────────────────────────────────────────

  Future<void> verifyOtp() async {
    final otp = otpCTRL.text.trim();
    if (otp.length < 6) {
      Toast.error('Enter the complete 6-digit code');
      return;
    }

    Loader.show();
    final result = await _verifyResetOtpUseCase(
      ResetOtpInput(email: _sentToEmail, otp: otp),
    );
    Loader.dismiss();

    result.fold(
      (err) => Toast.error(err.message),
      (_) => Get.toNamed(NewPasswordPage.route),
    );
  }

  /// Resends the recovery OTP without revalidating the form.
  Future<void> resendCode() async {
    if (_sentToEmail.isEmpty) return;

    Loader.show();
    final result = await _sendResetEmailUseCase(
      ForgotPasswordInput(email: _sentToEmail),
    );
    Loader.dismiss();

    result.fold(
      (err) => Toast.error(err.message),
      (_) => Toast.success('A new code has been sent to $_sentToEmail'),
    );
  }

  // ── Step 3: Set new password ──────────────────────────────────────────────

  Future<void> updatePassword(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    Loader.show();
    final result = await _updatePasswordUseCase(
      NewPasswordInput(password: passwordCTRL.text),
    );
    Loader.dismiss();

    result.fold((err) => Toast.error(err.message), (_) {
      Toast.success('Password updated — please log in');
      // Clear back-stack all the way to login.
      Get.offAllNamed(LoginPage.route);
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void toggleObscurePassword() =>
      obscurePassword.value = !obscurePassword.value;
  void toggleObscureConfirm() => obscureConfirm.value = !obscureConfirm.value;

  @override
  void onClose() {
    emailCTRL.dispose();
    otpCTRL.dispose();
    passwordCTRL.dispose();
    confirmCTRL.dispose();
    super.onClose();
  }
}

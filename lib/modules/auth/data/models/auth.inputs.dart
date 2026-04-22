// ─── Login ────────────────────────────────────────────────────────────────────

import 'package:unseen_scout/core/models/enums.dart';

class LoginInput {
  final String? email;
  final String? phone;
  final String? password;

  LoginInput({this.email, this.phone, this.password})
    : assert(
        (email != null || phone != null) && password != null,
        'Provide (email or phone) and password',
      );

  Map<String, dynamic> toMap() => {
    'email': email,
    'phone': phone,
    'password': password,
  };
}

// ─── OAuth (Google) ───────────────────────────────────────────────────────────

class OAuthInput {
  final String idToken;
  final bool isLogin;
  final String? accessToken;

  OAuthInput({required this.idToken, this.isLogin = true, this.accessToken});

  Map<String, dynamic> toMap() => {
    'idToken': idToken,
    'accessToken': accessToken,
  };
}

// ─── Signup ───────────────────────────────────────────────────────────────────

class SignupInput {
  final String email;
  final String password;
  final UserRole role;

  SignupInput({
    required this.email,
    required this.password,
    this.role = UserRole.scout,
  });

  Map<String, dynamic> toMap() => {
    'email': email,
    'password': password,
    'meta': {'role': role.name},
  };
}

// ─── OTP Verification ─────────────────────────────────────────────────────────

/// Use [email] for email OTP verification, [phone] for SMS OTP verification.
class VerifyOtpInput {
  final String otp;
  final String? email;
  final String? phone;

  VerifyOtpInput.email({required this.otp, required String this.email})
    : phone = null;

  VerifyOtpInput.phone({required this.otp, required String this.phone})
    : email = null;

  Map<String, dynamic> toMap() => {'otp': otp, 'email': email, 'phone': phone};
}

// ─── Phone Setup ──────────────────────────────────────────────────────────────

/// Full phone number including country code, e.g. "+254712345678".
class PhoneSetupInput {
  final String phone;

  PhoneSetupInput({required this.phone});
}

// ─── Names Setup ──────────────────────────────────────────────────────────────

class NamesInput {
  final String firstName;
  final String lastName;

  NamesInput({required this.firstName, required this.lastName});

  Map<String, dynamic> toMap() => {
    'first_name': firstName,
    'last_name': lastName,
  };
}

// ─── Reset Password ───────────────────────────────────────────────────────────

/// Step 1 — request a 6-digit recovery OTP to [email].
class ForgotPasswordInput {
  final String email;
  ForgotPasswordInput({required this.email});
}

/// Step 2 — verify the recovery OTP together with the [email] it was sent to.
class ResetOtpInput {
  final String email;
  final String otp;
  ResetOtpInput({required this.email, required this.otp});
  Map<String, dynamic> toMap() => {'email': email, 'otp': otp};
}

/// Step 3 — set the new password (requires an active recovery session).
class NewPasswordInput {
  final String password;
  NewPasswordInput({required this.password});
}

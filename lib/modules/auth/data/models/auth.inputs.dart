// ─── Login ────────────────────────────────────────────────────────────────────

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
  final String? accessToken;

  OAuthInput({required this.idToken, this.accessToken});

  Map<String, dynamic> toMap() => {
    'idToken': idToken,
    'accessToken': accessToken,
  };
}

// ─── Signup ───────────────────────────────────────────────────────────────────

class SignupInput {
  final String email;
  final String password;

  SignupInput({required this.email, required this.password});

  Map<String, dynamic> toMap() => {
    'email': email,
    'password': password,
    'meta': <String, dynamic>{},
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

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unseen_scout/core/models/enums.dart';

abstract class RemoteAuthDatasource {
  Future<AuthResponse> loginWithPassword({required Map<String, dynamic> data});
  Future<AuthResponse> verifyOTP({
    required Map<String, dynamic> data,
    OtpType otpType = OtpType.email,
  });
  Future<AuthResponse> signupWithOAuth({
    required Map<String, dynamic> data,
    OAuthProvider provider = OAuthProvider.google,
  });
  Future<AuthResponse> signUp({required Map<String, dynamic> data});
  Future<UserResponse> updatePhone(String phone);
  Future<Map<String, dynamic>?> updateNames(Map<String, dynamic> data);
  Future<void> logout();

  // ─── Password reset ───────────────────────────────────────────────────────
  /// Triggers a 6-digit recovery OTP email via Supabase.
  Future<void> sendPasswordResetEmail(String email);

  /// Verifies the recovery OTP.  On success Supabase issues a session that
  /// allows [updatePassword] to be called without re-authenticating.
  Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String otp,
  });

  /// Updates the authenticated user's password.  Must be called while a
  /// valid recovery session is active (i.e. after [verifyRecoveryOtp]).
  Future<UserResponse> updatePassword(String newPassword);
}

class RemoteAuthDatasourceImpl extends RemoteAuthDatasource {
  final SupabaseClient client;

  RemoteAuthDatasourceImpl({required this.client});

  @override
  Future<AuthResponse> loginWithPassword({required Map<String, dynamic> data}) {
    return client.auth.signInWithPassword(
      email: data['email'],
      phone: data['phone'],
      password: data['password'],
    );
  }

  @override
  Future<AuthResponse> signupWithOAuth({
    required Map<String, dynamic> data,
    OAuthProvider provider = OAuthProvider.google,
  }) {
    return client.auth.signInWithIdToken(
      provider: provider,
      idToken: data['idToken'],
      accessToken: data['accessToken'],
    );
  }

  @override
  Future<AuthResponse> signUp({required Map<String, dynamic> data}) {
    return client.auth.signUp(
      password: data['password'],
      email: data['email'],
      data: data['meta'],
    );
  }

  @override
  Future<AuthResponse> verifyOTP({
    required Map<String, dynamic> data,
    OtpType otpType = OtpType.email,
  }) {
    return client.auth.verifyOTP(
      type: otpType,
      email: data['email'],
      phone: data['phone'],
      token: data['otp'],
    );
  }

  @override
  Future<UserResponse> updatePhone(String phone) {
    return client.auth.updateUser(
      UserAttributes(phone: phone, data: {'role': UserRole.scout.name}),
    );
  }

  @override
  Future<Map<String, dynamic>?> updateNames(Map<String, dynamic> data) {
    return client
        .from('users')
        .update(data)
        .eq('id', client.auth.currentUser?.id ?? '')
        .select()
        .single();
  }

  @override
  Future<void> logout() {
    return client.auth.signOut();
  }

  // ─── Password reset ───────────────────────────────────────────────────────

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) {
    return client.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
    );
  }

  @override
  Future<UserResponse> updatePassword(String newPassword) {
    return client.auth.updateUser(UserAttributes(password: newPassword));
  }
}

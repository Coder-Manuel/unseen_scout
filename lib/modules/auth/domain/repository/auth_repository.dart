import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';

abstract class AuthRepository {
  // ─── Login ─────────────────────────────────────────────────────────────────
  Future<RepoResponse<User>> login(LoginInput input);
  Future<RepoResponse<User>> loginWithOAuth(OAuthInput input);

  // ─── Signup ────────────────────────────────────────────────────────────────
  /// Creates the account and triggers a Supabase email OTP.
  Future<RepoResponse<User>> signup(SignupInput input);

  // ─── Email verification ────────────────────────────────────────────────────
  Future<RepoResponse<User>> verifyEmailOtp(VerifyOtpInput input);

  // ─── Phone setup & verification ────────────────────────────────────────────
  /// Calls Supabase updateUser(phone) which triggers an SMS OTP.
  Future<RepoResponse<bool>> setupPhone(PhoneSetupInput input);
  Future<RepoResponse<User>> verifyPhoneOtp(VerifyOtpInput input);

  // ─── Names setup ───────────────────────────────────────────────────────────
  Future<RepoResponse<bool>> setupNames(NamesInput input);

  // ─── Logout ────────────────────────────────────────────────────────────────
  Future<RepoResponse<bool>> logout();

  // ─── Password reset ────────────────────────────────────────────────────────
  /// Step 1 — sends a 6-digit recovery OTP to [input.email].
  Future<RepoResponse<bool>> sendPasswordResetEmail(ForgotPasswordInput input);

  /// Step 2 — verifies the OTP.  Returns true when a recovery session is live.
  Future<RepoResponse<bool>> verifyResetOtp(ResetOtpInput input);

  /// Step 3 — updates the password while the recovery session is active.
  Future<RepoResponse<bool>> updatePassword(NewPasswordInput input);
}

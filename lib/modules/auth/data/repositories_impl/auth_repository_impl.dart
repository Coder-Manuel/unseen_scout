import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/models/user.model.dart';
import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/utils/error_wrapper.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/data/sources/remote_auth_datasource.dart';
import 'package:unseen_scout/modules/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final _library = 'Auth Repository';
  final RemoteAuthDatasource remoteDatasource;

  AuthRepositoryImpl({required this.remoteDatasource});

  // ─── Login ─────────────────────────────────────────────────────────────────

  @override
  Future<RepoResponse<User>> login(LoginInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<User>>(
      () async {
        final res = await remoteDatasource.loginWithPassword(
          data: input.toMap(),
        );
        if (res.session == null) {
          return FailureResponse('Invalid credentials, kindly retry');
        }
        return SuccessResponse(UserModel.fromMap(res.user?.toJson() ?? {}));
      },
      onError: (error) {
        if (error.toString().contains('invalid_credentials')) {
          return FailureResponse('Invalid credentials, kindly retry');
        }
        return FailureResponse('An error occurred, kindly retry');
      },
      library: _library,
      description: 'while user login',
    );
    return response!;
  }

  @override
  Future<RepoResponse<User>> loginWithOAuth(OAuthInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<User>>(
      () async {
        final res = await remoteDatasource.signupWithOAuth(data: input.toMap());
        if (res.session == null) {
          return FailureResponse('OAuth login failed, kindly retry');
        }
        return SuccessResponse(UserModel.fromMap(res.user?.toJson() ?? {}));
      },
      onError: (_) => FailureResponse('An error occurred, kindly retry'),
      library: _library,
      description: 'while OAuth login',
    );
    return response!;
  }

  // ─── Signup ────────────────────────────────────────────────────────────────

  @override
  Future<RepoResponse<User>> signup(SignupInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<User>>(
      () async {
        final res = await remoteDatasource.signUp(data: input.toMap());
        // Supabase returns a user before email is verified — that is expected.
        if (res.user == null) {
          return FailureResponse('Unable to create account, kindly retry');
        }
        return SuccessResponse(UserModel.fromMap(res.user?.toJson() ?? {}));
      },
      onError: (_) => FailureResponse('An error occurred, kindly retry'),
      library: _library,
      description: 'while signing up',
    );
    return response!;
  }

  // ─── Email verification ────────────────────────────────────────────────────

  @override
  Future<RepoResponse<User>> verifyEmailOtp(VerifyOtpInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<User>>(
      () async {
        final res = await remoteDatasource.verifyOTP(
          data: input.toMap(),
          otpType: OtpType.email,
        );
        if (res.session == null) {
          return FailureResponse('Invalid or expired code, kindly retry');
        }
        return SuccessResponse(UserModel.fromMap(res.user?.toJson() ?? {}));
      },
      onError: (_) => FailureResponse('An error occurred, kindly retry'),
      library: _library,
      description: 'while verifying email OTP',
    );
    return response!;
  }

  // ─── Phone setup & verification ────────────────────────────────────────────

  @override
  Future<RepoResponse<bool>> setupPhone(PhoneSetupInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<bool>>(
      () async {
        await remoteDatasource.updatePhone(input.phone);
        return SuccessResponse(true);
      },
      onError: (_) => FailureResponse('An error occurred, kindly retry'),
      library: _library,
      description: 'while setting up phone',
    );
    return response!;
  }

  @override
  Future<RepoResponse<User>> verifyPhoneOtp(VerifyOtpInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<User>>(
      () async {
        final res = await remoteDatasource.verifyOTP(
          data: input.toMap(),
          otpType: OtpType.sms,
        );
        if (res.session == null) {
          return FailureResponse('Invalid or expired code, kindly retry');
        }
        return SuccessResponse(UserModel.fromMap(res.user?.toJson() ?? {}));
      },
      onError: (error) {
        if (error.toString().contains('expired or is invalid')) {
          return FailureResponse('Invalid or expired code, kindly retry');
        }
        return FailureResponse('An error occurred, kindly retry');
      },
      library: _library,
      description: 'while verifying phone OTP',
    );
    return response!;
  }

  // ─── Names setup ───────────────────────────────────────────────────────────

  @override
  Future<RepoResponse<bool>> setupNames(NamesInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<bool>>(
      () async {
        final result = await remoteDatasource.updateNames(input.toMap());
        if (result == null) {
          return FailureResponse('Unable to save your name, kindly retry');
        }
        return SuccessResponse(true);
      },
      onError: (_) => FailureResponse('An error occurred, kindly retry'),
      library: _library,
      description: 'while setting up names',
    );
    return response!;
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  @override
  Future<RepoResponse<bool>> logout() async {
    final response = await ErrorWrapper.async<RepoResponse<bool>>(
      () async {
        await remoteDatasource.logout();
        return SuccessResponse(true);
      },
      onError: (_) => FailureResponse('An error occurred, kindly retry'),
      library: _library,
      description: 'while logging out',
    );
    return response!;
  }

  // ─── Password reset ────────────────────────────────────────────────────────

  @override
  Future<RepoResponse<bool>> sendPasswordResetEmail(
    ForgotPasswordInput input,
  ) async {
    final response = await ErrorWrapper.async<RepoResponse<bool>>(
      () async {
        await remoteDatasource.sendPasswordResetEmail(input.email);
        return SuccessResponse(true);
      },
      onError: (_) => FailureResponse('Could not send reset code, kindly retry'),
      library: _library,
      description: 'while sending password reset email',
    );
    return response!;
  }

  @override
  Future<RepoResponse<bool>> verifyResetOtp(ResetOtpInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<bool>>(
      () async {
        final res = await remoteDatasource.verifyRecoveryOtp(
          email: input.email,
          otp: input.otp,
        );
        if (res.session == null) {
          return FailureResponse('Invalid or expired code, kindly retry');
        }
        return SuccessResponse(true);
      },
      onError: (_) => FailureResponse('Invalid or expired code, kindly retry'),
      library: _library,
      description: 'while verifying reset OTP',
    );
    return response!;
  }

  @override
  Future<RepoResponse<bool>> updatePassword(NewPasswordInput input) async {
    final response = await ErrorWrapper.async<RepoResponse<bool>>(
      () async {
        await remoteDatasource.updatePassword(input.password);
        return SuccessResponse(true);
      },
      onError: (_) => FailureResponse('Could not update password, kindly retry'),
      library: _library,
      description: 'while updating password',
    );
    return response!;
  }
}

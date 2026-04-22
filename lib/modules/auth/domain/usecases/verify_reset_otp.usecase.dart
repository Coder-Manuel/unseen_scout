import 'dart:async';

import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/domain/repository/auth_repository.dart';

class VerifyResetOtpUseCase implements UseCase<bool, ResetOtpInput> {
  final AuthRepository repo;
  VerifyResetOtpUseCase({required this.repo});

  @override
  FutureOr<RepoResponse<bool>> call(ResetOtpInput params) =>
      repo.verifyResetOtp(params);
}

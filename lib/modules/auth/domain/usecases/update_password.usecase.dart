import 'dart:async';

import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/domain/repository/auth_repository.dart';

class UpdatePasswordUseCase implements UseCase<bool, NewPasswordInput> {
  final AuthRepository repo;
  UpdatePasswordUseCase({required this.repo});

  @override
  FutureOr<RepoResponse<bool>> call(NewPasswordInput params) =>
      repo.updatePassword(params);
}

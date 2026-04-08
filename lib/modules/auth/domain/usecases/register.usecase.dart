import 'dart:async';

import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/domain/repository/auth_repository.dart';

class RegisterUsecase implements UseCase<User, SignupInput> {
  final AuthRepository repo;
  RegisterUsecase({required this.repo});

  @override
  FutureOr<RepoResponse<User>> call(SignupInput params) => repo.signup(params);
}

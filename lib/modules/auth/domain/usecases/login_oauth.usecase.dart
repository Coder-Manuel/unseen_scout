import 'dart:async';

import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/domain/repository/auth_repository.dart';

class LoginOAuthUseCase implements UseCase<User, OAuthInput> {
  final AuthRepository repo;
  LoginOAuthUseCase({required this.repo});

  @override
  FutureOr<RepoResponse<User>> call(OAuthInput params) =>
      repo.loginWithOAuth(params);
}

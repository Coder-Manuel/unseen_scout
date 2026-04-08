import 'dart:async';

import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/auth/data/models/auth.inputs.dart';
import 'package:unseen_scout/modules/auth/domain/repository/auth_repository.dart';

class SetupNamesUseCase implements UseCase<bool, NamesInput> {
  final AuthRepository repo;
  SetupNamesUseCase({required this.repo});

  @override
  FutureOr<RepoResponse<bool>> call(NamesInput params) =>
      repo.setupNames(params);
}

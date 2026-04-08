import 'dart:async';

import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/user/domain/repository/user_repository.dart';

class GetUserInfoUseCase implements UseCase<User, dynamic> {
  final UserRepository repo;
  GetUserInfoUseCase({required this.repo});

  @override
  FutureOr<RepoResponse<User>> call([params]) {
    return repo.getUserInfo();
  }
}

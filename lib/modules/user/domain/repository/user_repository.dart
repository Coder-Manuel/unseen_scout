import 'package:unseen_scout/core/entities/user.entity.dart';
import 'package:unseen_scout/core/types/repo_reponse.type.dart';

abstract class UserRepository {
  Future<RepoResponse<User>> getUserInfo();
}

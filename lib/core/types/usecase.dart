import 'dart:async';

import 'package:unseen_scout/core/types/repo_reponse.type.dart';

abstract class UseCase<T, Params> {
  FutureOr<RepoResponse<T>> call(Params params);
}

abstract class StreamUseCase<T, Params> {
  Stream<RepoResponse<T>> call(Params params);
}

import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/modules/payments/domain/entities/statement.entity.dart';

abstract class PaymentsRepository {
  Future<RepoResponse<List<StatementEntity>>> getStatements();
}

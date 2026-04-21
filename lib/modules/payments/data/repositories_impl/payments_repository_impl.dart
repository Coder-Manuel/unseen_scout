import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/utils/error_wrapper.dart';
import 'package:unseen_scout/modules/payments/data/models/statement.model.dart';
import 'package:unseen_scout/modules/payments/data/sources/remote_payments_datasource.dart';
import 'package:unseen_scout/modules/payments/domain/entities/statement.entity.dart';
import 'package:unseen_scout/modules/payments/domain/repository/payments_repository.dart';

class PaymentsRepositoryImpl extends PaymentsRepository {
  final _library = 'Payments Repository';
  final RemotePaymentsDatasource remoteDatasource;

  PaymentsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<RepoResponse<List<StatementEntity>>> getStatements() async {
    final response = await ErrorWrapper.async<RepoResponse<List<StatementEntity>>>(
      () async {
        final rows = await remoteDatasource.getStatements();
        final statements = rows.map(StatementModel.fromMap).toList();
        return SuccessResponse(statements);
      },
      onError: (_) => FailureResponse('Unable to load payment statements.'),
      library: _library,
      description: 'while fetching payment statements',
    );
    return response!;
  }
}

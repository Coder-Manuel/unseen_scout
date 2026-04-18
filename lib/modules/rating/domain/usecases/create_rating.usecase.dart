import 'package:unseen_scout/core/types/repo_reponse.type.dart';
import 'package:unseen_scout/core/types/usecase.dart';
import 'package:unseen_scout/modules/rating/data/models/rating.input.dart';
import 'package:unseen_scout/modules/rating/domain/entities/rating.entity.dart';
import 'package:unseen_scout/modules/rating/domain/repository/rating_repository.dart';

class CreateRatingUseCase extends UseCase<RatingEntity, CreateRatingInput> {
  final RatingRepository repo;

  CreateRatingUseCase({required this.repo});

  @override
  Future<RepoResponse<RatingEntity>> call(CreateRatingInput input) =>
      repo.createRating(input);
}

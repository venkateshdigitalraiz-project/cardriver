import '../entities/rating_entity.dart';
import '../repositories/rating_repository.dart';

class SubmitRatingUseCase {
  final RatingRepository repository;

  SubmitRatingUseCase(this.repository);

  Future<bool> execute({
    required RatingEntity rating,
    String? token,
  }) async {
    return await repository.submitRating(
      rating: rating,
      token: token,
    );
  }
}


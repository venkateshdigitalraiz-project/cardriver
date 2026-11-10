import '../entities/rating_entity.dart';

abstract class RatingRepository {
  Future<bool> submitRating({
    required RatingEntity rating,
    String? token,
  });
}


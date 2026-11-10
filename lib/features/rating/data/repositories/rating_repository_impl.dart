import '../../domain/entities/rating_entity.dart';
import '../../domain/repositories/rating_repository.dart';
import '../datasources/rating_remote_datasource.dart';
import '../models/rating_model.dart';

class RatingRepositoryImpl implements RatingRepository {
  final RatingRemoteDataSource remoteDataSource;

  RatingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> submitRating({
    required RatingEntity rating,
    String? token,
  }) async {
    final model = RatingModel.fromEntity(rating);
    return await remoteDataSource.submitRating(
      model: model,
      token: token,
    );
  }
}


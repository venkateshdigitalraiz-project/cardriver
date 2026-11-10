import '../../domain/entities/rating_entity.dart';

class RatingModel extends RatingEntity {
  const RatingModel({
    required super.bookingId,
    required super.rating,
    super.comment,
    super.tags,
    super.targetId,
    super.targetName,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'rating': rating,
      if (comment.isNotEmpty) 'comment': comment,
      if (comment.isNotEmpty) 'feedback': comment,
      if (tags.isNotEmpty) 'tags': tags,
      if (targetId.isNotEmpty) 'userId': targetId,
      'isDriverRated': true,
    };
  }

  factory RatingModel.fromEntity(RatingEntity entity) {
    return RatingModel(
      bookingId: entity.bookingId,
      rating: entity.rating,
      comment: entity.comment,
      tags: entity.tags,
      targetId: entity.targetId,
      targetName: entity.targetName,
    );
  }
}


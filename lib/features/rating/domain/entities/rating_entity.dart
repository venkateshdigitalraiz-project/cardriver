import 'package:equatable/equatable.dart';

/// Clean Architecture Entity representing a rating submission
class RatingEntity extends Equatable {
  final String bookingId;
  final double rating;
  final String comment;
  final List<String> tags;
  final String targetId; // userId or driverId
  final String targetName;

  const RatingEntity({
    required this.bookingId,
    required this.rating,
    this.comment = '',
    this.tags = const [],
    this.targetId = '',
    this.targetName = '',
  });

  @override
  List<Object?> get props => [
        bookingId,
        rating,
        comment,
        tags,
        targetId,
        targetName,
      ];
}


import 'package:equatable/equatable.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

class RatingScoreChangedEvent extends RatingEvent {
  final double score;

  const RatingScoreChangedEvent(this.score);

  @override
  List<Object?> get props => [score];
}

class TagToggledEvent extends RatingEvent {
  final String tag;

  const TagToggledEvent(this.tag);

  @override
  List<Object?> get props => [tag];
}

typedef RatingTagToggledEvent = TagToggledEvent;

class CommentChangedEvent extends RatingEvent {
  final String comment;

  const CommentChangedEvent(this.comment);

  @override
  List<Object?> get props => [comment];
}

typedef RatingCommentChangedEvent = CommentChangedEvent;

class SubmitRatingEvent extends RatingEvent {
  final String bookingId;
  final String targetId;
  final String targetName;
  final String? token;
  final String? driverId;

  const SubmitRatingEvent({
    required this.bookingId,
    this.targetId = '',
    this.targetName = '',
    this.token,
    this.driverId,
  });

  @override
  List<Object?> get props => [bookingId, targetId, targetName, token, driverId];
}



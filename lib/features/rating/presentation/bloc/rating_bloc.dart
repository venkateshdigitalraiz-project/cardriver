import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/rating_entity.dart';
import '../../domain/usecases/submit_rating_usecase.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final SubmitRatingUseCase submitRatingUseCase;

  RatingBloc({required this.submitRatingUseCase})
      : super(const RatingState()) {
    on<RatingScoreChangedEvent>(_onScoreChanged);
    on<TagToggledEvent>(_onTagToggled);
    on<CommentChangedEvent>(_onCommentChanged);
    on<SubmitRatingEvent>(_onSubmitRating);
  }

  void _onScoreChanged(
    RatingScoreChangedEvent event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(score: event.score));
  }

  void _onTagToggled(
    TagToggledEvent event,
    Emitter<RatingState> emit,
  ) {
    final updatedTags = List<String>.from(state.selectedTags);
    if (updatedTags.contains(event.tag)) {
      updatedTags.remove(event.tag);
    } else {
      updatedTags.add(event.tag);
    }
    emit(state.copyWith(selectedTags: updatedTags));
  }

  void _onCommentChanged(
    CommentChangedEvent event,
    Emitter<RatingState> emit,
  ) {
    emit(state.copyWith(comment: event.comment));
  }

  Future<void> _onSubmitRating(
    SubmitRatingEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(state.copyWith(
      status: RatingSubmissionStatus.submitting,
      clearError: true,
    ));

    try {
      final effectiveTargetId =
          event.targetId.isNotEmpty ? event.targetId : (event.driverId ?? '');
      final entity = RatingEntity(
        bookingId: event.bookingId,
        rating: state.score,
        comment: state.comment.trim(),
        tags: state.selectedTags,
        targetId: effectiveTargetId,
        targetName: event.targetName,
      );

      final result = await submitRatingUseCase.execute(
        rating: entity,
        token: event.token,
      );

      if (result) {
        emit(state.copyWith(
          status: RatingSubmissionStatus.success,
          successMessage: 'Rating submitted successfully! Thank you.',
        ));
      } else {
        emit(state.copyWith(
          status: RatingSubmissionStatus.error,
          errorMessage: 'Unable to submit rating. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: RatingSubmissionStatus.error,
        errorMessage: e.toString().replaceAll('Exception:', '').trim(),
      ));
    }
  }
}


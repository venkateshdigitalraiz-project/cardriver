import 'package:equatable/equatable.dart';

enum RatingSubmissionStatus {
  initial,
  submitting,
  success,
  error;

  bool get isLoading => this == RatingSubmissionStatus.submitting;
  bool get isSuccess => this == RatingSubmissionStatus.success;
  bool get isError => this == RatingSubmissionStatus.error;
}

typedef RatingStatus = RatingSubmissionStatus;

class RatingState extends Equatable {
  final double score;
  final List<String> selectedTags;
  final String comment;
  final RatingSubmissionStatus status;
  final String? errorMessage;
  final String? successMessage;

  const RatingState({
    this.score = 5.0,
    this.selectedTags = const [],
    this.comment = '',
    this.status = RatingSubmissionStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  RatingState copyWith({
    double? score,
    List<String>? selectedTags,
    String? comment,
    RatingSubmissionStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
  }) {
    return RatingState(
      score: score ?? this.score,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        score,
        selectedTags,
        comment,
        status,
        errorMessage,
        successMessage,
      ];
}


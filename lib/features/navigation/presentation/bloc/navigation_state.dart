import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  final int tabIndex;

  const NavigationState({this.tabIndex = 0});

  NavigationState copyWith({
    int? tabIndex,
  }) {
    return NavigationState(
      tabIndex: tabIndex ?? this.tabIndex,
    );
  }

  @override
  List<Object?> get props => [tabIndex];
}

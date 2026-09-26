import 'package:equatable/equatable.dart';

abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object> get props => [];
}

class WelcomePageChangedEvent extends WelcomeEvent {
  final int pageIndex;
  
  const WelcomePageChangedEvent(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

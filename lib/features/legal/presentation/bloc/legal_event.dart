import 'package:equatable/equatable.dart';

abstract class LegalEvent extends Equatable {
  const LegalEvent();

  @override
  List<Object> get props => [];
}

class LoadTermsEvent extends LegalEvent {}

class LoadPrivacyPolicyEvent extends LegalEvent {}

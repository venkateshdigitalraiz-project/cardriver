import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading driver profile from API along with menu items
class LoadProfileEvent extends ProfileEvent {
  final String? token;
  final bool silent;

  const LoadProfileEvent({this.token, this.silent = false});

  @override
  List<Object?> get props => [token, silent];
}

/// Refresh profile event e.g. on pull-to-refresh
class RefreshProfileEvent extends ProfileEvent {
  final String? token;

  const RefreshProfileEvent({this.token});

  @override
  List<Object?> get props => [token];
}

/// Kept for backwards compatibility
class LoadProfileMenuEvent extends ProfileEvent {
  final String? token;

  const LoadProfileMenuEvent({this.token});

  @override
  List<Object?> get props => [token];
}

/// Triggers opening WhatsApp helpline
class OpenWhatsAppHelplineEvent extends ProfileEvent {
  final String? customMessage;

  const OpenWhatsAppHelplineEvent({this.customMessage});

  @override
  List<Object?> get props => [customMessage];
}


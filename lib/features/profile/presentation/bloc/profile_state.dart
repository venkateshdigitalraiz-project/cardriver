import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_menu_item.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final List<ProfileMenuItem> menuItems;

  const ProfileLoaded({required this.menuItems});

  @override
  List<Object?> get props => [menuItems];
}

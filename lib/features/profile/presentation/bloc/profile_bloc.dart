import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_menu_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileMenuUseCase getProfileMenuUseCase;

  ProfileBloc({required this.getProfileMenuUseCase}) : super(ProfileInitial()) {
    on<LoadProfileMenuEvent>(_onLoadProfileMenuEvent);
  }

  void _onLoadProfileMenuEvent(
    LoadProfileMenuEvent event,
    Emitter<ProfileState> emit,
  ) {
    final menuItems = getProfileMenuUseCase.execute();
    emit(ProfileLoaded(menuItems: menuItems));
  }
}

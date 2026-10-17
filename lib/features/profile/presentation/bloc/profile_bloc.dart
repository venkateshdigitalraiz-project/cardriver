import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/usecases/get_driver_profile_usecase.dart';
import '../../domain/usecases/get_profile_menu_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetDriverProfileUseCase getDriverProfileUseCase;
  final GetProfileMenuUseCase getProfileMenuUseCase;
  final String? driverToken;

  ProfileBloc({
    required this.getDriverProfileUseCase,
    required this.getProfileMenuUseCase,
    this.driverToken,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<LoadProfileMenuEvent>(_onLoadProfileMenu);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final menuItems = getProfileMenuUseCase.execute();

    if (!event.silent) {
      emit(ProfileLoading(menuItems: menuItems));
    }

    try {
      final token = event.token ?? driverToken;
      final DriverProfileEntity profile = await getDriverProfileUseCase(
        GetDriverProfileParams(token: token),
      );

      emit(
        ProfileLoaded(
          driverProfile: profile,
          menuItems: menuItems,
        ),
      );
    } catch (e) {
      log('❌ [ProfileBloc] Failed to fetch driver profile: $e');
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      if (state is ProfileLoaded) {
        emit(
          (state as ProfileLoaded).copyWith(
            errorMessage: errorMsg,
            isRefreshing: false,
          ),
        );
      } else {
        // Fallback with loaded menu items so UI still functions
        emit(
          ProfileLoaded(
            driverProfile: null,
            menuItems: menuItems,
            errorMessage: errorMsg,
          ),
        );
      }
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isRefreshing: true, clearError: true));
    }
    add(LoadProfileEvent(token: event.token, silent: true));
  }

  Future<void> _onLoadProfileMenu(
    LoadProfileMenuEvent event,
    Emitter<ProfileState> emit,
  ) async {
    add(LoadProfileEvent(token: event.token));
  }
}

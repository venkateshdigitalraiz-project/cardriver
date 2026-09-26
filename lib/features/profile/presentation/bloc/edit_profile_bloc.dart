import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/pick_image_usecase.dart';
import '../../domain/usecases/get_address_usecase.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final PickImageUseCase pickImageUseCase;
  final GetAddressUseCase getAddressUseCase;

  EditProfileBloc({
    required this.pickImageUseCase,
    required this.getAddressUseCase,
  }) : super(const EditProfileFormState()) {
    on<PickDocumentEvent>(_onPickDocumentEvent);
    on<UpdateAddressEvent>(_onUpdateAddressEvent);
    on<FetchAddressEvent>(_onFetchAddressEvent);
    on<LoadProfileDataEvent>(_onLoadProfileDataEvent);
  }

  Future<void> _onPickDocumentEvent(
    PickDocumentEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    final currentState = state is EditProfileFormState
        ? state as EditProfileFormState
        : const EditProfileFormState();
        
    final imagePath = await pickImageUseCase.execute(event.source);
    
    if (imagePath != null) {
      switch (event.type) {
        case DocumentType.profilePhoto:
          emit(currentState.copyWith(profilePhotoPath: imagePath));
          break;
        case DocumentType.drivingLicenceFront:
          emit(currentState.copyWith(drivingLicenceFrontPath: imagePath));
          break;
        case DocumentType.drivingLicenceBack:
          emit(currentState.copyWith(drivingLicenceBackPath: imagePath));
          break;
        case DocumentType.aadhar:
          emit(currentState.copyWith(aadharPath: imagePath));
          break;
        case DocumentType.pan:
          emit(currentState.copyWith(panPath: imagePath));
          break;
      }
    } else {
      // Could emit an error, but usually we just ignore if they cancelled.
    }
  }

  void _onUpdateAddressEvent(
    UpdateAddressEvent event,
    Emitter<EditProfileState> emit,
  ) {
    final currentState = state is EditProfileFormState
        ? state as EditProfileFormState
        : const EditProfileFormState();
    emit(currentState.copyWith(address: event.address));
  }

  Future<void> _onFetchAddressEvent(
    FetchAddressEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    final currentState = state is EditProfileFormState
        ? state as EditProfileFormState
        : const EditProfileFormState();

    // Optionally emit a loading state here if needed

    final address = await getAddressUseCase.execute(
      event.latitude,
      event.longitude,
    );

    emit(currentState.copyWith(address: address));
  }

  Future<void> _onLoadProfileDataEvent(
    LoadProfileDataEvent event,
    Emitter<EditProfileState> emit,
  ) async {
    // In a real application, you would fetch this from a repository via a UseCase.
    // For now, we auto-fill it with standard mock details to satisfy the requirement
    // without changing the architecture pattern.
    emit(
      const EditProfileFormState(
        fullName: 'John Doe',
        phoneNumber: '+91 9876543210',
        email: 'johndoe@example.com',
        dob: '01/01/1990',
        aadharNumber: '1234 5678 9012',
        panNumber: 'ABCDE1234F',
        drivingLicenceNumber: 'DL-1420110012345',
        address: '123 Main Street, Bangalore, Karnataka',
      ),
    );
  }
}

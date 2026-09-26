import 'package:equatable/equatable.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();

  @override
  List<Object?> get props => [];
}

class EditProfileFormState extends EditProfileState {
  final String? profilePhotoPath;
  final String? drivingLicenceFrontPath;
  final String? drivingLicenceBackPath;
  final String? aadharPath;
  final String? panPath;
  final String? address;
  final String? fullName;
  final String? phoneNumber;
  final String? email;
  final String? dob;
  final String? aadharNumber;
  final String? panNumber;
  final String? drivingLicenceNumber;

  const EditProfileFormState({
    this.profilePhotoPath,
    this.drivingLicenceFrontPath,
    this.drivingLicenceBackPath,
    this.aadharPath,
    this.panPath,
    this.address,
    this.fullName,
    this.phoneNumber,
    this.email,
    this.dob,
    this.aadharNumber,
    this.panNumber,
    this.drivingLicenceNumber,
  });

  EditProfileFormState copyWith({
    String? profilePhotoPath,
    String? drivingLicenceFrontPath,
    String? drivingLicenceBackPath,
    String? aadharPath,
    String? panPath,
    String? address,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? dob,
    String? aadharNumber,
    String? panNumber,
    String? drivingLicenceNumber,
  }) {
    return EditProfileFormState(
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      drivingLicenceFrontPath: drivingLicenceFrontPath ?? this.drivingLicenceFrontPath,
      drivingLicenceBackPath: drivingLicenceBackPath ?? this.drivingLicenceBackPath,
      aadharPath: aadharPath ?? this.aadharPath,
      panPath: panPath ?? this.panPath,
      address: address ?? this.address,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      drivingLicenceNumber: drivingLicenceNumber ?? this.drivingLicenceNumber,
    );
  }

  @override
  List<Object?> get props => [
        profilePhotoPath,
        drivingLicenceFrontPath,
        drivingLicenceBackPath,
        aadharPath,
        panPath,
        address,
        fullName,
        phoneNumber,
        email,
        dob,
        aadharNumber,
        panNumber,
        drivingLicenceNumber,
      ];
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

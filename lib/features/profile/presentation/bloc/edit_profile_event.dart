import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  @override
  List<Object?> get props => [];
}

enum DocumentType {
  profilePhoto,
  drivingLicenceFront,
  drivingLicenceBack,
  aadhar,
  pan,
}

class PickDocumentEvent extends EditProfileEvent {
  final ImageSource source;
  final DocumentType type;

  const PickDocumentEvent({required this.source, required this.type});

  @override
  List<Object?> get props => [source, type];
}

class UpdateAddressEvent extends EditProfileEvent {
  final String address;

  const UpdateAddressEvent(this.address);

  @override
  List<Object?> get props => [address];
}

class FetchAddressEvent extends EditProfileEvent {
  final double latitude;
  final double longitude;

  const FetchAddressEvent(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}

class LoadProfileDataEvent extends EditProfileEvent {
  const LoadProfileDataEvent();

  @override
  List<Object?> get props => [];
}

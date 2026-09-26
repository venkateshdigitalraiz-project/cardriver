import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
// import '../../../../core/style/app_colors.dart';
import '../../domain/usecases/pick_image_usecase.dart';
import '../bloc/edit_profile_bloc.dart';
import '../bloc/edit_profile_event.dart';
import '../bloc/edit_profile_state.dart';
import 'location_picker_page.dart';

import 'package:latlong2/latlong.dart';
import '../../domain/usecases/get_address_usecase.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProfileBloc(
        pickImageUseCase: PickImageUseCase(),
        getAddressUseCase: GetAddressUseCase(),
      )..add(const LoadProfileDataEvent()),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)), // Dark blue
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: BlocBuilder<EditProfileBloc, EditProfileState>(
          builder: (context, state) {
            final formState = state is EditProfileFormState
                ? state
                : const EditProfileFormState();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePhotoSection(context, formState.profilePhotoPath),
                const SizedBox(height: 32),

                // --- Personal Information ---
                _buildSectionHeader(Icons.person, 'Personal Information'),
                const SizedBox(height: 16),
                _buildTextField('Full Name *', initialValue: formState.fullName, suffixIcon: null),
                const SizedBox(height: 16),
                _buildTextField(
                  'Phone Number *',
                  initialValue: formState.phoneNumber,
                  suffixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email Address *',
                  initialValue: formState.email,
                  suffixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Date of Birth (DOB)',
                  initialValue: formState.dob,
                  suffixIcon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 16),
                _buildAddressField(context, formState.address),

                const SizedBox(height: 32),

                // --- License & Documents ---
                _buildSectionHeader(Icons.description, 'License & Documents'),
                const SizedBox(height: 16),
                _buildTextField('Aadhar Number *', initialValue: formState.aadharNumber),
                const SizedBox(height: 12),
                _buildDocumentPicker(
                  context,
                  title: 'Aadhar Document',
                  type: DocumentType.aadhar,
                  path: formState.aadharPath,
                ),
                const SizedBox(height: 24),
                _buildTextField('PAN Card Number *', initialValue: formState.panNumber),
                const SizedBox(height: 12),
                _buildDocumentPicker(
                  context,
                  title: 'PAN Document',
                  type: DocumentType.pan,
                  path: formState.panPath,
                ),
                const SizedBox(height: 24),
                _buildTextField('Driving License Number *', initialValue: formState.drivingLicenceNumber),
                const SizedBox(height: 12),
                _buildDocumentPicker(
                  context,
                  title: 'Driving License (Front)',
                  type: DocumentType.drivingLicenceFront,
                  path: formState.drivingLicenceFrontPath,
                ),
                const SizedBox(height: 12),
                _buildDocumentPicker(
                  context,
                  title: 'Driving License (Back)',
                  type: DocumentType.drivingLicenceBack,
                  path: formState.drivingLicenceBackPath,
                ),

                const SizedBox(height: 32),

                // --- Address ---
                // _buildSectionHeader(Icons.location_on, 'Address'),
                // const SizedBox(height: 16),
                const SizedBox(height: 48), // Bottom padding
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label, {
    String? initialValue,
    IconData? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      key: Key(initialValue ?? label), // Key needed to rebuild when state updates initialValue
      initialValue: initialValue,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey)
            : null,
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildAddressField(BuildContext context, String? address) {
    return TextFormField(
      readOnly: true,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocationPickerPage()),
        );
        if (result != null && result is LatLng) {
          context.read<EditProfileBloc>().add(
                FetchAddressEvent(result.latitude, result.longitude),
              );
        }
      },
      key: Key(address ?? 'address'),
      initialValue: address,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: 'Address *',
        hintText: 'Tap to pick location on map',
        labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0066FF)),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildDocumentPicker(
    BuildContext context, {
    required String title,
    required DocumentType type,
    required String? path,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (sheetContext) {
                return SafeArea(
                  child: Wrap(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Select Image Source',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.photo_library,
                          color: Color(0xFF0066FF),
                        ),
                        title: const Text('Photo Gallery'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.read<EditProfileBloc>().add(
                            PickDocumentEvent(
                              source: ImageSource.gallery,
                              type: type,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.camera_alt,
                          color: Color(0xFF0066FF),
                        ),
                        title: const Text('Camera'),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          context.read<EditProfileBloc>().add(
                            PickDocumentEvent(
                              source: ImageSource.camera,
                              type: type,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: path != null
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.shade300,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.shade50.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Document Attached',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              path.split('/').last,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tap to upload document',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.upload_file,
                        color: Colors.grey.shade400,
                        size: 22,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoSection(BuildContext context, String? path) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade50,
                backgroundImage: path != null ? FileImage(File(path)) : null,
                child: path == null
                    ? Icon(Icons.person, size: 40, color: Colors.blue.shade200)
                    : null,
              ),
            ),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (sheetContext) {
                    return SafeArea(
                      child: Wrap(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'Select Profile Photo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.photo_library,
                              color: Color(0xFF0066FF),
                            ),
                            title: const Text('Photo Gallery'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              context.read<EditProfileBloc>().add(
                                const PickDocumentEvent(
                                  source: ImageSource.gallery,
                                  type: DocumentType.profilePhoto,
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF0066FF),
                            ),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              context.read<EditProfileBloc>().add(
                                const PickDocumentEvent(
                                  source: ImageSource.camera,
                                  type: DocumentType.profilePhoto,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change Photo',
                style: TextStyle(
                  color: Color(0xFF0066FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload a clear photo\n(Recommended size: 1:1)',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

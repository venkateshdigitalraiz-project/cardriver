import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../data/models/driver_register_body.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/document_upload_tile.dart';
import '../../../documents/presentation/pages/documents_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Personal Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  // Legal & ID Numbers
  final _licenseNumberController = TextEditingController();
  final _aadharController = TextEditingController();
  final _panController = TextEditingController();
  final _passportController = TextEditingController();

  // Attached Document Files
  File? _profilePicFile;
  File? _aadharFrontFile;
  File? _aadharBackFile;
  File? _drivingLicenseFile;
  File? _panCardFile;
  File? _passportFile;

  // Validation state flags
  bool _obscurePassword = true;
  bool _termsAgreed = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _aadharController.dispose();
    _panController.dispose();
    _passportController.dispose();
    super.dispose();
  }

  /// Explicitly defines and constructs the API request body matching the cURL specification:
  /// POST http://192.168.0.161:3000/api/driver/register
  ///
  /// Text form fields:
  /// - firstName, lastName, email, phone, address, licenseNumber, pancardNumber, aadhaarNumber, passportId
  /// Multipart file fields:
  /// - pancard, aadhaarCardFront, aadhaarCardBack, drivingLicense, selfie, passport
  DriverRegisterBody _buildApiRequestBody() {
    return DriverRegisterBody(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      licenseNumber: _licenseNumberController.text.trim(),
      pancardNumber: _panController.text.trim().toUpperCase(),
      aadhaarNumber: _aadharController.text.trim(),
      passportId: _passportController.text.trim().toUpperCase(),
      pancard: _panCardFile?.path,
      aadhaarCardFront: _aadharFrontFile?.path,
      aadhaarCardBack: _aadharBackFile?.path,
      drivingLicense: _drivingLicenseFile?.path,
      selfie: _profilePicFile?.path,
      passport: _passportFile?.path,
      password: _passwordController.text,
    );
  }

  /// Request body map representation for inspection, logging, or debugging matching the cURL spec
  Map<String, dynamic> get apiRequestBody => _buildApiRequestBody().toMap();

  void _onRegisterSubmit() {
    if (!_termsAgreed) {
      AppSnackBar.showError(
        context,
        'Please accept the Terms of Service & Privacy Policy to continue.',
      );
      return;
    }

    // Trigger form validation to highlight errors on screen
    final isFormValid = _formKey.currentState?.validate() ?? false;

    // Explicit validation check in sequence for clear feedback
    final firstNameErr = InputValidators.validateFirstName(
      _firstNameController.text,
    );
    if (firstNameErr != null) {
      AppSnackBar.showError(context, firstNameErr);
      return;
    }

    final lastNameErr = InputValidators.validateLastName(
      _lastNameController.text,
    );
    if (lastNameErr != null) {
      AppSnackBar.showError(context, lastNameErr);
      return;
    }

    final emailErr = InputValidators.validateEmail(_emailController.text);
    if (emailErr != null) {
      AppSnackBar.showError(context, emailErr);
      return;
    }

    final phoneErr = InputValidators.validatePhone(_phoneController.text);
    if (phoneErr != null) {
      AppSnackBar.showError(context, phoneErr);
      return;
    }

    final passwordErr = InputValidators.validatePassword(
      _passwordController.text,
    );
    if (passwordErr != null) {
      AppSnackBar.showError(context, passwordErr);
      return;
    }

    final addressErr = InputValidators.validateAddress(_addressController.text);
    if (addressErr != null) {
      AppSnackBar.showError(context, addressErr);
      return;
    }

    final licenseErr = InputValidators.validateLicenseNumber(
      _licenseNumberController.text,
    );
    if (licenseErr != null) {
      AppSnackBar.showError(context, licenseErr);
      return;
    }

    final aadharErr = InputValidators.validateAadhar(_aadharController.text);
    if (aadharErr != null) {
      AppSnackBar.showError(context, aadharErr);
      return;
    }

    final panErr = InputValidators.validatePan(
      _panController.text,
      isRequired: true,
    );
    if (panErr != null) {
      AppSnackBar.showError(context, panErr);
      return;
    }

    final passportErr = InputValidators.validatePassport(
      _passportController.text,
      isRequired: true,
    );
    if (passportErr != null) {
      AppSnackBar.showError(context, passportErr);
      return;
    }

    if (!isFormValid) {
      AppSnackBar.showError(
        context,
        'Please fill in all mandatory fields with valid information.',
      );
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = '$firstName $lastName'.trim();

    // Explicitly construct API request body matching the cURL specification
    final body = _buildApiRequestBody();

    context.read<AuthBloc>().add(
      RegisterDriverEvent(
        body: body,
        firstName: body.firstName,
        lastName: body.lastName,
        name: fullName.isNotEmpty ? fullName : 'Driver',
        email: body.email,
        phone: body.phone,
        password: body.password ?? '',
        address: body.address,
        licenseNumber: body.licenseNumber,
        pancardNumber: body.pancardNumber,
        aadhaarNumber: body.aadhaarNumber,
        passportId: body.passportId,
        pancard: body.pancard,
        aadhaarCardFront: body.aadhaarCardFront,
        aadhaarCardBack: body.aadhaarCardBack,
        drivingLicense: body.drivingLicense,
        selfie: body.selfie,
        passport: body.passport,
        aadharNumber: body.aadhaarNumber,
        panNumber: body.pancardNumber,
        passportNumber: body.passportId,
        aadharFrontPath: body.aadhaarCardFront,
        aadharBackPath: body.aadhaarCardBack,
        panCardPath: body.pancard,
        drivingLicensePath: body.drivingLicense,
        passportPath: body.passport,
        profilePicPath: body.selfie,
      ),
    );
  }

  Future<void> _showDocumentSourcePicker({
    required String title,
    required File? currentFile,
    required ValueChanged<File?> onFileSelected,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Upload $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose source with clear lighting and readable text',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // Camera Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFFE5A600),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Use device camera to capture document',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.black38,
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final file = await MediaPermissionHelper.pickImage(
                      context: context,
                      source: ImageSource.camera,
                    );
                    if (file != null) {
                      setState(() {
                        onFileSelected(file);
                      });
                    }
                  },
                ),
                const Divider(height: 16),

                // Gallery Option
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF0066FF),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: const Text(
                    'Select existing image from photo library',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.black38,
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final file = await MediaPermissionHelper.pickImage(
                      context: context,
                      source: ImageSource.gallery,
                    );
                    if (file != null) {
                      setState(() {
                        onFileSelected(file);
                      });
                    }
                  },
                ),

                // Remove Option (if document already chosen)
                if (currentFile != null) ...[
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Remove Attached Document',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      setState(() {
                        onFileSelected(null);
                      });
                    },
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePreview(File file, String title) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.65,
                      ),
                      child: Image.file(file, fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.error && state.errorMessage != null) {
          AppSnackBar.showError(context, state.errorMessage!);
        } else if (state.status == AuthStatus.authenticated) {
          final driverName =
              state.driver?.name ?? state.customer?.name ?? 'Driver';
          AppSnackBar.showSuccess(
            context,
            'Registration successful! Welcome, $driverName!',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DocumentsPage()),
          );
        }
      },
      builder: (context, state) {
        const aadharFrontMissing = false;
        const aadharBackMissing = false;
        const licenseFileMissing = false;

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                // Top Hero Banner
                SizedBox(
                  height: size.height * 0.32,
                  width: double.infinity,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/car_driver.jpg'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.75),
                            Colors.black.withValues(alpha: 0.35),
                            AppColors.darkBackground.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back Button
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE94E34),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Positioned(
                                        left: 8,
                                        child: Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFFF2A33A,
                                            ).withValues(alpha: 0.9),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Driver Registration',
                                      style: TextStyle(
                                        fontSize: 26,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Enter details & upload verification documents',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Content Card
                Container(
                  margin: EdgeInsets.only(top: size.height * 0.28),
                  constraints: BoxConstraints(minHeight: size.height * 0.72),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Profile Picture Section ---
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              GestureDetector(
                                onTap: () => _showDocumentSourcePicker(
                                  title: 'Profile Picture',
                                  currentFile: _profilePicFile,
                                  onFileSelected: (f) => _profilePicFile = f,
                                ),
                                child: Container(
                                  width: 94,
                                  height: 94,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFFB800),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _profilePicFile != null
                                        ? Image.file(
                                            _profilePicFile!,
                                            width: 94,
                                            height: 94,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: const Color(0xFFF1F5F9),
                                            child: const Icon(
                                              Icons.person_rounded,
                                              size: 52,
                                              color: Color(0xFFCBD5E1),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showDocumentSourcePicker(
                                    title: 'Profile Picture',
                                    currentFile: _profilePicFile,
                                    onFileSelected: (f) => _profilePicFile = f,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFB800),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Profile Picture (Optional)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 1: Personal Details Header
                        _buildSectionHeader(
                          icon: Icons.person_outline_rounded,
                          title: 'Personal Information',
                        ),
                        const SizedBox(height: 14),

                        // First Name & Last Name (Side by Side)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                labelText: 'First Name *',
                                hintText: 'David',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: InputValidators.validateFirstName,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                labelText: 'Last Name *',
                                hintText: 'Miller',
                                prefixIcon: Icons.person_outline_rounded,
                                validator: InputValidators.validateLastName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        _buildTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number *',
                          hintText: '1234567890',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: InputValidators.validatePhone,
                        ),
                        const SizedBox(height: 16),

                        // Email Address
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'Email Address *',
                          hintText: 'driver@cardriver.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: InputValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildTextField(
                          controller: _passwordController,
                          labelText: 'Password *',
                          hintText: '••••••••',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: InputValidators.validatePassword,
                        ),
                        const SizedBox(height: 16),

                        // Address
                        _buildTextField(
                          controller: _addressController,
                          labelText: 'Address *',
                          hintText: 'e.g. 123 Main Street, Bangalore',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 1,
                          validator: InputValidators.validateAddress,
                        ),
                        const SizedBox(height: 28),

                        // Section 2: Identity & Legal Numbers
                        _buildSectionHeader(
                          icon: Icons.badge_outlined,
                          title: 'Identity & Legal Numbers',
                        ),
                        const SizedBox(height: 14),

                        // Driving License Number
                        _buildTextField(
                          controller: _licenseNumberController,
                          labelText: 'Driving License Number *',
                          hintText: 'e.g. DL-1420110012345',
                          prefixIcon: Icons.drive_eta_outlined,
                          textCapitalization: TextCapitalization.characters,
                          validator: InputValidators.validateLicenseNumber,
                        ),
                        const SizedBox(height: 16),

                        // Aadhaar Number *
                        _buildTextField(
                          controller: _aadharController,
                          labelText: 'Aadhaar Number *',
                          hintText: '12-digit Aadhaar number',
                          prefixIcon: Icons.fingerprint_rounded,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12),
                          ],
                          validator: InputValidators.validateAadhar,
                        ),
                        const SizedBox(height: 16),

                        // PAN Card Number *
                        _buildTextField(
                          controller: _panController,
                          labelText: 'PAN Card Number *',
                          hintText: 'e.g. ABCDE1234F',
                          prefixIcon: Icons.credit_card_rounded,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 10,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (val) => InputValidators.validatePan(
                            val,
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Passport ID *
                        _buildTextField(
                          controller: _passportController,
                          labelText: 'Passport ID *',
                          hintText: 'e.g. A1234567',
                          prefixIcon: Icons.flight_takeoff_rounded,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 12,
                          validator: (val) => InputValidators.validatePassport(
                            val,
                            isRequired: true,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Section 3: Document Attachments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.attach_file_rounded,
                              title: 'Verification Documents',
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFB800,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '3 Required',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Upload original photos or scans. Ensure all 4 corners and text are clearly visible.',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),

                        // 1. Aadhaar Card Front *
                        DocumentUploadTile(
                          title: 'Aadhaar Card (Front)',
                          subtitle: 'Upload photo of front side with photo',
                          isRequired: true,
                          file: _aadharFrontFile,
                          icon: Icons.badge_outlined,
                          hasError: aadharFrontMissing,
                          errorMessage: 'Aadhaar front document is required',
                          onTap: () => _showDocumentSourcePicker(
                            title: 'Aadhaar Card (Front)',
                            currentFile: _aadharFrontFile,
                            onFileSelected: (f) => _aadharFrontFile = f,
                          ),
                          onRemove: () => setState(() {
                            _aadharFrontFile = null;
                          }),
                          onPreview: _aadharFrontFile != null
                              ? () => _showImagePreview(
                                  _aadharFrontFile!,
                                  'Aadhaar Card (Front)',
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // 2. Aadhaar Card Back *
                        DocumentUploadTile(
                          title: 'Aadhaar Card (Back)',
                          subtitle: 'Upload photo of back side with address',
                          isRequired: true,
                          file: _aadharBackFile,
                          icon: Icons.badge_outlined,
                          hasError: aadharBackMissing,
                          errorMessage: 'Aadhaar back document is required',
                          onTap: () => _showDocumentSourcePicker(
                            title: 'Aadhaar Card (Back)',
                            currentFile: _aadharBackFile,
                            onFileSelected: (f) => _aadharBackFile = f,
                          ),
                          onRemove: () => setState(() {
                            _aadharBackFile = null;
                          }),
                          onPreview: _aadharBackFile != null
                              ? () => _showImagePreview(
                                  _aadharBackFile!,
                                  'Aadhaar Card (Back)',
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // 3. Driving License *
                        DocumentUploadTile(
                          title: 'Driving Licence',
                          subtitle:
                              'Upload clear photo of valid driving licence',
                          isRequired: true,
                          file: _drivingLicenseFile,
                          icon: Icons.drive_eta_rounded,
                          hasError: licenseFileMissing,
                          errorMessage: 'Driving licence document is required',
                          onTap: () => _showDocumentSourcePicker(
                            title: 'Driving Licence',
                            currentFile: _drivingLicenseFile,
                            onFileSelected: (f) => _drivingLicenseFile = f,
                          ),
                          onRemove: () => setState(() {
                            _drivingLicenseFile = null;
                          }),
                          onPreview: _drivingLicenseFile != null
                              ? () => _showImagePreview(
                                  _drivingLicenseFile!,
                                  'Driving Licence',
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // 4. PAN Card (Optional)
                        DocumentUploadTile(
                          title: 'PAN Card',
                          subtitle: 'Upload photo of PAN card (optional)',
                          isRequired: false,
                          file: _panCardFile,
                          icon: Icons.credit_card_rounded,
                          onTap: () => _showDocumentSourcePicker(
                            title: 'PAN Card',
                            currentFile: _panCardFile,
                            onFileSelected: (f) => _panCardFile = f,
                          ),
                          onRemove: () => setState(() {
                            _panCardFile = null;
                          }),
                          onPreview: _panCardFile != null
                              ? () =>
                                    _showImagePreview(_panCardFile!, 'PAN Card')
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // 5. Passport (Optional)
                        DocumentUploadTile(
                          title: 'Passport',
                          subtitle: 'Upload photo page of passport (optional)',
                          isRequired: false,
                          file: _passportFile,
                          icon: Icons.flight_takeoff_rounded,
                          onTap: () => _showDocumentSourcePicker(
                            title: 'Passport',
                            currentFile: _passportFile,
                            onFileSelected: (f) => _passportFile = f,
                          ),
                          onRemove: () => setState(() {
                            _passportFile = null;
                          }),
                          onPreview: _passportFile != null
                              ? () => _showImagePreview(
                                  _passportFile!,
                                  'Passport',
                                )
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Terms & Conditions Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: Checkbox(
                                value: _termsAgreed,
                                activeColor: const Color(0xFFFFB800),
                                checkColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1.5,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _termsAgreed = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _termsAgreed = !_termsAgreed;
                                  });
                                },
                                child: const Text(
                                  'I agree to the Terms of Service & Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF475569),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Register Submit Button
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: state.isLoading
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFFFB800),
                                      Color(0xFFFF9800),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            color: state.isLoading ? Colors.grey[300] : null,
                            boxShadow: state.isLoading
                                ? null
                                : [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFFB800,
                                      ).withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                          ),
                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : _onRegisterSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: state.isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black87,
                                      ),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Submit Registration',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Already have an account? Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE5A600),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE5A600)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String labelText, {bool? isRequired}) {
    final bool hasAsterisk = labelText.contains('*') || (isRequired ?? false);
    final String cleanTitle = labelText.replaceAll('*', '').trimRight();

    if (hasAsterisk) {
      return Text.rich(
        TextSpan(
          text: cleanTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFE53935), // Vibrant Red Asterisk
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool? isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(labelText, isRequired: isRequired),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFFE5A600),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFFB800),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

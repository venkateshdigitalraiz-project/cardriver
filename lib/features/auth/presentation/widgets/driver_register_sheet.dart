import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/driver_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class DriverRegisterSheet extends StatefulWidget {
  const DriverRegisterSheet({super.key});

  @override
  State<DriverRegisterSheet> createState() => _DriverRegisterSheetState();
}

class _DriverRegisterSheetState extends State<DriverRegisterSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  DriverServiceType _selectedServiceType = DriverServiceType.taxi;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  void _onRegisterSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
      Navigator.of(context).pop(); // Close sheet
      context.read<AuthBloc>().add(
            RegisterDriverEvent(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              name: fullName,
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              vehicleModel: _vehicleModelController.text.trim(),
              vehiclePlate: _vehiclePlateController.text.trim(),
              serviceType: _selectedServiceType,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkCardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.app_registration_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver Partner Registration', style: AppTypography.headingMedium()),
                      Text('Register your vehicle & start driving', style: AppTypography.bodySmall(color: AppColors.textMutedDark)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // First Name & Last Name in a Side-by-Side Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      labelText: 'First Name',
                      hintText: 'e.g. David',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      labelText: 'Last Name',
                      hintText: 'e.g. Miller',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Email
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                hintText: 'driver@cardriver.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20),
                validator: InputValidators.validateEmail,
              ),
              const SizedBox(height: 14),

              // Mobile Phone
              CustomTextField(
                controller: _phoneController,
                labelText: 'Mobile Phone',
                hintText: '+1 555-012-3456',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                validator: InputValidators.validatePhone,
              ),
              const SizedBox(height: 14),

              // Vehicle Model & Plate
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      controller: _vehicleModelController,
                      labelText: 'Vehicle Model',
                      hintText: 'e.g. Toyota Camry',
                      prefixIcon: const Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 20),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Vehicle model required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _vehiclePlateController,
                      labelText: 'License Plate',
                      hintText: 'e.g. TX-9900',
                      textCapitalization: TextCapitalization.characters,
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Plate required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Service Fleet Category
              Text('Service Fleet Category', style: AppTypography.inputLabel()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: DriverServiceType.values.map((type) {
                  final isSelected = _selectedServiceType == type;
                  return ChoiceChip(
                    label: Text(
                      type.name.toUpperCase(),
                      style: AppTypography.bodySmall(
                        color: isSelected ? AppColors.black : AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.darkInputFill,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.darkCardBorder,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedServiceType = type;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Password
              CustomTextField(
                controller: _passwordController,
                labelText: 'Create Driver Password',
                hintText: 'Minimum 6 characters',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                validator: InputValidators.validatePassword,
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomElevatedButton(
                text: 'Submit Application & Join',
                icon: Icons.check_rounded,
                onPressed: _onRegisterSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

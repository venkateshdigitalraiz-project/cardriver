import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class CustomerRegisterSheet extends StatefulWidget {
  const CustomerRegisterSheet({super.key});

  @override
  State<CustomerRegisterSheet> createState() => _CustomerRegisterSheetState();
}

class _CustomerRegisterSheetState extends State<CustomerRegisterSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  CustomerPaymentMethod _selectedPayment = CustomerPaymentMethod.card;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      context.read<AuthBloc>().add(
            RegisterCustomerEvent(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              preferredPayment: _selectedPayment,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF10B981), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Passenger Account',
                        style: AppTypography.headingMedium(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Sign up to book rides & track drivers',
                        style: AppTypography.bodySmall(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // First Name & Last Name Side by Side
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      labelText: 'First Name',
                      hintText: 'e.g. Sarah',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF10B981), size: 20),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      labelText: 'Last Name',
                      hintText: 'e.g. Jenkins',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF10B981), size: 20),
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
                hintText: 'sarah@example.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF10B981), size: 20),
                validator: InputValidators.validateEmail,
              ),
              const SizedBox(height: 14),

              // Mobile Phone
              CustomTextField(
                controller: _phoneController,
                labelText: 'Mobile Phone',
                hintText: '+1 555-901-2345',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981), size: 20),
                validator: InputValidators.validatePhone,
              ),
              const SizedBox(height: 14),

              // Preferred Payment Method
              Text(
                'Preferred Payment Method',
                style: AppTypography.inputLabel(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: CustomerPaymentMethod.values.map((method) {
                  final isSelected = _selectedPayment == method;
                  return ChoiceChip(
                    label: Text(
                      method.name.toUpperCase(),
                      style: AppTypography.bodySmall(
                        color: isSelected
                            ? AppColors.white
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF10B981)
                          : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPayment = method;
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
                labelText: 'Create Password',
                hintText: 'Minimum 6 characters',
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF10B981), size: 20),
                validator: InputValidators.validatePassword,
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomElevatedButton(
                text: 'Create Account & Start Riding',
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: const Color(0xFF10B981),
                useGradient: false,
                onPressed: _onRegisterSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../bloc/onboarding_bloc.dart';
import 'document_upload_page.dart';

class OnboardingPage extends StatelessWidget {
  final CustomerEntity customer;

  const OnboardingPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(),
      child: _OnboardingView(customer: customer),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  final CustomerEntity customer;

  const _OnboardingView({required this.customer});

  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF135029);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload your Information',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Personal ID proof',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 32),
              _buildLabeledTextField('Full Name (Driving License)', 'Enter full name as per your driving license', darkGreen, isRequired: true),
              const SizedBox(height: 16),
              _buildLabeledTextField('Email ID (Optional)', 'xxxx@xxxxx.com', darkGreen, isRequired: false),
              const SizedBox(height: 16),
              _buildLabeledTextField('DOB', 'yyyy-mm-dd', darkGreen, isRequired: true),
              const SizedBox(height: 16),
              _buildLabeledTextField('PAN Account number', 'eg: ABCVP89765', darkGreen, isRequired: true),
              const SizedBox(height: 16),
              _buildLabeledTextField('Driving Licence number', 'eg: XXXXXXXXXXXXXXX', darkGreen, isRequired: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildLabeledTextField('Issue Date', 'yyyy-mm-dd', darkGreen, isRequired: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildLabeledTextField('Expiry Date', 'yyyy-mm-dd', darkGreen, isRequired: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabeledTextField('Referred By (Optional) :', 'eg: XXXXXXXXXXXXXXX', darkGreen, isRequired: false),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DocumentUploadPage(customer: widget.customer),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  elevation: 0,
                ),
                child: const Text(
                  'CONTINUE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(String label, String hint, Color labelColor, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(color: Colors.black),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: labelColor),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

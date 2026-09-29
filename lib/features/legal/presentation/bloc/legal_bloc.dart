import 'package:flutter_bloc/flutter_bloc.dart';
import 'legal_event.dart';
import 'legal_state.dart';
import '../../domain/entities/legal_document.dart';

class LegalBloc extends Bloc<LegalEvent, LegalState> {
  LegalBloc() : super(LegalInitial()) {
    on<LoadTermsEvent>(_onLoadTerms);
    on<LoadPrivacyPolicyEvent>(_onLoadPrivacyPolicy);
  }

  Future<void> _onLoadTerms(LoadTermsEvent event, Emitter<LegalState> emit) async {
    emit(LegalLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate fetch
      final termsDocument = LegalDocument(
        title: 'Terms & Conditions',
        content: '''1. Acceptance of Terms
By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.

2. Driver Responsibilities
As a driver, you are expected to maintain a professional demeanor, ensure your vehicle is safe and clean, and adhere to all local traffic laws.

3. Payments & Fees
Earnings are calculated based on distance, time, and dynamic pricing factors. A service fee will be deducted from total earnings.

4. Account Termination
We reserve the right to suspend or terminate accounts that violate these terms or exhibit fraudulent behavior.

5. Modifications
These terms may be updated from time to time. Continued use of the app constitutes acceptance of the new terms.''',
        lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
      );
      emit(LegalLoaded(termsDocument));
    } catch (e) {
      emit(LegalError('Failed to load terms: $e'));
    }
  }

  Future<void> _onLoadPrivacyPolicy(LoadPrivacyPolicyEvent event, Emitter<LegalState> emit) async {
    emit(LegalLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate fetch
      final privacyDocument = LegalDocument(
        title: 'Privacy Policy',
        content: '''1. Information Collection
We collect personal information such as name, contact details, payment info, and real-time location data necessary for providing ride services.

2. Use of Information
Your data is used to connect you with riders, process payments, improve our services, and ensure safety.

3. Data Sharing
We do not sell your data. Information is only shared with third parties for essential operational services (e.g., payment processing) or when required by law.

4. Data Security
We implement industry-standard security measures to protect your personal information from unauthorized access or disclosure.

5. Your Rights
You have the right to access, correct, or delete your personal data within the app settings or by contacting support.''',
        lastUpdated: DateTime.now().subtract(const Duration(days: 15)),
      );
      emit(LegalLoaded(privacyDocument));
    } catch (e) {
      emit(LegalError('Failed to load privacy policy: $e'));
    }
  }
}

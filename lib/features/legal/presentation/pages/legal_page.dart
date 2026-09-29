import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/legal_bloc.dart';
import '../bloc/legal_event.dart';
import '../bloc/legal_state.dart';

enum LegalPageType { terms, privacy }

class LegalPage extends StatelessWidget {
  final LegalPageType pageType;

  const LegalPage({super.key, required this.pageType});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = LegalBloc();
        if (pageType == LegalPageType.terms) {
          bloc.add(LoadTermsEvent());
        } else {
          bloc.add(LoadPrivacyPolicyEvent());
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            pageType == LegalPageType.terms ? 'Terms & Conditions' : 'Privacy Policy',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<LegalBloc, LegalState>(
          builder: (context, state) {
            if (state is LegalLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
            } else if (state is LegalLoaded) {
              final doc = state.document;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: ${doc.lastUpdated.day}/${doc.lastUpdated.month}/${doc.lastUpdated.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      doc.content,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            } else if (state is LegalError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

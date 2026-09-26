import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../navigation/presentation/pages/main_navigator_page.dart';
import '../bloc/welcome_bloc.dart';
import '../bloc/welcome_event.dart';
import '../bloc/welcome_state.dart';
import 'onboarding_page.dart';

class WelcomePage extends StatelessWidget {
  final CustomerEntity customer;

  const WelcomePage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WelcomeBloc(),
      child: _WelcomeView(customer: customer),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final CustomerEntity customer;
  final PageController _pageController = PageController();

  _WelcomeView({required this.customer});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF135029);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => MainNavigatorPage(customer: customer),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Training Center',
                      style: TextStyle(
                        color: darkGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Logo & Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   children: [
                  //     const Text(
                  //       'DRIVE',
                  //       style: TextStyle(
                  //         fontSize: 28,
                  //         fontWeight: FontWeight.w900,
                  //         color: Colors.black87,
                  //       ),
                  //     ),
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  //       decoration: BoxDecoration(
                  //         color: Colors.teal.shade300,
                  //         borderRadius: BorderRadius.circular(4),
                  //       ),
                  //       child: const Text(
                  //         'U',
                  //         style: TextStyle(
                  //           fontSize: 24,
                  //           fontWeight: FontWeight.w900,
                  //           color: darkGreen,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const Text(
                    'DRIVE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Private Car Driver',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to Driver',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel
            Expanded(
              child: BlocBuilder<WelcomeBloc, WelcomeState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            context.read<WelcomeBloc>().add(
                              WelcomePageChangedEvent(index),
                            );
                          },
                          children: [
                            _buildTestimonialPage(),
                            _buildTestimonialPage(), // Dummy copies for carousel
                            _buildTestimonialPage(),
                            _buildTestimonialPage(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: state.currentPage == index
                                  ? darkGreen
                                  : Colors.grey.shade400,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OnboardingPage(customer: customer),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'JOIN AS A DRIVER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black,
            child: CircleAvatar(
              radius: 38,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400&auto=format&fit=crop&q=80',
              ),
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            'Shahenshah Babar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF135029),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'I got my sister married in 2023 and had taken loans for the wedding. I was worried about how I would repay the EMIs, but thanks to DriveU, I\'ve been able to manage my repayments while taking care of my family. Sometimes I wonder',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF135029),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

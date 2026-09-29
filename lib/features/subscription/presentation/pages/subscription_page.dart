import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F9FA),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'Manage Your Plan & Benefits',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.headset_mic_outlined,
                      color: Color(0xFF0066FF),
                      size: 16,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Need Help?',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: const _SubscriptionView(),
        bottomNavigationBar: const _BottomSubscribeBar(),
      ),
    );
  }
}

class _SubscriptionView extends StatelessWidget {
  const _SubscriptionView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          // Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/subscription.png',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),

          // Choose Your Plan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF4D4F),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Most Popular',
                      style: TextStyle(
                        color: Color(0xFFFF4D4F),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, state) {
              final selectedPlanId = state is SubscriptionInitial
                  ? state.selectedPlanId
                  : 'premium';
              final currentPlanId = state is SubscriptionInitial
                  ? state.currentPlanId
                  : 'premium';

              return Column(
                children: [
                  _PlanCard(
                    id: 'premium',
                    title: 'Premium Plan',
                    subtitle: 'Best value for active drivers',
                    price: '₹499',
                    features: const [
                      'Lower Commission',
                      'Priority Support',
                      'Exclusive Offers',
                    ],
                    icon: Icons.workspace_premium,
                    themeColor: Colors.amber,
                    isSelected: selectedPlanId == 'premium',
                    isCurrentPlan: currentPlanId == 'premium',
                    isPremium: true,
                    onTap: () => context.read<SubscriptionBloc>().add(
                      const SelectSubscriptionPlanEvent('premium'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    id: 'standard',
                    title: 'Standard Plan',
                    subtitle: 'Great for everyday driving',
                    price: '₹299',
                    features: const [
                      'Normal Commission',
                      'Standard Support',
                      'Special Offers',
                    ],
                    icon: Icons.star,
                    themeColor: Colors.grey.shade500,
                    isSelected: selectedPlanId == 'standard',
                    isCurrentPlan: currentPlanId == 'standard',
                    onTap: () => context.read<SubscriptionBloc>().add(
                      const SelectSubscriptionPlanEvent('standard'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    id: 'basic',
                    title: 'Basic Plan',
                    subtitle: 'Essential benefits to keep you moving',
                    price: '₹149',
                    features: const [
                      'Standard Commission',
                      'Email Support',
                      'Limited Offers',
                    ],
                    icon: Icons.shield,
                    themeColor: Colors.blue,
                    isSelected: selectedPlanId == 'basic',
                    isCurrentPlan: currentPlanId == 'basic',
                    onTap: () => context.read<SubscriptionBloc>().add(
                      const SelectSubscriptionPlanEvent('basic'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Subscription Benefits
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Light grayish blue
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Benefits',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _BenefitItem(
                        icon: Icons.percent,
                        title: 'Lower\nCommission',
                        subtitle: 'Keep more\nof your earnings',
                        color: const Color(0xFF10B981), // Green
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _BenefitItem(
                        icon: Icons.headset_mic,
                        title: 'Priority\nSupport',
                        subtitle: 'Faster help,\nless downtime',
                        color: const Color(0xFF3B82F6), // Blue
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _BenefitItem(
                        icon: Icons.card_giftcard,
                        title: 'Exclusive\nOffers',
                        subtitle: 'Special bonuses\n& rewards',
                        color: const Color(0xFFA855F7), // Purple
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _BenefitItem(
                        icon: Icons.workspace_premium,
                        title: 'Higher\nPriority',
                        subtitle: 'Get more ride\nrequests',
                        color: const Color(0xFFF59E0B), // Orange/Amber
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
  final IconData icon;
  final Color themeColor;
  final bool isSelected;
  final bool isPremium;
  final bool isCurrentPlan;
  final VoidCallback onTap;

  const _PlanCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.features,
    required this.icon,
    required this.themeColor,
    required this.isSelected,
    this.isPremium = false,
    this.isCurrentPlan = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isPremium ? Colors.amber : const Color(0xFF0066FF))
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: themeColor, size: 28),
                ),
                if (isPremium) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isCurrentPlan)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                'CURRENT PLAN',
                                style: TextStyle(
                                  color: const Color(0xFF10B981), // Green
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                price,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const Text(
                                ' / month',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (isPremium)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Save 16%',
                                style: TextStyle(
                                  color: Colors.amber.shade900,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: features.map((feature) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color(0xFF10B981),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            feature,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Radio button
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? (isPremium ? Colors.amber : const Color(0xFF0066FF))
                  : Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 9,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _BottomSubscribeBar extends StatelessWidget {
  const _BottomSubscribeBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              // Action for Subscribe Now
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF021B45), // Dark blue
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Subscribe Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

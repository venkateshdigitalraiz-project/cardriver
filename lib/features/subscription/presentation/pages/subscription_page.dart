import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../subscription_history/presentation/pages/subscription_history_page.dart';
import '../../domain/entities/subscription_activation_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../bloc/subscription_bloc.dart';
import '../bloc/subscription_event.dart';
import '../bloc/subscription_state.dart';

class SubscriptionPage extends StatelessWidget {
  final String? driverToken;

  const SubscriptionPage({super.key, this.driverToken});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.createSubscriptionBloc(
        driverToken: driverToken,
      )..add(LoadSubscriptionPlansEvent(token: driverToken)),
      child: _SubscriptionScaffold(driverToken: driverToken),
    );
  }
}

class _SubscriptionScaffold extends StatelessWidget {
  final String? driverToken;

  const _SubscriptionScaffold({this.driverToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Plans',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '0% Commission • Keep 100% Earnings',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Subscription History',
            icon: const Icon(
              Icons.history_rounded,
              color: Color(0xFF021B45),
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SubscriptionHistoryPage(driverToken: driverToken),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.plans.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.activationErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.activationErrorMessage!)),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          if (state.activationResult != null) {
            _showActivationSuccessDialog(
              context,
              state.activationResult!,
              driverToken: driverToken,
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.plans.isEmpty) {
            return const _SubscriptionSkeletonLoading();
          }

          if (state.errorMessage != null && state.plans.isEmpty) {
            return _SubscriptionErrorView(
              errorMessage: state.errorMessage!,
              onRetry: () {
                context.read<SubscriptionBloc>().add(
                      const LoadSubscriptionPlansEvent(),
                    );
              },
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  context.read<SubscriptionBloc>().add(
                        const RefreshSubscriptionPlansEvent(),
                      );
                },
                color: const Color(0xFF021B45),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Premium Hero Banner
                      _buildHeroBanner(),
                      const SizedBox(height: 20),

                      // 2. Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Driver Pass',
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
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              '${state.plans.length} ${state.plans.length == 1 ? 'Pass' : 'Passes'} Available',
                              style: const TextStyle(
                                color: Color(0xFF1D4ED8),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. Dynamic Plan Cards from API
                      ...state.plans.map((plan) {
                        final isSelected = plan.id == state.selectedPlanId;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _PlanCard(
                            plan: plan,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<SubscriptionBloc>().add(
                                    SelectSubscriptionPlanEvent(plan.id),
                                  );
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      // 4. Value Proposition / Benefits Section
                      _buildBenefitsCard(),
                      const SizedBox(height: 16),

                      // 5. Driver Trust & Support Card
                      _buildSupportCard(context),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
              if (state.isActivating) _buildActivatingOverlay(),
            ],
          );
        },
      ),
      bottomNavigationBar: _BottomSubscribeBar(driverToken: driverToken),
    );
  }

  // ================= 1. Premium Hero Banner =================
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF021B45),
            Color(0xFF0B2C6F),
            Color(0xFF1E3E62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF021B45).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM DRIVER PASS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF10B981),
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Official Pass',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Keep 100% of Every Ride Fare',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Activate a monthly pass to eliminate platform commission and unlock priority ride dispatch.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroBadge(Icons.money_off_rounded, '0% Fee'),
              const SizedBox(width: 8),
              _buildHeroBadge(Icons.flash_on_rounded, 'Fast Match'),
              const SizedBox(width: 8),
              _buildHeroBadge(Icons.all_inclusive_rounded, '999 Duties'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFCD34D), size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 4. Value Proposition / Benefits Card =================
  Widget _buildBenefitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Why Subscribe to a Driver Pass?',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _BenefitTile(
                  icon: Icons.percent_rounded,
                  color: Color(0xFF10B981),
                  title: 'Zero Commission',
                  subtitle: 'Take home 100% of the passenger trip payment.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _BenefitTile(
                  icon: Icons.speed_rounded,
                  color: Color(0xFF0284C7),
                  title: 'Priority Dispatch',
                  subtitle: 'Get alerts before non-subscribed drivers.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _BenefitTile(
                  icon: Icons.support_agent_rounded,
                  color: Color(0xFF8B5CF6),
                  title: '24/7 Helpline',
                  subtitle: 'Dedicated operations support team.',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _BenefitTile(
                  icon: Icons.alt_route_rounded,
                  color: Color(0xFFD97706),
                  title: 'Local & Outstation',
                  subtitle: 'Full eligibility for local and outstation runs.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 5. Driver Trust & Support Card =================
  Widget _buildSupportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF021B45),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Immediate Activation',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your pass benefits apply instantly upon subscription confirmation.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivatingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF021B45)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Activating Driver Pass...',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Processing payment and issuing active pass...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActivationSuccessDialog(
    BuildContext context,
    SubscriptionActivationEntity activation, {
    String? driverToken,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Pass Activated',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (dialogContext, anim1, anim2) {
        return _ActivationSuccessDialog(
          activation: activation,
          driverToken: driverToken,
          onDismiss: () {
            Navigator.pop(dialogContext);
            context
                .read<SubscriptionBloc>()
                .add(ClearSubscriptionActivationEvent());
          },
          onViewHistory: () {
            Navigator.pop(dialogContext);
            context
                .read<SubscriptionBloc>()
                .add(ClearSubscriptionActivationEvent());
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    SubscriptionHistoryPage(driverToken: driverToken),
              ),
            );
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }
}

// ================= Dynamic Plan Card Widget =================

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasGold = plan.isHighTier;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? (hasGold ? const Color(0xFFFFFDF5) : const Color(0xFFF0FDF4))
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (hasGold ? const Color(0xFFF59E0B) : const Color(0xFF10B981))
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (hasGold
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.18)
                      : const Color(0xFF10B981).withValues(alpha: 0.15))
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Plan Name, Tag & Radio selection
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (hasGold
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFDCFCE7))
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasGold
                        ? Icons.workspace_premium_rounded
                        : Icons.star_rounded,
                    color: isSelected
                        ? (hasGold
                            ? const Color(0xFFB45309)
                            : const Color(0xFF15803D))
                        : const Color(0xFF64748B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasGold) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFFCD34D),
                                ),
                              ),
                              child: const Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${plan.formattedDuration} • ${plan.billingCycle.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Radio Indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? (hasGold
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF10B981))
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? (hasGold
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981))
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Pricing & Daily Rate
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  plan.formattedPrice,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  ' ${plan.formattedBillingSuffix}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (plan.dailyCostText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      plan.dailyCostText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
              ],
            ),

            if (plan.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                plan.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),

            // Eligibility Badges
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (plan.localEligible)
                  _buildEligibilityChip(
                    Icons.directions_car_rounded,
                    'Local Eligible',
                    const Color(0xFF0284C7),
                    const Color(0xFFE0F2FE),
                  ),
                if (plan.outstationEligible)
                  _buildEligibilityChip(
                    Icons.explore_rounded,
                    'Outstation Eligible',
                    const Color(0xFF059669),
                    const Color(0xFFD1FAE5),
                  ),
                if (plan.maxRequestsPerDay > 0)
                  _buildEligibilityChip(
                    Icons.all_inclusive_rounded,
                    '${plan.maxRequestsPerDay} Requests/Day',
                    const Color(0xFFD97706),
                    const Color(0xFFFEF3C7),
                  ),
              ],
            ),

            if (plan.features.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityChip(
    IconData icon,
    String label,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Benefit Tile =================

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _BenefitTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= Sticky Bottom Subscription Bar =================

class _BottomSubscribeBar extends StatelessWidget {
  final String? driverToken;

  const _BottomSubscribeBar({this.driverToken});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        final plan = state.selectedPlan;
        final isActivating = state.isActivating;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Plan info & Price summary
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan?.name ?? 'Select Plan',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            plan != null ? plan.formattedPrice : '₹0',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF021B45),
                            ),
                          ),
                          if (plan != null)
                            Text(
                              ' ${plan.formattedBillingSuffix}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Subscribe CTA Button
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: (plan == null || isActivating)
                          ? null
                          : () {
                              _showSubscribeConfirmationSheet(
                                context,
                                plan,
                                driverToken: driverToken,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF021B45),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFF021B45).withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isActivating
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Activating...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Activate Pass',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
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

  void _showSubscribeConfirmationSheet(
    BuildContext context,
    SubscriptionPlanEntity plan, {
    String? driverToken,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _SubscriptionConfirmationSheet(
          plan: plan,
          driverToken: driverToken,
          onConfirm: (selectedMethod) {
            context.read<SubscriptionBloc>().add(
                  ActivateSubscriptionEvent(
                    planId: plan.id,
                    paymentMethod: selectedMethod,
                    token: driverToken,
                  ),
                );
          },
        );
      },
    );
  }
}

// ================= Payment Confirmation Modal Sheet =================

class _SubscriptionConfirmationSheet extends StatefulWidget {
  final SubscriptionPlanEntity plan;
  final String? driverToken;
  final Function(String paymentMethod) onConfirm;

  const _SubscriptionConfirmationSheet({
    required this.plan,
    this.driverToken,
    required this.onConfirm,
  });

  @override
  State<_SubscriptionConfirmationSheet> createState() =>
      _SubscriptionConfirmationSheetState();
}

class _SubscriptionConfirmationSheetState
    extends State<_SubscriptionConfirmationSheet> {
  String _selectedPaymentMethod = 'UPI';

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Plan Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFB45309),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '${plan.formattedDuration} Pass • ${plan.billingCycle.toUpperCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    plan.formattedPrice,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF021B45),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Payment Method Section
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),

              // UPI (Default & Recommended)
              _buildPaymentOption(
                method: 'UPI',
                title: 'UPI (GPay, PhonePe, Paytm)',
                subtitle: 'Instant pass activation with zero extra fee',
                icon: Icons.account_balance_wallet_rounded,
                isRecommended: true,
              ),
              const SizedBox(height: 8),

              // Debit / Credit Card
              _buildPaymentOption(
                method: 'Card',
                title: 'Debit / Credit Card',
                subtitle: 'Visa, Mastercard, RuPay',
                icon: Icons.credit_card_rounded,
              ),
              const SizedBox(height: 8),

              // Net Banking
              _buildPaymentOption(
                method: 'NetBanking',
                title: 'Net Banking',
                subtitle: 'All major Indian banks supported',
                icon: Icons.account_balance_rounded,
              ),

              const SizedBox(height: 18),

              // Price Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Plan Fee', plan.formattedPrice),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Duration', plan.formattedDuration),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      'Daily Request Limit',
                      '${plan.maxRequestsPerDay} Requests/Day',
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      'Platform Commission',
                      '0% (Keep 100% Earnings)',
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Payment Method', _selectedPaymentMethod),
                    const Divider(height: 20),
                    _buildReceiptRow(
                      'Total Payable',
                      plan.formattedPrice,
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Security notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '100% Secure 256-Bit Encrypted Payment',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    widget.onConfirm(_selectedPaymentMethod);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF021B45),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proceed to Pay ${plan.formattedPrice}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String method,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDBEAFE)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF64748B),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (isRecommended)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFF0F172A) : Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 12,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF021B45) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

// ================= Activation Success Celebration Dialog =================

class _ActivationSuccessDialog extends StatelessWidget {
  final SubscriptionActivationEntity activation;
  final String? driverToken;
  final VoidCallback onDismiss;
  final VoidCallback onViewHistory;

  const _ActivationSuccessDialog({
    required this.activation,
    this.driverToken,
    required this.onDismiss,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Celebration Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF021B45),
                          Color(0xFF0B2C6F),
                          Color(0xFF065F46),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF34D399),
                              width: 2,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF34D399),
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pass Activated Successfully!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activation.message,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA7F3D0),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Pass Summary Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Color(0xFFB45309),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      activation.planName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          activation.subscriptionStatus
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    activation.formattedAmount,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFCD34D),
                                      ),
                                    ),
                                    child: Text(
                                      '${activation.daysLeft} Days Remaining',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (activation.formattedDateRange.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 12,
                                      color: Color(0xFF78350F),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      activation.formattedDateRange,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF78350F),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 2. Driver & Receipt Details Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Driver Profile Header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: const Color(0xFFE2E8F0),
                                    backgroundImage:
                                        activation.driverAvatar.isNotEmpty
                                            ? NetworkImage(
                                                activation.driverAvatar,
                                              )
                                            : null,
                                    child: activation.driverAvatar.isEmpty
                                        ? const Icon(
                                            Icons.person,
                                            color: Color(0xFF64748B),
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activation.driverName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          'ID: ${activation.driverId} • ${activation.driverPhone}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const Divider(
                                height: 20,
                                color: Color(0xFFE2E8F0),
                              ),

                              _buildDetailRow(
                                'Transaction ID',
                                activation.transactionId,
                                isCopyable: true,
                                context: context,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Payment Method',
                                activation.paymentMethod,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Payment Status',
                                activation.paymentStatus,
                                valueColor: const Color(0xFF10B981),
                                isBold: true,
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Platform Commission',
                                '0% (Keep 100% Earnings)',
                                valueColor: const Color(0xFF0284C7),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Daily Requests',
                                '${activation.maxRequestsPerDay} Requests/Day',
                              ),
                            ],
                          ),
                        ),

                        if (activation.features.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Text(
                            'Active Privileges',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...activation.features.map(
                            (feat) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF10B981),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      feat,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: onViewHistory,
                            icon: const Icon(Icons.history_rounded, size: 18),
                            label: const Text(
                              'View Subscription History',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF021B45),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: TextButton(
                            onPressed: onDismiss,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                            ),
                            child: const Text(
                              'Done & Close',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
    bool isCopyable = false,
    BuildContext? context,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
            if (isCopyable && context != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied $value to clipboard!'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ================= Skeleton Loading State =================

class _SubscriptionSkeletonLoading extends StatelessWidget {
  const _SubscriptionSkeletonLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 140,
          height: 20,
          color: Colors.grey.shade200,
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }
}

// ================= Error State View =================

class _SubscriptionErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _SubscriptionErrorView({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to Load Plans',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF021B45),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

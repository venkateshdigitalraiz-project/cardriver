import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rewards_bloc.dart';
import '../bloc/rewards_event.dart';
import '../bloc/rewards_state.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RewardsBloc()..add(LoadRewardsData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Rewards',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocBuilder<RewardsBloc, RewardsState>(
          builder: (context, state) {
            if (state is RewardsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RewardsLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CaptainStatusBanner(
                      captainTier: state.captainTier,
                      totalRewards: state.totalRewards,
                      currentTrips: state.currentTrips,
                      totalTrips: state.totalTrips,
                      tripsToNextTier: state.tripsToNextTier,
                      nextTier: state.nextTier,
                      tierProgress: state.tierProgress,
                    ),
                    const SizedBox(height: 24),
                    const _SectionHeader(icon: Icons.list_alt, title: 'Complete and earn'),
                    const SizedBox(height: 12),
                    ...state.tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      final isFirst = index == 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _ProgressCard(
                          title: task.title,
                          subtitle: '${task.completed} / ${task.total} completed',
                          reward: '+ ₹${task.rewardAmount}',
                          progress: task.progress,
                          progressColor: isFirst ? Colors.blue : Colors.deepPurpleAccent,
                          iconContainerColor: isFirst ? const Color(0xFFD6E4FF) : const Color(0xFFEBE0FF),
                          iconColor: isFirst ? Colors.blue : Colors.deepPurpleAccent,
                          icon: isFirst ? Icons.local_taxi : Icons.nights_stay,
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    const _SectionHeader(icon: Icons.card_giftcard, title: 'Available rewards'),
                    const SizedBox(height: 12),
                    Row(
                      children: state.availableRewards.asMap().entries.map((entry) {
                        final index = entry.key;
                        final reward = entry.value;
                        final isFirst = index == 0;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: isFirst ? 12.0 : 0.0),
                            child: _RewardCard(
                              title: reward.amountOrTitle,
                              subtitle: reward.subtitle,
                              backgroundColor: isFirst ? const Color(0xFFC8F0D0) : const Color(0xFFD6E8FF),
                              textColor: isFirst ? const Color(0xFF1B8031) : const Color(0xFF2355A0),
                              icon: isFirst ? Icons.payments_outlined : Icons.local_gas_station_outlined,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.grey, height: 1),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.history, color: Colors.grey),
                      title: Text('Reward history', style: TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    ),
                    const Divider(color: Colors.grey, height: 1),
                  ],
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CaptainStatusBanner extends StatelessWidget {
  final String captainTier;
  final int totalRewards;
  final int currentTrips;
  final int totalTrips;
  final int tripsToNextTier;
  final String nextTier;
  final double tierProgress;

  const _CaptainStatusBanner({
    required this.captainTier,
    required this.totalRewards,
    required this.currentTrips,
    required this.totalTrips,
    required this.tripsToNextTier,
    required this.nextTier,
    required this.tierProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3D9A4), // Light orange/beige background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium, color: Colors.amber[700], size: 16),
                const SizedBox(width: 4),
                Text(
                  captainTier,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '₹$totalRewards',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total rewards earned',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: tierProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.5),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentTrips / $totalTrips\ntrips',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.2,
                ),
              ),
              Text(
                '$tripsToNextTier more trips → $nextTier',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String reward;
  final double progress;
  final Color progressColor;
  final Color iconContainerColor;
  final Color iconColor;
  final IconData icon;

  const _ProgressCard({
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.progress,
    required this.progressColor,
    required this.iconContainerColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  reward,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const _RewardCard({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Redeem',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_right_alt, color: textColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subscription_transaction.dart';
import '../bloc/subscription_history_bloc.dart';
import '../bloc/subscription_history_event.dart';
import '../bloc/subscription_history_state.dart';

class SubscriptionHistoryPage extends StatelessWidget {
  const SubscriptionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SubscriptionHistoryBloc()..add(LoadSubscriptionHistory()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subscription History',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'View Your Past Plans & Payments',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
        body: const _SubscriptionHistoryView(),
      ),
    );
  }
}

class _SubscriptionHistoryView extends StatelessWidget {
  const _SubscriptionHistoryView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF021B45), Color(0xFF0044B2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Icon
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description,
                        color: Colors.amber,
                        size: 36,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(8, 8),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0066FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Subscription\nJourney',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your past plans, payments\nand download invoices anytime.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filters
        BlocBuilder<SubscriptionHistoryBloc, SubscriptionHistoryState>(
          builder: (context, state) {
            if (state is SubscriptionHistoryLoaded) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      title: 'All',
                      isSelected: state.currentFilter == 'All',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      title: 'Active',
                      isSelected: state.currentFilter == 'Active',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      title: 'Expired',
                      isSelected: state.currentFilter == 'Expired',
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      title: 'Cancelled',
                      isSelected: state.currentFilter == 'Cancelled',
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // List
        Expanded(
          child: BlocBuilder<SubscriptionHistoryBloc, SubscriptionHistoryState>(
            builder: (context, state) {
              if (state is SubscriptionHistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SubscriptionHistoryLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = state.filteredTransactions[index];
                    return _HistoryCard(transaction: transaction);
                  },
                );
              } else if (state is SubscriptionHistoryError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _FilterChip({required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<SubscriptionHistoryBloc>().add(
          FilterSubscriptionHistory(title),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final SubscriptionTransaction transaction;

  const _HistoryCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color iconBgColor;
    IconData planIcon;

    if (transaction.status == 'Active') {
      statusColor = const Color(0xFF10B981);
      iconBgColor = Colors.amber.shade100;
      planIcon = Icons.workspace_premium;
    } else if (transaction.status == 'Cancelled') {
      statusColor = const Color(0xFFEF4444);
      iconBgColor = Colors.red.shade100;
      planIcon = Icons.workspace_premium; // using same icon for premium
    } else {
      statusColor = Colors.grey.shade500;
      if (transaction.planName.contains('Premium')) {
        iconBgColor = Colors.amber.shade100;
        planIcon = Icons.workspace_premium;
      } else if (transaction.planName.contains('Standard')) {
        iconBgColor = Colors.grey.shade200;
        planIcon = Icons.star;
      } else {
        iconBgColor = Colors.purple.shade100;
        planIcon = Icons.shield;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: statusColor, // Outer container gets the status color
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(left: 4), // Leaves a 4px strip on the left
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  planIcon,
                  color: transaction.status == 'Cancelled'
                      ? Colors.red
                      : (transaction.planName.contains('Premium')
                            ? Colors.amber
                            : (transaction.planName.contains('Standard')
                                  ? Colors.grey.shade600
                                  : Colors.purple)),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            transaction.planName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transaction.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.duration,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      transaction.dateRange,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      transaction.paymentMethod,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 11,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              '₹${transaction.amount.toInt()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF0066FF),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 12,
                              color: Color(0xFF0066FF),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Download Invoice',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

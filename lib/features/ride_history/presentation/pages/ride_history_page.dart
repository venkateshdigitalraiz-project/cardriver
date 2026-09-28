import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/ride_history_remote_datasource.dart';
import '../../data/repositories/ride_history_repository_impl.dart';
import '../../domain/usecases/get_ride_history_usecase.dart';
import '../bloc/ride_history_bloc.dart';
import '../bloc/ride_history_event.dart';
import '../bloc/ride_history_state.dart';

class RideHistoryPage extends StatelessWidget {
  const RideHistoryPage({super.key});

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideHistoryBloc(
        getRideHistoryUseCase: GetRideHistoryUseCase(
          RideHistoryRepositoryImpl(
            remoteDataSource: RideHistoryRemoteDataSourceImpl(),
          ),
        ),
      )..add(LoadRideHistory()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // Light slate gray background for contrast
        appBar: AppBar(
          title: const Text('Ride History'),
          backgroundColor: const Color(0xFF0066FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<RideHistoryBloc, RideHistoryState>(
          builder: (context, state) {
            if (state is RideHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RideHistoryLoaded) {
              if (state.history.isEmpty) {
                return const Center(child: Text('No ride history found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final ride = state.history[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.06), // Subtle brand-tinted shadow
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF1F5F9), // Very light border
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Date & Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getMonthName(ride.date.month)} ${ride.date.day}, ${ride.date.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ride ID: #${ride.id.padLeft(6, '0')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ride.status == 'Completed' ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: ride.status == 'Completed' ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      ride.status == 'Completed' ? Icons.check_circle : Icons.cancel,
                                      size: 14,
                                      color: ride.status == 'Completed' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      ride.status,
                                      style: TextStyle(
                                        color: ride.status == 'Completed' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          
                          // Locations with Timeline
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Timeline indicators
                              Column(
                                children: [
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFDBEAFE), width: 3),
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 24,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFFEE2E2), width: 3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Location Texts
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ride.pickupLocation,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      ride.dropLocation,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Footer: Fare
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Fare',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '₹${ride.fare.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is RideHistoryError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

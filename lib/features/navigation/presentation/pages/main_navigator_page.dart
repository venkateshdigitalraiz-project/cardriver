import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../trip/presentation/pages/trip_page.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';

class MainNavigatorPage extends StatelessWidget {
  final CustomerEntity customer;

  const MainNavigatorPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationBloc(),
      child: _MainNavigatorView(customer: customer),
    );
  }
}

class _MainNavigatorView extends StatelessWidget {
  final CustomerEntity customer;

  const _MainNavigatorView({required this.customer});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(customer: customer),
      const TripPage(),
      ProfilePage(userName: customer.name),
    ];

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: IndexedStack(
            index: state.tabIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: state.tabIndex,
            onTap: (index) {
              context.read<NavigationBloc>().add(NavigationTabChanged(index));
            },
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey.shade400,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Trip',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

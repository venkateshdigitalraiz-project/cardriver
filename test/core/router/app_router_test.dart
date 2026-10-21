import 'package:cardriver/core/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter Route Definition Tests', () {
    test('AppRoutes defines valid route paths', () {
      expect(AppRoutes.splash, equals('/'));
      expect(AppRoutes.login, equals('/login'));
      expect(AppRoutes.register, equals('/register'));
      expect(AppRoutes.customerHome, equals('/home'));
      expect(AppRoutes.customerDashboard, equals('/customer-dashboard'));
      expect(AppRoutes.driverDashboard, equals('/driver-dashboard'));
      expect(AppRoutes.documents, equals('/documents'));
      expect(AppRoutes.earnings, equals('/earnings'));
      expect(AppRoutes.rideHistory, equals('/ride-history'));
      expect(AppRoutes.support, equals('/support'));
      expect(AppRoutes.rewards, equals('/rewards'));
      expect(AppRoutes.notifications, equals('/notifications'));
      expect(AppRoutes.subscription, equals('/subscription'));
      expect(AppRoutes.subscriptionHistory, equals('/subscription-history'));
      expect(AppRoutes.legal, equals('/legal'));
      expect(AppRoutes.editProfile, equals('/edit-profile'));
      expect(AppRoutes.locationPicker, equals('/location-picker'));
      expect(AppRoutes.trips, equals('/trips'));
      expect(AppRoutes.tripDetails, equals('/trip-details'));
      expect(AppRoutes.profile, equals('/profile'));
    });

    test('AppRouteNames defines unique route names', () {
      final names = [
        AppRouteNames.splash,
        AppRouteNames.login,
        AppRouteNames.register,
        AppRouteNames.customerHome,
        AppRouteNames.customerDashboard,
        AppRouteNames.driverDashboard,
        AppRouteNames.documents,
        AppRouteNames.earnings,
        AppRouteNames.rideHistory,
        AppRouteNames.support,
        AppRouteNames.rewards,
        AppRouteNames.notifications,
        AppRouteNames.subscription,
        AppRouteNames.subscriptionHistory,
        AppRouteNames.legal,
        AppRouteNames.editProfile,
        AppRouteNames.locationPicker,
        AppRouteNames.trips,
        AppRouteNames.tripDetails,
        AppRouteNames.profile,
      ];

      expect(names.toSet().length, equals(names.length));
    });
  });
}

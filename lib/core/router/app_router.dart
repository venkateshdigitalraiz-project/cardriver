import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/customer_entity.dart';
import '../../features/auth/domain/entities/driver_entity.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/documents/presentation/pages/documents_page.dart';
import '../../features/earnings/presentation/pages/earnings_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/widgets/create_ride_widget.dart';
import '../../features/legal/presentation/pages/legal_page.dart';
import '../../features/navigation/presentation/pages/main_navigator_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/domain/entities/driver_documents_entity.dart';
import '../../features/profile/domain/entities/driver_profile_entity.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/location_picker_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/rewards/presentation/pages/rewards_page.dart';
import '../../features/ride_history/presentation/pages/ride_history_page.dart';
import '../../features/subscription/presentation/pages/subscription_page.dart';
import '../../features/subscription_history/presentation/pages/subscription_history_page.dart';
import '../../features/support/presentation/pages/support_page.dart';
import '../../features/trip/domain/entities/trip_entity.dart';
import '../../features/trip/presentation/pages/trip_details_page.dart';
import '../../features/trip/presentation/pages/trip_page.dart';
import '../../injection_container.dart';
import '../style/app_colors.dart';

/// Centralized route paths for the application
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHome = '/home';
  static const String customerDashboard = '/customer-dashboard';
  static const String driverDashboard = '/driver-dashboard';
  static const String documents = '/documents';
  static const String earnings = '/earnings';
  static const String rideHistory = '/ride-history';
  static const String support = '/support';
  static const String rewards = '/rewards';
  static const String notifications = '/notifications';
  static const String subscription = '/subscription';
  static const String subscriptionHistory = '/subscription-history';
  static const String legal = '/legal';
  static const String editProfile = '/edit-profile';
  static const String locationPicker = '/location-picker';
  static const String trips = '/trips';
  static const String tripDetails = '/trip-details';
  static const String profile = '/profile';
  static const String createRide = '/create-ride';
}

/// Centralized route names for named navigation
class AppRouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String customerHome = 'customerHome';
  static const String customerDashboard = 'customerDashboard';
  static const String driverDashboard = 'driverDashboard';
  static const String documents = 'documents';
  static const String earnings = 'earnings';
  static const String rideHistory = 'rideHistory';
  static const String support = 'support';
  static const String rewards = 'rewards';
  static const String notifications = 'notifications';
  static const String subscription = 'subscription';
  static const String subscriptionHistory = 'subscriptionHistory';
  static const String legal = 'legal';
  static const String editProfile = 'editProfile';
  static const String locationPicker = 'locationPicker';
  static const String trips = 'trips';
  static const String tripDetails = 'tripDetails';
  static const String profile = 'profile';
  static const String createRide = 'createRide';
}

/// Helper that converts any Stream into a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

CustomerEntity? _resolveCustomer(dynamic extra, AuthState authState) {
  if (extra is CustomerEntity) return extra;
  if (extra is DriverEntity) return extra.toCustomerEntity();
  if (authState.customer != null) return authState.customer;
  if (authState.driver != null) return authState.driver!.toCustomerEntity();
  return null;
}

/// Centralized Router Configuration using go_router
class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        final status = authState.status;
        final location = state.uri.path;

        final isSplash = location == AppRoutes.splash;
        final isLogin = location == AppRoutes.login;
        final isRegister = location == AppRoutes.register;

        // 1. Initial local authentication verification
        if (status == AuthStatus.initial) {
          if (isLogin || isRegister) return null;
          return isSplash ? null : AppRoutes.splash;
        }

        // 2. Unauthenticated check
        final isUnauthenticated =
            status == AuthStatus.unauthenticated ||
            status == AuthStatus.registered ||
            (status == AuthStatus.error && !authState.isAuthenticated);

        if (isUnauthenticated) {
          if (isLogin || isRegister) {
            return null;
          }
          return AppRoutes.login;
        }

        // 3. Authenticated check - redirect away from auth gates / login / splash
        if (status == AuthStatus.authenticated || authState.isAuthenticated) {
          if (isSplash || isLogin || isRegister) {
            if (authState.driver != null) {
              return AppRoutes.driverDashboard;
            } else if (authState.customer != null) {
              return AppRoutes.customerHome;
            }
          }
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: AppRouteNames.splash,
          builder: (context, state) => const AuthSplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRouteNames.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: AppRouteNames.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.customerHome,
          name: AppRouteNames.customerHome,
          builder: (context, state) {
            final customer = _resolveCustomer(state.extra, authBloc.state);
            if (customer == null) {
              return const LoginPage();
            }
            return MainNavigatorPage(customer: customer);
          },
        ),
        GoRoute(
          path: AppRoutes.driverDashboard,
          name: AppRouteNames.driverDashboard,
          builder: (context, state) {
            final customer = _resolveCustomer(state.extra, authBloc.state);
            if (customer == null) {
              return const LoginPage();
            }
            return MainNavigatorPage(customer: customer);
          },
        ),

        GoRoute(
          path: AppRoutes.documents,
          name: AppRouteNames.documents,
          builder: (context, state) {
            DriverDocumentsEntity? documents;
            DriverProfileEntity? profile;
            final extra = state.extra;
            if (extra is DriverDocumentsEntity) {
              documents = extra;
            } else if (extra is DriverProfileEntity) {
              profile = extra;
              documents = extra.documents;
            } else if (extra is Map) {
              if (extra['documents'] is DriverDocumentsEntity) {
                documents = extra['documents'] as DriverDocumentsEntity;
              }
              if (extra['profile'] is DriverProfileEntity) {
                profile = extra['profile'] as DriverProfileEntity;
                documents ??= profile.documents;
              }
            }
            return DocumentsPage(documents: documents, profile: profile);
          },
        ),
        GoRoute(
          path: AppRoutes.earnings,
          name: AppRouteNames.earnings,
          builder: (context, state) => const EarningsPage(),
        ),
        GoRoute(
          path: AppRoutes.rideHistory,
          name: AppRouteNames.rideHistory,
          builder: (context, state) => const RideHistoryPage(),
        ),
        GoRoute(
          path: AppRoutes.support,
          name: AppRouteNames.support,
          builder: (context, state) => const SupportPage(),
        ),
        GoRoute(
          path: AppRoutes.rewards,
          name: AppRouteNames.rewards,
          builder: (context, state) => const RewardsPage(),
        ),
        GoRoute(
          path: AppRoutes.notifications,
          name: AppRouteNames.notifications,
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: AppRoutes.subscription,
          name: AppRouteNames.subscription,
          builder: (context, state) {
            String? driverToken;
            bool? hasSubscription;

            if (state.extra is Map) {
              final map = state.extra as Map;
              driverToken = map['driverToken'] as String?;
              hasSubscription = map['hasSubscription'] as bool?;
            } else if (state.extra is bool) {
              hasSubscription = state.extra as bool;
            }

            driverToken ??=
                state.uri.queryParameters['driverToken'] ??
                authBloc.state.driver?.token;
            if (hasSubscription == null &&
                state.uri.queryParameters.containsKey('hasSubscription')) {
              hasSubscription =
                  state.uri.queryParameters['hasSubscription'] == 'true';
            }

            return SubscriptionPage(
              driverToken: driverToken,
              hasSubscription: hasSubscription,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.subscriptionHistory,
          name: AppRouteNames.subscriptionHistory,
          builder: (context, state) {
            String? driverToken;
            if (state.extra is String) {
              driverToken = state.extra as String;
            } else if (state.extra is Map) {
              driverToken = (state.extra as Map)['driverToken'] as String?;
            }
            driverToken ??=
                state.uri.queryParameters['driverToken'] ??
                authBloc.state.driver?.token;

            return SubscriptionHistoryPage(driverToken: driverToken);
          },
        ),
        GoRoute(
          path: AppRoutes.legal,
          name: AppRouteNames.legal,
          builder: (context, state) {
            LegalPageType pageType = LegalPageType.terms;
            if (state.extra is LegalPageType) {
              pageType = state.extra as LegalPageType;
            } else if (state.uri.queryParameters['type'] == 'privacy') {
              pageType = LegalPageType.privacy;
            }
            return LegalPage(pageType: pageType);
          },
        ),
        GoRoute(
          path: AppRoutes.editProfile,
          name: AppRouteNames.editProfile,
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.locationPicker,
          name: AppRouteNames.locationPicker,
          builder: (context, state) => const LocationPickerPage(),
        ),
        GoRoute(
          path: AppRoutes.trips,
          name: AppRouteNames.trips,
          builder: (context, state) {
            final driverToken =
                state.uri.queryParameters['driverToken'] ??
                (state.extra as String?) ??
                authBloc.state.driver?.token ??
                authBloc.state.customer?.token;
            return TripPage(driverToken: driverToken);
          },
        ),
        GoRoute(
          path: AppRoutes.profile,
          name: AppRouteNames.profile,
          builder: (context, state) {
            final userName =
                state.uri.queryParameters['userName'] ??
                authBloc.state.customer?.name ??
                authBloc.state.driver?.name ??
                'Driver';
            final driverToken =
                state.uri.queryParameters['driverToken'] ??
                authBloc.state.driver?.token ??
                authBloc.state.customer?.token;
            return ProfilePage(userName: userName, driverToken: driverToken);
          },
        ),
        GoRoute(
          path: AppRoutes.tripDetails,
          name: AppRouteNames.tripDetails,
          builder: (context, state) {
            TripEntity? trip;
            String? bookingId = state.uri.queryParameters['bookingId'];
            String? driverToken =
                state.uri.queryParameters['driverToken'] ??
                authBloc.state.driver?.token;

            if (state.extra is TripEntity) {
              trip = state.extra as TripEntity;
            } else if (state.extra is Map) {
              final map = state.extra as Map;
              trip = map['trip'] as TripEntity?;
              bookingId ??= map['bookingId'] as String?;
              driverToken ??= map['driverToken'] as String?;
            }

            if (trip != null) {
              return TripDetailsPage(
                trip: trip,
                bookingId: bookingId,
                driverToken: driverToken,
              );
            } else if (bookingId != null && bookingId.isNotEmpty) {
              return TripDetailsPage.fromId(
                bookingId: bookingId,
                driverToken: driverToken,
              );
            }

            return const Scaffold(
              body: Center(child: Text('Invalid booking details')),
            );
          },
          routes: [
            GoRoute(
              path: ':bookingId',
              builder: (context, state) {
                final bookingId = state.pathParameters['bookingId'] ?? '';
                final driverToken =
                    state.uri.queryParameters['driverToken'] ??
                    authBloc.state.driver?.token;
                TripEntity? trip;

                if (state.extra is TripEntity) {
                  trip = state.extra as TripEntity;
                } else if (state.extra is Map) {
                  final map = state.extra as Map;
                  trip = map['trip'] as TripEntity?;
                }

                if (trip != null) {
                  return TripDetailsPage(
                    trip: trip,
                    bookingId: bookingId,
                    driverToken: driverToken,
                  );
                }
                return TripDetailsPage.fromId(
                  bookingId: bookingId,
                  driverToken: driverToken,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.createRide,
          name: AppRouteNames.createRide,
          builder: (context, state) {
            HomeBloc? homeBloc;
            CustomerEntity? customer;

            if (state.extra is Map) {
              final map = state.extra as Map;
              homeBloc = map['homeBloc'] as HomeBloc?;
              customer = map['customer'] as CustomerEntity?;
            } else if (state.extra is HomeBloc) {
              homeBloc = state.extra as HomeBloc;
            } else if (state.extra is CustomerEntity) {
              customer = state.extra as CustomerEntity;
            }

            customer ??= authBloc.state.customer;
            final token =
                customer?.token ??
                authBloc.state.driver?.token ??
                authBloc.state.customer?.token ??
                '';

            return CreateRideRouteScreen(
              key: const ValueKey('create_ride_route_screen'),
              passedBloc: homeBloc,
              customer: customer,
              driverToken: token,
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Text(
            'Route not found: ${state.uri}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Seamless splash screen during session verification
class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_taxi_rounded, size: 64, color: AppColors.primary),
            SizedBox(height: 24),
            CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Route screen wrapper that stably holds and provides HomeBloc
/// using a single consistent BlocProvider constructor.
class CreateRideRouteScreen extends StatefulWidget {
  final HomeBloc? passedBloc;
  final CustomerEntity? customer;
  final String driverToken;

  const CreateRideRouteScreen({
    super.key,
    this.passedBloc,
    this.customer,
    required this.driverToken,
  });

  @override
  State<CreateRideRouteScreen> createState() => _CreateRideRouteScreenState();
}

class _CreateRideRouteScreenState extends State<CreateRideRouteScreen> {
  late HomeBloc _bloc;
  late bool _ownsBloc;

  @override
  void initState() {
    super.initState();
    if (widget.passedBloc != null) {
      _bloc = widget.passedBloc!;
      _ownsBloc = false;
    } else {
      _bloc = InjectionContainer.createHomeBloc(
        driverToken: widget.driverToken,
      );
      _ownsBloc = true;
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>.value(
      value: _bloc,
      child: CreateRidePage(
        //  customer: widget.customer,
        homeBloc: _bloc,
      ),
    );
  }
}

/// Extension on BuildContext to safely handle back navigation without throwing
/// "GoError: There is nothing to pop" when pages are navigated with context.go()
extension SafeNavigationExtension on BuildContext {
  void safePop({String? fallbackRoute}) {
    if (canPop()) {
      pop();
    } else if (Navigator.of(this).canPop()) {
      Navigator.of(this).pop();
    } else {
      if (fallbackRoute != null && fallbackRoute.isNotEmpty) {
        go(fallbackRoute);
        return;
      }
      try {
        final authState = read<AuthBloc>().state;
        if (authState.driver != null) {
          go(AppRoutes.driverDashboard, extra: authState.driver);
        } else if (authState.customer != null) {
          go(AppRoutes.customerHome, extra: authState.customer);
        } else {
          go(AppRoutes.login);
        }
      } catch (_) {
        go(AppRoutes.login);
      }
    }
  }
}

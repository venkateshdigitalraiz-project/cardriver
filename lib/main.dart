import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/style/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/driver_dashboard_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/navigation/presentation/pages/main_navigator_page.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E17),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Clean Architecture dependency injection container
  InjectionContainer.init();

  // Initialize Firebase and messaging safely (without throwing uncaught exceptions)
  await InjectionContainer.firebaseMessagingService.initialize();

  runApp(const CarDriverApp());

  // Request runtime permissions safely after first frame to prevent startup PlatformException collision
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _requestAppPermissionsSafely();
  });
}

Future<void> _requestAppPermissionsSafely() async {
  try {
    await [
      Permission.notification,
      Permission.camera,
      Permission.storage,
    ].request();
  } catch (e) {
    debugPrint('Startup permissions note: $e');
  }
}

class CarDriverApp extends StatelessWidget {
  const CarDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(initialMode: ThemeMode.dark),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => InjectionContainer.createAuthBloc()
            ..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => InjectionContainer.createNotificationBloc()
            ..add(const LoadNotifications()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Car Driver & Passenger Portal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const AppAuthGate(),
          );
        },
      ),
    );
  }
}

/// Dynamic gate that directs authenticated users to their home dashboard
/// while displaying a seamless dark splash view during initial local session verification.
class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.initial) {
          return const _AuthSplashScreen();
        }

        if (state.status == AuthStatus.authenticated) {
          if (state.customer != null) {
            return MainNavigatorPage(customer: state.customer!);
          } else if (state.driver != null) {
            return DriverDashboardPage(driver: state.driver!);
          }
        }

        return const LoginPage();
      },
    );
  }
}

class _AuthSplashScreen extends StatelessWidget {
  const _AuthSplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_taxi_rounded,
              size: 64,
              color: AppColors.primary,
            ),
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

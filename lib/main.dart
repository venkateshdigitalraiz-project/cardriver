import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
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

class CarDriverApp extends StatefulWidget {
  const CarDriverApp({super.key});

  @override
  State<CarDriverApp> createState() => _CarDriverAppState();
}

class _CarDriverAppState extends State<CarDriverApp> {
  late final AuthBloc _authBloc;
  late final NotificationBloc _notificationBloc;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit(initialMode: ThemeMode.dark);
    _authBloc = InjectionContainer.createAuthBloc()
      ..add(const CheckAuthStatusEvent())
      ..add(const LoadIntroBannersEvent());
    _notificationBloc = InjectionContainer.createNotificationBloc()
      ..add(const LoadNotifications());
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
    _themeCubit.close();
    _authBloc.close();
    _notificationBloc.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<NotificationBloc>.value(value: _notificationBloc),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Car Driver & Passenger Portal',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

import 'core/services/firebase_messaging_service.dart';
import 'core/services/socket_service.dart';
import 'core/storage/local_storage_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_intro_banners_usecase.dart';
import 'features/auth/domain/usecases/login_customer_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_customer_usecase.dart';
import 'features/auth/domain/usecases/register_driver_usecase.dart';
import 'features/auth/domain/usecases/send_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/domain/repositories/notification_repository.dart';
import 'features/notifications/domain/usecases/get_fcm_token_usecase.dart';
import 'features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'features/notifications/domain/usecases/refresh_fcm_token_usecase.dart';
import 'features/notifications/domain/usecases/send_notification_usecase.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/home/data/datasources/available_rides_remote_data_source.dart';
import 'features/home/data/datasources/home_remote_data_source.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/home/domain/repositories/home_repository.dart';
import 'features/home/domain/usecases/accept_ride_usecase.dart';
import 'features/home/domain/usecases/get_available_rides_usecase.dart';
import 'features/home/domain/usecases/reject_ride_usecase.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/trip/data/datasources/trip_remote_data_source.dart';
import 'features/trip/data/repositories/trip_repository_impl.dart';
import 'features/trip/domain/repositories/trip_repository.dart';
import 'features/trip/domain/usecases/get_driver_booking_details_usecase.dart';
import 'features/trip/domain/usecases/get_driver_bookings_usecase.dart';
import 'features/trip/domain/usecases/update_trip_status_usecase.dart';
import 'features/trip/presentation/bloc/trip_bloc.dart';
import 'features/trip/presentation/bloc/trip_details_bloc.dart';
import 'features/subscription/data/datasources/subscription_remote_data_source.dart';
import 'features/subscription/data/repositories/subscription_repository_impl.dart';
import 'features/subscription/domain/repositories/subscription_repository.dart';
import 'features/subscription/domain/usecases/activate_subscription_usecase.dart';
import 'features/subscription/domain/usecases/get_subscription_plans_usecase.dart';
import 'features/subscription/presentation/bloc/subscription_bloc.dart';
import 'features/subscription_history/data/datasources/subscription_history_remote_data_source.dart';
import 'features/subscription_history/data/repositories/subscription_history_repository_impl.dart';
import 'features/subscription_history/domain/repositories/subscription_history_repository.dart';
import 'features/subscription_history/domain/usecases/get_subscription_history_usecase.dart';
import 'features/subscription_history/presentation/bloc/subscription_history_bloc.dart';
import 'features/profile/data/datasources/profile_remote_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_driver_profile_usecase.dart';
import 'features/profile/domain/usecases/get_profile_menu_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

/// Service Locator / Dependency Injection Setup for Clean Architecture
class InjectionContainer {
  InjectionContainer._();

  // Core Services
  static late final FirebaseMessagingService firebaseMessagingService;
  static late final LocalStorageService localStorageService;
  static final SocketService socketService = SocketService();

  // Home Data Sources & Repositories
  static late final HomeRemoteDataSource homeRemoteDataSource;
  static late final HomeRepository homeRepository;

  // Home UseCases
  static late final GetAvailableRidesUseCase getAvailableRidesUseCase;
  static late final AcceptRideUseCase acceptRideUseCase;
  static late final RejectRideUseCase rejectRideUseCase;

  // Trip Data Sources & Repositories
  static late final TripRemoteDataSource tripRemoteDataSource;
  static late final TripRepository tripRepository;

  // Trip UseCases
  static late final GetDriverBookingsUseCase getDriverBookingsUseCase;
  static late final GetDriverBookingDetailsUseCase getDriverBookingDetailsUseCase;
  static late final UpdateTripStatusUseCase updateTripStatusUseCase;

  // Subscription Data Sources & Repositories
  static late final SubscriptionRemoteDataSource subscriptionRemoteDataSource;
  static late final SubscriptionRepository subscriptionRepository;

  // Subscription UseCases
  static late final GetSubscriptionPlansUseCase getSubscriptionPlansUseCase;
  static late final ActivateSubscriptionUseCase activateSubscriptionUseCase;

  // Subscription History Data Sources & Repositories
  static late final SubscriptionHistoryRemoteDataSource subscriptionHistoryRemoteDataSource;
  static late final SubscriptionHistoryRepository subscriptionHistoryRepository;

  // Subscription History UseCases
  static late final GetSubscriptionHistoryUseCase getSubscriptionHistoryUseCase;

  // Auth Data Sources & Repositories
  static late final AuthRemoteDataSource authRemoteDataSource;
  static late final AuthLocalDataSource authLocalDataSource;
  static late final AuthRepository authRepository;

  // Auth UseCases
  static late final LoginCustomerUseCase loginCustomerUseCase;
  static late final SendOtpUseCase sendOtpUseCase;
  static late final VerifyOtpUseCase verifyOtpUseCase;
  static late final RegisterCustomerUseCase registerCustomerUseCase;
  static late final RegisterDriverUseCase registerDriverUseCase;
  static late final LogoutUseCase logoutUseCase;
  static late final GetIntroBannersUseCase getIntroBannersUseCase;

  // Notification Data Sources & Repositories
  static late final NotificationRemoteDataSource notificationRemoteDataSource;
  static late final NotificationRepository notificationRepository;

  // Notification UseCases
  static late final GetNotificationsUseCase getNotificationsUseCase;
  static late final SendNotificationUseCase sendNotificationUseCase;
  static late final GetFcmTokenUseCase getFcmTokenUseCase;
  static late final RefreshFcmTokenUseCase refreshFcmTokenUseCase;

  // Profile Data Sources & Repositories
  static late final ProfileRemoteDataSource profileRemoteDataSource;
  static late final ProfileRepository profileRepository;

  // Profile UseCases
  static late final GetDriverProfileUseCase getDriverProfileUseCase;
  static late final GetProfileMenuUseCase getProfileMenuUseCase;

  static void init() {
    // Core Services
    firebaseMessagingService = FirebaseMessagingService();
    localStorageService = LocalStorageService();
    // socketService is a singleton — no initialization needed here.

    // Data Sources
    authRemoteDataSource = AuthRemoteDataSourceImpl();
    authLocalDataSource = AuthLocalDataSourceImpl(
      storageService: localStorageService,
    );
    notificationRemoteDataSource = NotificationRemoteDataSourceImpl(
      messagingService: firebaseMessagingService,
    );

    // Repositories
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      messagingService: firebaseMessagingService,
    );
    notificationRepository = NotificationRepositoryImpl(
      remoteDataSource: notificationRemoteDataSource,
    );

    // Auth UseCases
    loginCustomerUseCase = LoginCustomerUseCase(authRepository);
    sendOtpUseCase = SendOtpUseCase(authRepository);
    verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    registerCustomerUseCase = RegisterCustomerUseCase(authRepository);
    registerDriverUseCase = RegisterDriverUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getIntroBannersUseCase = GetIntroBannersUseCase(authRepository);

    // Notification UseCases
    getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
    sendNotificationUseCase = SendNotificationUseCase(notificationRepository);
    getFcmTokenUseCase = GetFcmTokenUseCase(notificationRepository);
    refreshFcmTokenUseCase = RefreshFcmTokenUseCase(notificationRepository);

    // Home Data Sources & Repositories
    homeRemoteDataSource = HomeRemoteDataSourceImpl();
    homeRepository = HomeRepositoryImpl(remoteDataSource: homeRemoteDataSource);
    getAvailableRidesUseCase = GetAvailableRidesUseCase(homeRepository);
    acceptRideUseCase = AcceptRideUseCase(homeRepository);
    rejectRideUseCase = RejectRideUseCase(homeRepository);

    // Trip Data Sources & Repositories
    tripRemoteDataSource = TripRemoteDataSourceImpl();
    tripRepository = TripRepositoryImpl(remoteDataSource: tripRemoteDataSource);
    getDriverBookingsUseCase = GetDriverBookingsUseCase(tripRepository);
    getDriverBookingDetailsUseCase = GetDriverBookingDetailsUseCase(tripRepository);
    updateTripStatusUseCase = UpdateTripStatusUseCase(tripRepository);

    // Subscription Data Sources & Repositories
    subscriptionRemoteDataSource = SubscriptionRemoteDataSourceImpl();
    subscriptionRepository = SubscriptionRepositoryImpl(
      remoteDataSource: subscriptionRemoteDataSource,
    );
    getSubscriptionPlansUseCase = GetSubscriptionPlansUseCase(subscriptionRepository);
    activateSubscriptionUseCase = ActivateSubscriptionUseCase(subscriptionRepository);

    // Subscription History Data Sources & Repositories
    subscriptionHistoryRemoteDataSource = SubscriptionHistoryRemoteDataSourceImpl();
    subscriptionHistoryRepository = SubscriptionHistoryRepositoryImpl(
      remoteDataSource: subscriptionHistoryRemoteDataSource,
    );
    getSubscriptionHistoryUseCase = GetSubscriptionHistoryUseCase(
      subscriptionHistoryRepository,
    );

    // Profile Data Sources & Repositories
    profileRemoteDataSource = ProfileRemoteDataSourceImpl(
      storageService: localStorageService,
    );
    profileRepository = ProfileRepositoryImpl(
      remoteDataSource: profileRemoteDataSource,
    );
    getDriverProfileUseCase = GetDriverProfileUseCase(profileRepository);
    getProfileMenuUseCase = GetProfileMenuUseCase();
  }

  static ProfileBloc createProfileBloc({String? driverToken}) {
    return ProfileBloc(
      getDriverProfileUseCase: getDriverProfileUseCase,
      getProfileMenuUseCase: getProfileMenuUseCase,
      driverToken: driverToken,
    );
  }

  static AuthBloc createAuthBloc() {
    return AuthBloc(
      loginCustomerUseCase: loginCustomerUseCase,
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
      registerCustomerUseCase: registerCustomerUseCase,
      registerDriverUseCase: registerDriverUseCase,
      logoutUseCase: logoutUseCase,
      getIntroBannersUseCase: getIntroBannersUseCase,
      authRepository: authRepository,
    );
  }

  static NotificationBloc createNotificationBloc() {
    return NotificationBloc(
      getNotificationsUseCase: getNotificationsUseCase,
      sendNotificationUseCase: sendNotificationUseCase,
      getFcmTokenUseCase: getFcmTokenUseCase,
      refreshFcmTokenUseCase: refreshFcmTokenUseCase,
      repository: notificationRepository,
    );
  }

  static HomeBloc createHomeBloc({required String driverToken}) {
    return HomeBloc(
      remoteDataSource: AvailableRidesRemoteDataSourceImpl(),
      socketService: socketService,
      driverToken: driverToken,
      acceptRideUseCase: acceptRideUseCase,
      rejectRideUseCase: rejectRideUseCase,
    );
  }

  static TripBloc createTripBloc({String? driverToken}) {
    return TripBloc(
      getDriverBookingsUseCase: getDriverBookingsUseCase,
      updateTripStatusUseCase: updateTripStatusUseCase,
      tripRepository: tripRepository,
      remoteDataSource: tripRemoteDataSource,
      driverToken: driverToken,
    );
  }

  static TripDetailsBloc createTripDetailsBloc({String? driverToken}) {
    return TripDetailsBloc(
      getDriverBookingDetailsUseCase: getDriverBookingDetailsUseCase,
      tripRepository: tripRepository,
      remoteDataSource: tripRemoteDataSource,
      driverToken: driverToken,
    );
  }

  static SubscriptionBloc createSubscriptionBloc({
    String? driverToken,
    bool initialHasSubscription = false,
  }) {
    return SubscriptionBloc(
      getSubscriptionPlansUseCase: getSubscriptionPlansUseCase,
      activateSubscriptionUseCase: activateSubscriptionUseCase,
      getDriverProfileUseCase: getDriverProfileUseCase,
      driverToken: driverToken,
      initialHasSubscription: initialHasSubscription,
    );
  }

  static SubscriptionHistoryBloc createSubscriptionHistoryBloc({
    String? driverToken,
  }) {
    return SubscriptionHistoryBloc(
      getSubscriptionHistoryUseCase: getSubscriptionHistoryUseCase,
      driverToken: driverToken,
    );
  }
}

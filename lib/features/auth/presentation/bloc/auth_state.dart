import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/entities/intro_banner.dart';
import 'auth_event.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final CustomerEntity? customer;
  final DriverEntity? driver;
  final String? errorMessage;
  final AuthLoginMode loginMode;
  final bool rememberMe;
  final String? pendingPhoneNumber;
  final List<IntroBanner> introBanners;
  final int currentBannerIndex;
  final bool isLoadingBanners;

  const AuthState({
    this.status = AuthStatus.initial,
    this.customer,
    this.driver,
    this.errorMessage,
    this.loginMode = AuthLoginMode.email,
    this.rememberMe = true,
    this.pendingPhoneNumber,
    this.introBanners = const [],
    this.currentBannerIndex = 0,
    this.isLoadingBanners = false,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated =>
      status == AuthStatus.authenticated &&
      (customer != null || driver != null);
  bool get isOtpSent => status == AuthStatus.otpSent;
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  AuthState copyWith({
    AuthStatus? status,
    CustomerEntity? customer,
    DriverEntity? driver,
    String? errorMessage,
    AuthLoginMode? loginMode,
    bool? rememberMe,
    String? pendingPhoneNumber,
    List<IntroBanner>? introBanners,
    int? currentBannerIndex,
    bool? isLoadingBanners,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      customer: customer ?? this.customer,
      driver: driver ?? this.driver,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      loginMode: loginMode ?? this.loginMode,
      rememberMe: rememberMe ?? this.rememberMe,
      pendingPhoneNumber: pendingPhoneNumber ?? this.pendingPhoneNumber,
      introBanners: introBanners ?? this.introBanners,
      currentBannerIndex: currentBannerIndex ?? this.currentBannerIndex,
      isLoadingBanners: isLoadingBanners ?? this.isLoadingBanners,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customer,
    driver,
    errorMessage,
    loginMode,
    rememberMe,
    pendingPhoneNumber,
    introBanners,
    currentBannerIndex,
    isLoadingBanners,
  ];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_intro_banners_usecase.dart';
import '../../domain/usecases/login_customer_usecase.dart';
import '../../domain/usecases/register_customer_usecase.dart';
import '../../domain/usecases/register_driver_usecase.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginCustomerUseCase loginCustomerUseCase;
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterCustomerUseCase registerCustomerUseCase;
  final RegisterDriverUseCase? registerDriverUseCase;
  final LogoutUseCase logoutUseCase;
  final GetIntroBannersUseCase? getIntroBannersUseCase;
  final AuthRepository authRepository;
  final SocketService _socketService;

  AuthBloc({
    required this.loginCustomerUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerCustomerUseCase,
    this.registerDriverUseCase,
    required this.logoutUseCase,
    this.getIntroBannersUseCase,
    required this.authRepository,
    SocketService? socketService,
  })  : _socketService = socketService ?? SocketService(),
        super(const AuthState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoadIntroBannersEvent>(_onLoadIntroBanners);
    on<IntroBannerPageChangedEvent>(_onIntroBannerPageChanged);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SocialLoginEvent>(_onSocialLogin);
    on<RegisterCustomerEvent>(_onRegisterCustomer);
    on<RegisterDriverEvent>(_onRegisterDriver);
    on<SwitchLoginModeEvent>(_onSwitchLoginMode);
    on<ToggleRememberMeEvent>(_onToggleRememberMe);
    on<LogoutEvent>(_onLogout);
    on<ClearAuthErrorEvent>(_onClearAuthError);
    on<ResetAuthEvent>(_onResetAuth);
  }

  Future<void> _onLoadIntroBanners(
    LoadIntroBannersEvent event,
    Emitter<AuthState> emit,
  ) async {
    final useCase = getIntroBannersUseCase;
    if (useCase == null) return;
    emit(state.copyWith(isLoadingBanners: true));
    try {
      final banners = await useCase();
      emit(state.copyWith(
        introBanners: banners,
        isLoadingBanners: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingBanners: false));
    }
  }

  void _onIntroBannerPageChanged(
    IntroBannerPageChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(currentBannerIndex: event.pageIndex));
  }

  void _onResetAuth(ResetAuthEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(status: AuthStatus.initial, clearError: true));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final cachedCustomer = await authRepository.getCurrentCustomer();
      if (cachedCustomer != null && cachedCustomer.token.isNotEmpty) {
        try {
          _socketService.connectWithToken(cachedCustomer.token);
        } catch (_) {}
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            customer: cachedCustomer,
          ),
        );
        return;
      }

      final cachedDriver = await authRepository.getCurrentDriver();
      if (cachedDriver != null && cachedDriver.token.isNotEmpty) {
        try {
          _socketService.connectWithToken(cachedDriver.token);
        } catch (_) {}
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            driver: cachedDriver,
          ),
        );
        return;
      }

      emit(const AuthState(status: AuthStatus.unauthenticated));
    } catch (_) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final customer = await loginCustomerUseCase(
        LoginCustomerParams(
          email: event.email,
          password: event.password,
          rememberMe: event.rememberMe,
        ),
      );
      emit(
        state.copyWith(status: AuthStatus.authenticated, customer: customer),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } on ServerException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await sendOtpUseCase(
        SendOtpParams(
          phone: event.phone,
          fcmToken: event.fcmToken,
        ),
      );
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          pendingPhoneNumber: event.phone,
        ),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Failed to send OTP. Please check your mobile number.',
        ),
      );
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final customer = await authRepository.verifyCustomerOtp(
        phone: event.phone,
        otp: event.otp,
      );
      // Connect socket using the token received from the API safely.
      if (customer.token.isNotEmpty) {
        try {
          _socketService.connectWithToken(customer.token);
        } catch (_) {}
      }
      emit(
        state.copyWith(status: AuthStatus.authenticated, customer: customer),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } on ServerException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final customer = await authRepository.loginCustomerWithSocial(
        provider: event.provider,
      );
      emit(
        state.copyWith(status: AuthStatus.authenticated, customer: customer),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Failed to sign in with ${event.provider}.',
        ),
      );
    }
  }

  Future<void> _onRegisterCustomer(
    RegisterCustomerEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final customer = await registerCustomerUseCase(
        RegisterCustomerParams(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          phone: event.phone,
          password: event.password,
          preferredPayment: event.preferredPayment,
        ),
      );
      emit(
        state.copyWith(status: AuthStatus.authenticated, customer: customer),
      );
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Account creation failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onRegisterDriver(
    RegisterDriverEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final driverUseCase =
          registerDriverUseCase ?? RegisterDriverUseCase(authRepository);
      final driver = await driverUseCase(
        RegisterDriverParams(
          body: event.body,
          firstName: event.firstName,
          lastName: event.lastName,
          name: event.name,
          email: event.email,
          phone: event.phone,
          password: event.password,
          address: event.address,
          licenseNumber: event.licenseNumber,
          vehicleModel: event.vehicleModel,
          vehiclePlate: event.vehiclePlate,
          serviceType: event.serviceType,
          pancardNumber: event.pancardNumber,
          aadhaarNumber: event.aadhaarNumber,
          passportId: event.passportId,
          pancard: event.pancard,
          aadhaarCardFront: event.aadhaarCardFront,
          aadhaarCardBack: event.aadhaarCardBack,
          drivingLicense: event.drivingLicense,
          selfie: event.selfie,
          passport: event.passport,
          aadharNumber: event.aadhaarNumber,
          panNumber: event.pancardNumber,
          passportNumber: event.passportId,
          aadharFrontPath: event.aadhaarCardFront,
          aadharBackPath: event.aadhaarCardBack,
          panCardPath: event.pancard,
          drivingLicensePath: event.drivingLicensePath,
          passportPath: event.passport,
          profilePicPath: event.selfie,
        ),
      );
      emit(state.copyWith(status: AuthStatus.authenticated, driver: driver));
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Driver registration failed. Please try again.',
        ),
      );
    }
  }

  void _onSwitchLoginMode(SwitchLoginModeEvent event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        loginMode: event.mode,
        clearError: true,
        status: AuthStatus.initial,
      ),
    );
  }

  void _onToggleRememberMe(
    ToggleRememberMeEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(rememberMe: event.value));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    _socketService.disconnectFully();
    await logoutUseCase(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onClearAuthError(ClearAuthErrorEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearError: true, status: AuthStatus.initial));
  }
}

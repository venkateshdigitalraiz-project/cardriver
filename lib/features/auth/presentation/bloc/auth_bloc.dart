import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/login_customer_usecase.dart';
import '../../domain/usecases/register_customer_usecase.dart';
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
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginCustomerUseCase,
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerCustomerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(const AuthState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SocialLoginEvent>(_onSocialLogin);
    on<RegisterCustomerEvent>(_onRegisterCustomer);
    on<SwitchLoginModeEvent>(_onSwitchLoginMode);
    on<ToggleRememberMeEvent>(_onToggleRememberMe);
    on<LogoutEvent>(_onLogout);
    on<ClearAuthErrorEvent>(_onClearAuthError);
    on<ResetAuthEvent>(_onResetAuth);
  }

  void _onResetAuth(
    ResetAuthEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(status: AuthStatus.initial, clearError: true));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final cachedCustomer = await authRepository.getCurrentCustomer();
      if (cachedCustomer != null) {
        emit(state.copyWith(
          status: AuthStatus.authenticated,
          customer: cachedCustomer,
        ));
      }
    } catch (_) {
      // Stay initial/unauthenticated
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
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        customer: customer,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred. Please try again.',
      ));
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await sendOtpUseCase(SendOtpParams(phone: event.phone));
      emit(state.copyWith(
        status: AuthStatus.otpSent,
        pendingPhoneNumber: event.phone,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to send OTP. Please check your mobile number.',
      ));
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
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        customer: customer,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Invalid OTP code. Please try again.',
      ));
    }
  }

  Future<void> _onSocialLogin(
    SocialLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final customer = await authRepository.loginCustomerWithSocial(provider: event.provider);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        customer: customer,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign in with ${event.provider}.',
      ));
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
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        customer: customer,
      ));
    } on AuthException catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Account creation failed. Please try again.',
      ));
    }
  }

  void _onSwitchLoginMode(
    SwitchLoginModeEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      loginMode: event.mode,
      clearError: true,
      status: AuthStatus.initial,
    ));
  }

  void _onToggleRememberMe(
    ToggleRememberMeEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(rememberMe: event.value));
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await logoutUseCase(const NoParams());
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _onClearAuthError(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(clearError: true, status: AuthStatus.initial));
  }
}

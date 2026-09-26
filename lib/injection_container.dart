import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_customer_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_customer_usecase.dart';
import 'features/auth/domain/usecases/send_otp_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

/// Service Locator / Dependency Injection Setup for Clean Architecture
class InjectionContainer {
  InjectionContainer._();

  static late final AuthRemoteDataSource authRemoteDataSource;
  static late final AuthLocalDataSource authLocalDataSource;
  static late final AuthRepository authRepository;

  static late final LoginCustomerUseCase loginCustomerUseCase;
  static late final SendOtpUseCase sendOtpUseCase;
  static late final VerifyOtpUseCase verifyOtpUseCase;
  static late final RegisterCustomerUseCase registerCustomerUseCase;
  static late final LogoutUseCase logoutUseCase;

  static void init() {
    // Data Sources
    authRemoteDataSource = AuthRemoteDataSourceImpl();
    authLocalDataSource = AuthLocalDataSourceImpl();

    // Repository
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    // UseCases
    loginCustomerUseCase = LoginCustomerUseCase(authRepository);
    sendOtpUseCase = SendOtpUseCase(authRepository);
    verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    registerCustomerUseCase = RegisterCustomerUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
  }

  static AuthBloc createAuthBloc() {
    return AuthBloc(
      loginCustomerUseCase: loginCustomerUseCase,
      sendOtpUseCase: sendOtpUseCase,
      verifyOtpUseCase: verifyOtpUseCase,
      registerCustomerUseCase: registerCustomerUseCase,
      logoutUseCase: logoutUseCase,
      authRepository: authRepository,
    );
  }
}

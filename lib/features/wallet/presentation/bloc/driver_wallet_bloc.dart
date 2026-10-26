import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_money_to_driver_wallet_usecase.dart';
import '../../domain/usecases/get_driver_wallet_usecase.dart';
import '../../domain/usecases/withdraw_wallet_funds_usecase.dart';
import 'driver_wallet_event.dart';
import 'driver_wallet_state.dart';

class DriverWalletBloc extends Bloc<DriverWalletEvent, DriverWalletState> {
  final GetDriverWalletUseCase getDriverWalletUseCase;
  final WithdrawWalletFundsUseCase withdrawWalletFundsUseCase;
  final AddMoneyToDriverWalletUseCase addMoneyToDriverWalletUseCase;

  DriverWalletBloc({
    required this.getDriverWalletUseCase,
    required this.withdrawWalletFundsUseCase,
    required this.addMoneyToDriverWalletUseCase,
  }) : super(const DriverWalletInitial()) {
    on<LoadDriverWalletEvent>(_onLoadWallet);
    on<RefreshDriverWalletEvent>(_onRefreshWallet);
    on<WithdrawDriverWalletFundsEvent>(_onWithdrawFunds);
    on<AddMoneyToDriverWalletEvent>(_onAddMoney);
  }

  Future<void> _onLoadWallet(
    LoadDriverWalletEvent event,
    Emitter<DriverWalletState> emit,
  ) async {
    emit(const DriverWalletLoading());
    try {
      final wallet = await getDriverWalletUseCase();
      emit(DriverWalletLoaded(wallet: wallet));
    } catch (e) {
      emit(DriverWalletError(message: 'Failed to load wallet: $e'));
    }
  }

  Future<void> _onRefreshWallet(
    RefreshDriverWalletEvent event,
    Emitter<DriverWalletState> emit,
  ) async {
    final current = state is DriverWalletLoaded ? (state as DriverWalletLoaded).wallet : null;
    try {
      final wallet = await getDriverWalletUseCase();
      emit(DriverWalletLoaded(wallet: wallet));
    } catch (e) {
      if (current != null) {
        emit(DriverWalletLoaded(wallet: current));
      } else {
        emit(DriverWalletError(message: 'Failed to refresh wallet: $e'));
      }
    }
  }

  Future<void> _onWithdrawFunds(
    WithdrawDriverWalletFundsEvent event,
    Emitter<DriverWalletState> emit,
  ) async {
    final current = state is DriverWalletLoaded ? (state as DriverWalletLoaded).wallet : null;
    if (current == null) return;

    if (event.amount <= 0) {
      emit(DriverWalletError(
        message: 'Please enter a valid amount to withdraw',
        currentWallet: current,
      ));
      emit(DriverWalletLoaded(wallet: current));
      return;
    }

    if (event.amount > current.balance) {
      emit(DriverWalletError(
        message: 'Insufficient balance. Available: ₹${current.balance.toStringAsFixed(0)}',
        currentWallet: current,
      ));
      emit(DriverWalletLoaded(wallet: current));
      return;
    }

    emit(DriverWalletLoading(currentWallet: current));
    try {
      final updatedWallet = await withdrawWalletFundsUseCase(
        amount: event.amount,
        bankOrUpi: event.destination,
      );
      emit(DriverWalletLoaded(
        wallet: updatedWallet,
        successMessage: '₹${event.amount.toStringAsFixed(0)} payout initiated successfully!',
      ));
    } catch (e) {
      emit(DriverWalletError(
        message: 'Withdrawal failed: $e',
        currentWallet: current,
      ));
      emit(DriverWalletLoaded(wallet: current));
    }
  }

  Future<void> _onAddMoney(
    AddMoneyToDriverWalletEvent event,
    Emitter<DriverWalletState> emit,
  ) async {
    final current = state is DriverWalletLoaded ? (state as DriverWalletLoaded).wallet : null;
    if (event.amount <= 0) {
      emit(DriverWalletError(
        message: 'Please enter a valid amount',
        currentWallet: current,
      ));
      if (current != null) emit(DriverWalletLoaded(wallet: current));
      return;
    }

    emit(DriverWalletLoading(currentWallet: current));
    try {
      final updatedWallet = await addMoneyToDriverWalletUseCase(
        amount: event.amount,
        method: event.method,
      );
      emit(DriverWalletLoaded(
        wallet: updatedWallet,
        successMessage: '₹${event.amount.toStringAsFixed(0)} added to wallet successfully!',
      ));
    } catch (e) {
      emit(DriverWalletError(
        message: 'Failed to add money: $e',
        currentWallet: current,
      ));
      if (current != null) emit(DriverWalletLoaded(wallet: current));
    }
  }
}

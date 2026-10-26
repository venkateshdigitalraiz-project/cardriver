import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/driver_wallet_transaction_entity.dart';
import '../models/driver_wallet_model.dart';
import '../models/driver_wallet_transaction_model.dart';

abstract class DriverWalletLocalDataSource {
  Future<DriverWalletModel> getWallet();
  Future<DriverWalletModel> withdrawFunds(double amount, String? bankOrUpi);
  Future<DriverWalletModel> addMoney(double amount, String? method);
  Future<List<DriverWalletTransactionModel>> getTransactions();
}

class DriverWalletLocalDataSourceImpl implements DriverWalletLocalDataSource {
  static const String _kDriverWalletKey = 'driver_wallet_cache_v1';

  DriverWalletModel _getDefaultWallet() {
    return DriverWalletModel(
      balance: 1250.0,
      todayEarnings: 850.0,
      totalWithdrawn: 4500.0,
      currency: '₹',
      bankAccountInfo: 'State Bank of India (••4092)',
      lastUpdated: DateTime.now(),
      transactions: [
        DriverWalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 500000}',
          title: 'Ride Fare Credit',
          description: 'Booking #CD-1092 (Local Trip)',
          amount: 450.0,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: DriverTransactionType.credit,
          status: 'Completed',
        ),
        DriverWalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 1500000}',
          title: 'Ride Fare Credit',
          description: 'Booking #CD-1088 (Outstation)',
          amount: 400.0,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          type: DriverTransactionType.credit,
          status: 'Completed',
        ),
        DriverWalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 3000000}',
          title: 'Payout to Bank Account',
          description: 'Transferred to SBI ••4092',
          amount: 1500.0,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          type: DriverTransactionType.debit,
          status: 'Completed',
        ),
        DriverWalletTransactionModel(
          id: 'TXN${DateTime.now().millisecondsSinceEpoch - 5000000}',
          title: 'Weekly Incentive Bonus',
          description: 'Target 15 trips completed',
          amount: 500.0,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          type: DriverTransactionType.credit,
          status: 'Completed',
        ),
      ],
    );
  }

  @override
  Future<DriverWalletModel> getWallet() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_kDriverWalletKey);
    if (data != null) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return DriverWalletModel.fromJson(decoded);
        }
      } catch (_) {}
    }
    final defaultWallet = _getDefaultWallet();
    await prefs.setString(_kDriverWalletKey, jsonEncode(defaultWallet.toJson()));
    return defaultWallet;
  }

  @override
  Future<DriverWalletModel> withdrawFunds(double amount, String? bankOrUpi) async {
    final current = await getWallet();
    final newBalance = current.balance - amount;
    final newWithdrawn = current.totalWithdrawn + amount;
    final newTxn = DriverWalletTransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      title: 'Payout Transfer',
      description: 'Transferred to ${bankOrUpi ?? current.bankAccountInfo}',
      amount: amount,
      timestamp: DateTime.now(),
      type: DriverTransactionType.debit,
      status: 'Completed',
    );

    final updatedTxns = [newTxn, ...current.transactions];
    final updatedWallet = DriverWalletModel(
      balance: newBalance,
      todayEarnings: current.todayEarnings,
      totalWithdrawn: newWithdrawn,
      currency: current.currency,
      bankAccountInfo: current.bankAccountInfo,
      lastUpdated: DateTime.now(),
      transactions: updatedTxns,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDriverWalletKey, jsonEncode(updatedWallet.toJson()));
    return updatedWallet;
  }

  @override
  Future<DriverWalletModel> addMoney(double amount, String? method) async {
    final current = await getWallet();
    final newBalance = current.balance + amount;
    final newTxn = DriverWalletTransactionModel(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      title: 'Added to Wallet',
      description: 'Payment via ${method ?? 'UPI'}',
      amount: amount,
      timestamp: DateTime.now(),
      type: DriverTransactionType.credit,
      status: 'Completed',
    );

    final updatedTxns = [newTxn, ...current.transactions];
    final updatedWallet = DriverWalletModel(
      balance: newBalance,
      todayEarnings: current.todayEarnings,
      totalWithdrawn: current.totalWithdrawn,
      currency: current.currency,
      bankAccountInfo: current.bankAccountInfo,
      lastUpdated: DateTime.now(),
      transactions: updatedTxns,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDriverWalletKey, jsonEncode(updatedWallet.toJson()));
    return updatedWallet;
  }

  @override
  Future<List<DriverWalletTransactionModel>> getTransactions() async {
    final wallet = await getWallet();
    return wallet.transactions.cast<DriverWalletTransactionModel>();
  }
}

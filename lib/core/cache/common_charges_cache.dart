import '../../features/home/domain/entities/common_charges_entity.dart';

/// Singleton in-memory cache for GET /api/common/charges in cardriver (Driver App).
/// Provides fast, synchronous access to charges across all BLoCs, UseCases, and screens,
/// eliminating repeated network requests.
class CommonChargesCache {
  CommonChargesCache._internal();

  static final CommonChargesCache _instance = CommonChargesCache._internal();

  static CommonChargesCache get instance => _instance;

  List<CommonChargesEntity>? _charges;
  Future<List<CommonChargesEntity>>? inFlight;

  /// Returns true if valid cached charges exist.
  bool get hasData => _charges != null && _charges!.isNotEmpty;

  /// Returns the cached list of common charges, or null if not yet loaded.
  List<CommonChargesEntity>? get charges => _charges;

  /// Returns the first common charges record if available.
  CommonChargesEntity? get currentCharges =>
      hasData ? _charges!.first : null;

  /// Stores charges in memory.
  void setCharges(List<CommonChargesEntity> data) {
    _charges = data;
  }

  /// Clears in-memory cache (e.g. on logout or refresh).
  void clear() {
    _charges = null;
    inFlight = null;
  }
}


abstract class DocumentsState {}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentItem {
  final String title;
  final String subtitle;
  final String status; // 'Verified', 'Not uploaded', '26 days', etc.
  final String statusType; // 'success', 'warning', 'error', 'upload'

  DocumentItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusType,
  });
}

class DocumentsLoaded extends DocumentsState {
  final int verifiedCount;
  final int expiringCount;
  final int missingCount;
  final List<DocumentItem> driverDocuments;
  final List<DocumentItem> vehicleDocuments;
  final String selectedFilter;

  DocumentsLoaded({
    required this.verifiedCount,
    required this.expiringCount,
    required this.missingCount,
    required this.driverDocuments,
    required this.vehicleDocuments,
    this.selectedFilter = 'All',
  });

  DocumentsLoaded copyWith({
    int? verifiedCount,
    int? expiringCount,
    int? missingCount,
    List<DocumentItem>? driverDocuments,
    List<DocumentItem>? vehicleDocuments,
    String? selectedFilter,
  }) {
    return DocumentsLoaded(
      verifiedCount: verifiedCount ?? this.verifiedCount,
      expiringCount: expiringCount ?? this.expiringCount,
      missingCount: missingCount ?? this.missingCount,
      driverDocuments: driverDocuments ?? this.driverDocuments,
      vehicleDocuments: vehicleDocuments ?? this.vehicleDocuments,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class DocumentsError extends DocumentsState {
  final String message;
  DocumentsError(this.message);
}

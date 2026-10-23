import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/document_verification_status.dart';
import '../../domain/usecases/evaluate_document_status_usecase.dart';
import '../../domain/usecases/get_driver_documents_usecase.dart';
import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import 'documents_event.dart';
import 'documents_state.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final GetDriverDocumentsUseCase? getDriverDocumentsUseCase;

  DocumentsBloc({this.getDriverDocumentsUseCase}) : super(DocumentsInitial()) {
    on<LoadDocumentsEvent>(_onLoadDocuments);
    on<FilterDocumentsEvent>(_onFilterDocuments);
    on<RefreshDocumentsEvent>(_onRefreshDocuments);
    on<UpdateDocumentFileEvent>(_onUpdateDocumentFile);
  }

  Future<void> _onLoadDocuments(
    LoadDocumentsEvent event,
    Emitter<DocumentsState> emit,
  ) async {
    // 1. If documents are already passed in and not forcing refresh, build immediately
    if (event.documents != null && !event.forceRefresh) {
      final loadedState = _buildLoadedState(
        documents: event.documents!,
        profile: event.profile,
        filter: (state is DocumentsLoaded)
            ? (state as DocumentsLoaded).selectedFilter
            : 'All',
      );
      emit(loadedState);
      return;
    }

    // 2. Otherwise fetch from API using Clean Architecture
    if (state is! DocumentsLoaded) {
      emit(DocumentsLoading());
    }

    if (getDriverDocumentsUseCase == null) {
      final loadedState = _buildLoadedState(
        documents: event.documents ?? const DriverDocumentsEntity(),
        profile: event.profile,
        filter: 'All',
      );
      emit(loadedState);
      return;
    }

    try {
      final profile = await getDriverDocumentsUseCase!(
        GetDriverDocumentsParams(token: event.token),
      );
      final documents = profile.documents ?? const DriverDocumentsEntity();

      final loadedState = _buildLoadedState(
        documents: documents,
        profile: profile,
        filter: (state is DocumentsLoaded)
            ? (state as DocumentsLoaded).selectedFilter
            : 'All',
      );
      emit(loadedState);
    } catch (e) {
      log('❌ [DocumentsBloc] Failed to load documents: $e');
      final errorMsg = e.toString().replaceFirst('Exception: ', '');

      if (event.documents != null) {
        emit(
          _buildLoadedState(
            documents: event.documents!,
            profile: event.profile,
            filter: 'All',
            message: 'Using cached documents ($errorMsg)',
          ),
        );
      } else if (state is DocumentsLoaded) {
        emit(
          (state as DocumentsLoaded).copyWith(
            isRefreshing: false,
            message: errorMsg,
          ),
        );
      } else {
        emit(DocumentsError(errorMsg));
      }
    }
  }

  void _onFilterDocuments(
    FilterDocumentsEvent event,
    Emitter<DocumentsState> emit,
  ) {
    if (state is DocumentsLoaded) {
      final current = state as DocumentsLoaded;
      emit(current.copyWith(selectedFilter: event.filterType));
    }
  }

  Future<void> _onRefreshDocuments(
    RefreshDocumentsEvent event,
    Emitter<DocumentsState> emit,
  ) async {
    if (state is DocumentsLoaded) {
      emit((state as DocumentsLoaded).copyWith(isRefreshing: true));
    }
    add(
      LoadDocumentsEvent(
        token: event.token,
        forceRefresh: true,
        profile: (state is DocumentsLoaded)
            ? (state as DocumentsLoaded).profile
            : null,
      ),
    );
  }

  void _onUpdateDocumentFile(
    UpdateDocumentFileEvent event,
    Emitter<DocumentsState> emit,
  ) {
    if (state is! DocumentsLoaded) return;
    final current = state as DocumentsLoaded;

    final updatedDocs = current.driverDocuments.map((doc) {
      // 1. Aadhaar Card
      if (doc.key == 'aadhaar' ||
          event.documentKey == 'aadhaar' ||
          event.documentKey == 'aadhaarCardFront' ||
          event.documentKey == 'aadhaarCardBack') {
        if (doc.key == 'aadhaar') {
          final isBack =
              event.side == 'back' || event.documentKey == 'aadhaarCardBack';
          final newLocalPath = isBack ? doc.localPath : event.filePath;
          final newLocalBackPath = isBack ? event.filePath : doc.localBackPath;

          final hasFront =
              (newLocalPath != null && newLocalPath.trim().isNotEmpty) ||
              EvaluateDocumentStatusUseCase.isValidDocumentValue(doc.fileUrl);
          final hasBack =
              (newLocalBackPath != null &&
                  newLocalBackPath.trim().isNotEmpty) ||
              EvaluateDocumentStatusUseCase.isValidDocumentValue(
                doc.backFileUrl,
              );

          final bool isAadhaarVerified = hasFront && hasBack;
          final newStatus = isAadhaarVerified
              ? DocumentVerificationStatus.verified
              : DocumentVerificationStatus.notVerified;

          final subtitle = doc.documentNumber ?? '';

          return doc.copyWith(
            localPath: newLocalPath,
            localBackPath: newLocalBackPath,
            uploadedFileName: event.fileName,
            verificationStatus: newStatus,
            status: newStatus.label,
            statusType: newStatus.statusType,
            subtitle: subtitle,
          );
        }
      }

      // 2. Other documents
      if (doc.key == event.documentKey) {
        const newStatus = DocumentVerificationStatus.verified;
        final docNum = doc.documentNumber;
        final subtitle = docNum != null && docNum.isNotEmpty ? docNum : '';

        return doc.copyWith(
          localPath: event.filePath,
          uploadedFileName: event.fileName,
          verificationStatus: newStatus,
          status: newStatus.label,
          statusType: newStatus.statusType,
          subtitle: subtitle,
        );
      }
      return doc;
    }).toList();

    final int verified = updatedDocs.where((d) => d.isVerified).length;
    final int missing = updatedDocs.where((d) => !d.isVerified).length;

    emit(
      current.copyWith(
        driverDocuments: updatedDocs,
        verifiedCount: verified,
        missingCount: missing,
        expiringCount: 0,
        message: '${event.fileName} uploaded successfully!',
      ),
    );
  }

  /// Builds the Clean Architecture presentation state using EvaluateDocumentStatusUseCase.
  ///
  /// Verification rules:
  /// - Status is strictly 'Verified' or 'Not Verified'.
  /// - Aadhaar Card: 'Verified' ONLY when BOTH aadhaarCardFront and aadhaarCardBack are valid.
  ///   Otherwise 'Not Verified'.
  /// - Driving Licence: 'Verified' ONLY when drivingLicense contains a valid file value.
  /// - PAN Card: 'Verified' ONLY when pancard contains a valid file value.
  /// - Passport: 'Verified' ONLY when passport contains a valid file value.
  /// - Selfie: 'Verified' ONLY when selfie contains a valid file value.
  ///
  /// Document identification numbers (aadhaarNumber, licenseNumber, pancardNumber, passportId)
  /// NEVER determine verification status.
  DocumentsLoaded _buildLoadedState({
    required DriverDocumentsEntity documents,
    DriverProfileEntity? profile,
    String filter = 'All',
    String? message,
  }) {
    final licenseNo = documents.licenseNumber.trim().isNotEmpty
        ? documents.licenseNumber.trim()
        : (profile?.licenseNumber.trim() ?? '');
    final panNo = documents.pancardNumber.trim().isNotEmpty
        ? documents.pancardNumber.trim()
        : (profile?.pancardNumber.trim() ?? '');
    final passportNo = documents.passportId.trim().isNotEmpty
        ? documents.passportId.trim()
        : (profile?.passportId.trim() ?? '');
    final aadhaarNo = documents.aadhaarNumber.trim().isNotEmpty
        ? documents.aadhaarNumber.trim()
        : (profile?.aadhaarNumber.trim() ?? '');

    final List<DocumentItem> items = [];

    // 1. Aadhaar Card (Requires BOTH front and back for Verified)
    final aadhaarStatus = EvaluateDocumentStatusUseCase.evaluateAadhaar(
      front: documents.aadhaarCardFront,
      back: documents.aadhaarCardBack,
    );
    final String aadhaarSubtitle = aadhaarNo.isNotEmpty ? aadhaarNo : '';

    items.add(
      DocumentItem(
        key: 'aadhaar',
        title: 'Aadhaar Card',
        subtitle: "ID : $aadhaarSubtitle",
        documentNumber: aadhaarNo.isNotEmpty ? aadhaarNo : null,
        fileUrl:
            EvaluateDocumentStatusUseCase.isValidDocumentValue(
              documents.aadhaarCardFront,
            )
            ? documents.aadhaarCardFront.trim()
            : null,
        backFileUrl:
            EvaluateDocumentStatusUseCase.isValidDocumentValue(
              documents.aadhaarCardBack,
            )
            ? documents.aadhaarCardBack.trim()
            : null,
        verificationStatus: aadhaarStatus,
        status: aadhaarStatus.label,
        statusType: aadhaarStatus.statusType,
      ),
    );

    // 2. Driving Licence (Requires drivingLicense file value)
    final dlStatus = EvaluateDocumentStatusUseCase.evaluateSingleDocument(
      documents.drivingLicense,
    );
    final String dlSubtitle = licenseNo.isNotEmpty ? licenseNo : '';

    items.add(
      DocumentItem(
        key: 'drivingLicense',
        title: 'Driving Licence',
        subtitle: "ID : $dlSubtitle",
        documentNumber: licenseNo.isNotEmpty ? licenseNo : null,
        fileUrl:
            EvaluateDocumentStatusUseCase.isValidDocumentValue(
              documents.drivingLicense,
            )
            ? documents.drivingLicense.trim()
            : null,
        verificationStatus: dlStatus,
        status: dlStatus.label,
        statusType: dlStatus.statusType,
      ),
    );

    // 3. PAN Card (Requires pancard file value)
    final panStatus = EvaluateDocumentStatusUseCase.evaluateSingleDocument(
      documents.pancard,
    );
    final String panSubtitle = panNo.isNotEmpty ? panNo : '';

    items.add(
      DocumentItem(
        key: 'pancard',
        title: 'PAN Card',
        subtitle: "ID : $panSubtitle",
        documentNumber: panNo.isNotEmpty ? panNo : null,
        fileUrl:
            EvaluateDocumentStatusUseCase.isValidDocumentValue(
              documents.pancard,
            )
            ? documents.pancard.trim()
            : null,
        verificationStatus: panStatus,
        status: panStatus.label,
        statusType: panStatus.statusType,
      ),
    );

    // 4. Passport (Requires passport file value)
    final passportStatus = EvaluateDocumentStatusUseCase.evaluateSingleDocument(
      documents.passport,
    );
    final String passportSubtitle = passportNo.isNotEmpty ? passportNo : '';

    items.add(
      DocumentItem(
        key: 'passport',
        title: 'Passport',
        subtitle: "ID : $passportSubtitle",
        documentNumber: passportNo.isNotEmpty ? passportNo : null,
        fileUrl:
            EvaluateDocumentStatusUseCase.isValidDocumentValue(
              documents.passport,
            )
            ? documents.passport.trim()
            : null,
        verificationStatus: passportStatus,
        status: passportStatus.label,
        statusType: passportStatus.statusType,
      ),
    );

    // 5. Driver Photo / Selfie (Requires selfie file value)
    final selfieStatus = EvaluateDocumentStatusUseCase.evaluateSingleDocument(
      documents.selfie,
    );
    const String selfieSubtitle = '';

    items.add(
      DocumentItem(
        key: 'selfie',
        title: 'Driver Photo / Selfie',
        subtitle: selfieSubtitle,
        documentNumber: null,
        fileUrl:
            EvaluateDocumentStatusUseCase.isValidDocumentValue(documents.selfie)
            ? documents.selfie.trim()
            : null,
        verificationStatus: selfieStatus,
        status: selfieStatus.label,
        statusType: selfieStatus.statusType,
      ),
    );

    final int verifiedCount = items.where((d) => d.isVerified).length;
    final int missingCount = items.where((d) => !d.isVerified).length;

    return DocumentsLoaded(
      verifiedCount: verifiedCount,
      expiringCount: 0,
      missingCount: missingCount,
      driverDocuments: items,
      vehicleDocuments: const [],
      selectedFilter: filter,
      rawDocuments: documents,
      profile: profile,
      message: message,
    );
  }
}

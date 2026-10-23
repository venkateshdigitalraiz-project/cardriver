import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver/features/documents/domain/entities/document_verification_status.dart';
import 'package:cardriver/features/documents/domain/repositories/documents_repository.dart';
import 'package:cardriver/features/documents/domain/usecases/get_driver_documents_usecase.dart';
import 'package:cardriver/features/documents/presentation/bloc/documents_bloc.dart';
import 'package:cardriver/features/documents/presentation/bloc/documents_event.dart';
import 'package:cardriver/features/documents/presentation/bloc/documents_state.dart';
import 'package:cardriver/features/profile/domain/entities/driver_documents_entity.dart';
import 'package:cardriver/features/profile/domain/entities/driver_profile_entity.dart';

class FakeDocumentsRepository implements DocumentsRepository {
  DriverProfileEntity? profileToReturn;
  Exception? exceptionToThrow;

  @override
  Future<DriverDocumentsEntity> getDriverDocuments({String? token}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return profileToReturn?.documents ?? const DriverDocumentsEntity();
  }

  @override
  Future<DriverProfileEntity> getDriverProfileWithDocuments({String? token}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return profileToReturn ??
        const DriverProfileEntity(
          id: 'test-id',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          phone: '9876543210',
          address: '123 Test St',
          driverId: 'DRV-1',
          licenseNumber: 'DL-9988776655',
          pancardNumber: 'ABCDE1234F',
          aadhaarNumber: '123456789012',
          passportId: 'P1234567',
          status: 'verified',
          isOnline: false,
          isVerified: true,
          createdAt: '',
          updatedAt: '',
          hasSubscription: false,
        );
  }
}

void main() {
  late FakeDocumentsRepository fakeRepository;
  late GetDriverDocumentsUseCase useCase;
  late DocumentsBloc bloc;

  setUp(() {
    fakeRepository = FakeDocumentsRepository();
    useCase = GetDriverDocumentsUseCase(fakeRepository);
    bloc = DocumentsBloc(getDriverDocumentsUseCase: useCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('DocumentsBloc Verified / Not Verified Logic Tests', () {
    test('Case 1 & 5: ID numbers exist but document file fields are empty -> all documents show Not Verified', () async {
      const documents = DriverDocumentsEntity(
        aadhaarNumber: '123456789012',
        aadhaarCardFront: '',
        aadhaarCardBack: '',
        aadhaarCardImage: '',
        drivingLicense: '',
        licenseNumber: 'DL-9988776655',
        pancard: '',
        pancardNumber: 'ABCDE1234F',
        passport: '',
        passportId: 'P1234567',
        selfie: '',
      );

      bloc.add(const LoadDocumentsEvent(documents: documents));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.driverDocuments.map((d) => d.status).toList(),
          'all statuses are Not Verified',
          [
            'Not Verified', // Aadhaar
            'Not Verified', // DL
            'Not Verified', // PAN
            'Not Verified', // Passport
            'Not Verified', // Selfie
          ],
        ).having((s) => s.verifiedCount, 'verified count', 0)
         .having((s) => s.missingCount, 'not verified count', 5)),
      );
    });

    test('Case 2: Aadhaar front and back are populated -> Aadhaar status is Verified', () async {
      const documents = DriverDocumentsEntity(
        aadhaarCardFront: 'https://example.com/front.jpg',
        aadhaarCardBack: 'https://example.com/back.jpg',
      );

      bloc.add(const LoadDocumentsEvent(documents: documents));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').verificationStatus,
          'aadhaar is verified',
          DocumentVerificationStatus.verified,
        ).having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').status,
          'status label',
          'Verified',
        )),
      );
    });

    test('Case 3: Only Aadhaar front is populated -> Aadhaar status is Not Verified', () async {
      const documents = DriverDocumentsEntity(
        aadhaarCardFront: 'https://example.com/front.jpg',
        aadhaarCardBack: '',
      );

      bloc.add(const LoadDocumentsEvent(documents: documents));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').verificationStatus,
          'aadhaar is not verified',
          DocumentVerificationStatus.notVerified,
        ).having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').status,
          'status label',
          'Not Verified',
        ).having(
          (s) => s.missingCount,
          'missing count',
          5,
        )),
      );
    });

    test('Case 4: Populated individual document fields update their statuses to Verified', () async {
      const documents = DriverDocumentsEntity(
        drivingLicense: 'https://example.com/dl.jpg',
        pancard: 'https://example.com/pan.jpg',
        passport: 'https://example.com/passport.jpg',
        selfie: 'https://example.com/selfie.jpg',
      );

      bloc.add(const LoadDocumentsEvent(documents: documents));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'drivingLicense').status,
          'DL status',
          'Verified',
        ).having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'pancard').status,
          'PAN status',
          'Verified',
        ).having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'passport').status,
          'Passport status',
          'Verified',
        ).having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'selfie').status,
          'Selfie status',
          'Verified',
        ).having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').status,
          'Aadhaar status',
          'Not Verified',
        ).having(
          (s) => s.verifiedCount,
          'verified count',
          4,
        ).having(
          (s) => s.missingCount,
          'missing count',
          1,
        )),
      );
    });

    test('Case 6: Whitespace-only strings are treated as missing / Not Verified', () async {
      const documents = DriverDocumentsEntity(
        drivingLicense: '   ',
        pancard: '\t',
        passport: '  \n  ',
        aadhaarCardFront: '   ',
        aadhaarCardBack: '   ',
        selfie: ' ',
      );

      bloc.add(const LoadDocumentsEvent(documents: documents));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.verifiedCount,
          'no documents verified',
          0,
        ).having(
          (s) => s.missingCount,
          'all missing / not verified',
          5,
        )),
      );
    });

    test('Case 7: API request failure emits DocumentsError state cleanly', () async {
      fakeRepository.exceptionToThrow = Exception('Network error');

      bloc.add(const LoadDocumentsEvent(forceRefresh: true));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DocumentsLoading>(),
          isA<DocumentsError>().having((s) => s.message, 'error message', 'Network error'),
        ]),
      );
    });

    test('Case 8: RefreshDocumentsEvent refreshes and recalculates document statuses', () async {
      fakeRepository.profileToReturn = const DriverProfileEntity(
        id: 'p1',
        firstName: 'Jane',
        lastName: 'Doe',
        email: 'jane@example.com',
        phone: '1234567890',
        address: 'Main St',
        driverId: 'DRV-2',
        licenseNumber: 'DL-123',
        pancardNumber: 'PAN-123',
        aadhaarNumber: 'AAD-123',
        passportId: 'PASS-123',
        status: 'verified',
        isOnline: true,
        isVerified: true,
        createdAt: '',
        updatedAt: '',
        hasSubscription: true,
        documents: DriverDocumentsEntity(
          drivingLicense: 'https://example.com/dl.jpg',
        ),
      );

      bloc.add(const RefreshDocumentsEvent());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<DocumentsLoading>(),
          isA<DocumentsLoaded>().having(
            (s) => s.driverDocuments.firstWhere((d) => d.key == 'drivingLicense').status,
            'driving license verified after refresh',
            'Verified',
          ).having(
            (s) => s.verifiedCount,
            'verified count is 1',
            1,
          ),
        ]),
      );
    });

    test('UpdateDocumentFileEvent updates Aadhaar front/back and recalculates status', () async {
      // Start with empty documents
      bloc.add(const LoadDocumentsEvent(documents: DriverDocumentsEntity()));
      await Future.delayed(const Duration(milliseconds: 50));

      // 1. Upload Aadhaar Front -> Still Not Verified because back is missing
      bloc.add(const UpdateDocumentFileEvent(
        documentKey: 'aadhaar',
        filePath: '/storage/front.jpg',
        fileName: 'front.jpg',
        side: 'front',
      ));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').status,
          'status is Not Verified when back is still missing',
          'Not Verified',
        )),
      );

      // 2. Upload Aadhaar Back -> Now Verified because both front and back are present
      bloc.add(const UpdateDocumentFileEvent(
        documentKey: 'aadhaar',
        filePath: '/storage/back.jpg',
        fileName: 'back.jpg',
        side: 'back',
      ));

      await expectLater(
        bloc.stream,
        emits(isA<DocumentsLoaded>().having(
          (s) => s.driverDocuments.firstWhere((d) => d.key == 'aadhaar').status,
          'status is Verified when both are present',
          'Verified',
        ).having(
          (s) => s.verifiedCount,
          'verified count is 1',
          1,
        )),
      );
    });
  });
}

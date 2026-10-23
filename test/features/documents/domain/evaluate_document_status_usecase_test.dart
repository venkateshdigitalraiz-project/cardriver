import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver/features/documents/domain/entities/document_verification_status.dart';
import 'package:cardriver/features/documents/domain/usecases/evaluate_document_status_usecase.dart';

void main() {
  group('EvaluateDocumentStatusUseCase (Verified or Not Verified only)', () {
    group('isValidDocumentValue', () {
      test('returns false for null', () {
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue(null), false);
      });

      test('returns false for empty string', () {
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue(''), false);
      });

      test('returns false for whitespace only', () {
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('   '), false);
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('\t\n'), false);
      });

      test('returns false for literal "null" string', () {
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('null'), false);
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('NULL'), false);
      });

      test('returns true for valid trimmed paths/URLs', () {
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('https://example.com/doc.jpg'), true);
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('/storage/emulated/0/doc.png'), true);
        expect(EvaluateDocumentStatusUseCase.isValidDocumentValue('  valid_file.pdf  '), true);
      });
    });

    group('evaluateAadhaar', () {
      test('returns notVerified when both front and back are empty', () {
        final status = EvaluateDocumentStatusUseCase.evaluateAadhaar(
          front: '',
          back: '',
        );
        expect(status, DocumentVerificationStatus.notVerified);
        expect(status.label, 'Not Verified');
        expect(status.isVerified, false);
      });

      test('returns notVerified when both front and back are whitespace or null', () {
        final status = EvaluateDocumentStatusUseCase.evaluateAadhaar(
          front: '   ',
          back: null,
        );
        expect(status, DocumentVerificationStatus.notVerified);
        expect(status.label, 'Not Verified');
        expect(status.isVerified, false);
      });

      test('returns notVerified when only front is populated', () {
        final status = EvaluateDocumentStatusUseCase.evaluateAadhaar(
          front: 'https://example.com/front.jpg',
          back: '',
        );
        expect(status, DocumentVerificationStatus.notVerified);
        expect(status.label, 'Not Verified');
        expect(status.isVerified, false);
      });

      test('returns notVerified when only back is populated', () {
        final status = EvaluateDocumentStatusUseCase.evaluateAadhaar(
          front: '',
          back: 'https://example.com/back.jpg',
        );
        expect(status, DocumentVerificationStatus.notVerified);
        expect(status.label, 'Not Verified');
        expect(status.isVerified, false);
      });

      test('returns verified when both front and back are valid', () {
        final status = EvaluateDocumentStatusUseCase.evaluateAadhaar(
          front: 'https://example.com/front.jpg',
          back: 'https://example.com/back.jpg',
        );
        expect(status, DocumentVerificationStatus.verified);
        expect(status.label, 'Verified');
        expect(status.isVerified, true);
      });
    });

    group('evaluateSingleDocument', () {
      test('returns notVerified when file value is empty or missing', () {
        expect(
          EvaluateDocumentStatusUseCase.evaluateSingleDocument(null),
          DocumentVerificationStatus.notVerified,
        );
        expect(
          EvaluateDocumentStatusUseCase.evaluateSingleDocument(''),
          DocumentVerificationStatus.notVerified,
        );
        expect(
          EvaluateDocumentStatusUseCase.evaluateSingleDocument('   '),
          DocumentVerificationStatus.notVerified,
        );
      });

      test('returns verified when file value is valid', () {
        final status = EvaluateDocumentStatusUseCase.evaluateSingleDocument('https://example.com/license.jpg');
        expect(status, DocumentVerificationStatus.verified);
        expect(status.label, 'Verified');
        expect(status.isVerified, true);
      });
    });
  });
}

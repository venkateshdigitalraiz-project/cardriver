import 'package:flutter_bloc/flutter_bloc.dart';
import 'documents_event.dart';
import 'documents_state.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  DocumentsBloc() : super(DocumentsInitial()) {
    on<LoadDocumentsEvent>((event, emit) async {
      emit(DocumentsLoading());
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(DocumentsLoaded(
        verifiedCount: 5,
        expiringCount: 2,
        missingCount: 1,
        driverDocuments: [
          DocumentItem(
            title: 'Driving licence',
            subtitle: 'Valid till 14 Mar 2031',
            status: 'Verified',
            statusType: 'success',
          ),
          DocumentItem(
            title: 'Aadhaar card',
            subtitle: 'xxxx xxxx 4821',
            status: 'Verified',
            statusType: 'success',
          ),
          DocumentItem(
            title: 'Police verification',
            subtitle: 'Not uploaded',
            status: 'Upload',
            statusType: 'upload',
          ),
        ],
        vehicleDocuments: [
          DocumentItem(
            title: 'Registration (RC)',
            subtitle: 'Valid till 09 Jun 2033',
            status: 'Verified',
            statusType: 'success',
          ),
          DocumentItem(
            title: 'Insurance',
            subtitle: 'Expires 24 Oct 2026',
            status: '26 days',
            statusType: 'warning',
          ),
          DocumentItem(
            title: 'PUC certificate',
            subtitle: 'Expires 03 Oct 2026',
            status: '5 days',
            statusType: 'warning',
          ),
          DocumentItem(
            title: 'Fitness certificate',
            subtitle: 'Valid till 18 Jan 2028',
            status: 'Verified',
            statusType: 'success',
          ),
        ],
      ));
    });

    on<FilterDocumentsEvent>((event, emit) {
      if (state is DocumentsLoaded) {
        final currentState = state as DocumentsLoaded;
        emit(currentState.copyWith(selectedFilter: event.filterType));
      }
    });
  }
}

abstract class DocumentsEvent {}

class LoadDocumentsEvent extends DocumentsEvent {}

class FilterDocumentsEvent extends DocumentsEvent {
  final String filterType;

  FilterDocumentsEvent(this.filterType);
}

abstract class SupportState {}

class SupportInitial extends SupportState {}

class SupportLoading extends SupportState {}

class SupportCategory {
  final String title;
  final String subtitle;

  SupportCategory({
    required this.title,
    required this.subtitle,
  });
}

class SupportTicket {
  final String title;
  final String description; // "Ticket 20418 · 26 Sep"
  final String status;      // "In progress", "Resolved"

  SupportTicket({
    required this.title,
    required this.description,
    required this.status,
  });
}

class SupportLoaded extends SupportState {
  final List<SupportCategory> categories;
  final List<SupportTicket> recentTickets;

  SupportLoaded({
    required this.categories,
    required this.recentTickets,
  });
}

class SupportError extends SupportState {
  final String message;

  SupportError(this.message);
}

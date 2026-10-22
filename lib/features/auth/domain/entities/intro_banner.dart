import 'package:equatable/equatable.dart';

/// Entity representing an introductory / banner slide for the driver login screen.
class IntroBanner extends Equatable {
  final String id;
  final String section;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionUrl;
  final int order;

  const IntroBanner({
    required this.id,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionUrl,
    required this.order,
  });

  @override
  List<Object?> get props => [
        id,
        section,
        title,
        subtitle,
        imageUrl,
        actionUrl,
        order,
      ];
}

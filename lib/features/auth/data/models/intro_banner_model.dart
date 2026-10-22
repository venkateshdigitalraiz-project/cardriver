import '../../domain/entities/intro_banner.dart';

/// Data model representation of IntroBanner extending the domain entity.
class IntroBannerModel extends IntroBanner {
  const IntroBannerModel({
    required super.id,
    required super.section,
    required super.title,
    required super.subtitle,
    required super.imageUrl,
    required super.actionUrl,
    required super.order,
  });

  factory IntroBannerModel.fromJson(Map<String, dynamic> json) {
    return IntroBannerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      actionUrl: json['actionUrl']?.toString() ?? '',
      order: (json['order'] is num) ? (json['order'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'order': order,
    };
  }
}

import 'package:equatable/equatable.dart';

class DriverJobEntity extends Equatable {
  final String id;
  final String jobId;
  final String title;
  final int monthlySalary;
  final String joiningDate;
  final String description;
  final String location;
  final String jobType;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? createdAt;

  const DriverJobEntity({
    required this.id,
    required this.jobId,
    required this.title,
    required this.monthlySalary,
    required this.joiningDate,
    required this.description,
    required this.location,
    required this.jobType,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.createdAt,
  });

  factory DriverJobEntity.fromJson(Map<String, dynamic> json) {
    return DriverJobEntity(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ??
          (json['_id'] != null
              ? 'JOB-${json['_id'].toString().substring(json['_id'].toString().length > 6 ? json['_id'].toString().length - 6 : 0).toUpperCase()}'
              : 'JOB-POST'),
      title: json['title']?.toString() ?? 'Driver Requirement',
      monthlySalary: (json['monthlySalary'] as num?)?.toInt() ?? 0,
      joiningDate: json['joiningDate']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? 'full_time',
      status: json['status']?.toString().toLowerCase() ?? 'active',
      customerName: json['customerName']?.toString() ??
          json['userName']?.toString() ??
          (json['userId'] is Map ? json['userId']['name']?.toString() : null),
      customerPhone: json['customerPhone']?.toString() ??
          json['userPhone']?.toString() ??
          (json['userId'] is Map ? json['userId']['phone']?.toString() : null),
      createdAt: json['createdAt']?.toString(),
    );
  }

  String get formattedSalary {
    if (monthlySalary <= 0) return 'Negotiable';
    final str = monthlySalary.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
      } else if (count > 3 && (count - 3) % 2 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return '₹$formatted / mo';
  }

  String get formattedJobType {
    switch (jobType.toLowerCase()) {
      case 'full_time':
        return 'Full Time';
      case 'part_time':
        return 'Part Time';
      case 'contract':
        return 'Contract';
      case 'temporary':
        return 'Temporary';
      default:
        return jobType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get formattedJoiningDate {
    if (joiningDate.isEmpty) return 'Immediate';
    try {
      final dt = DateTime.parse(joiningDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      return '$day $month $year';
    } catch (_) {
      return joiningDate.split('T').first;
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt!).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      return '$day $month $year';
    } catch (_) {
      return createdAt!.split('T').first;
    }
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        title,
        monthlySalary,
        joiningDate,
        description,
        location,
        jobType,
        status,
        customerName,
        customerPhone,
        createdAt,
      ];
}

class DriverJobListResponseEntity extends Equatable {
  final bool success;
  final String message;
  final List<DriverJobEntity> jobs;
  final int total;
  final int page;
  final int limit;

  const DriverJobListResponseEntity({
    required this.success,
    required this.message,
    required this.jobs,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory DriverJobListResponseEntity.fromJson(Map<String, dynamic> json) {
    List<DriverJobEntity> jobList = [];

    dynamic items = json['data'] ?? json['jobs'] ?? json['items'];
    if (items is List) {
      jobList = items
          .whereType<Map<String, dynamic>>()
          .map((item) => DriverJobEntity.fromJson(item))
          .toList();
    } else if (items is Map<String, dynamic>) {
      if (items['jobs'] is List) {
        jobList = (items['jobs'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => DriverJobEntity.fromJson(item))
            .toList();
      }
    }

    return DriverJobListResponseEntity(
      success: json['success'] == true || json['status'] == 'success',
      message: json['message']?.toString() ?? 'Jobs fetched successfully',
      jobs: jobList,
      total: (json['total'] as num?)?.toInt() ?? jobList.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }

  @override
  List<Object?> get props => [success, message, jobs, total, page, limit];
}


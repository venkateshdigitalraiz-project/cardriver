import '../../domain/entities/d_to_d_booking_entity.dart';

/// Request model representing the exact payload required for D-to-D bookings API:
/// POST http://localhost:3000/api/driver/d-to-d-bookings
class DtoDBookingRequestModel {
  final String serviceType;
  final String tripType;
  final String bookingMode;
  final String scheduledStartTime;
  final int? durationDays;
  final int? durationHours;
  final String? returnDate;
  final String pickupAddress;
  final double pickupLng;
  final double pickupLat;
  final String dropAddress;
  final double dropLng;
  final double dropLat;
  final String vehicleType;
  final String transmission;
  final String vehicleNumber;
  final int numberOfPassengers;
  final List<String> driverReturnOption;
  final String baseAmount;
  final String driverFee;
  final String taxAmount;
  final dynamic totalAmount;
  final String estimatedDistance;
  final String userNotes;
  final String? packageNote;

  const DtoDBookingRequestModel({
    required this.serviceType,
    required this.tripType,
    this.bookingMode = 'scheduled',
    required this.scheduledStartTime,
    this.durationDays,
    this.durationHours,
    this.returnDate,
    required this.pickupAddress,
    required this.pickupLng,
    required this.pickupLat,
    required this.dropAddress,
    required this.dropLng,
    required this.dropLat,
    this.vehicleType = '',
    this.transmission = '',
    this.vehicleNumber = '',
    this.numberOfPassengers = 4,
    this.driverReturnOption = const [],
    this.baseAmount = '',
    this.driverFee = '',
    this.taxAmount = '',
    required this.totalAmount,
    this.estimatedDistance = '',
    this.userNotes = '',
    this.packageNote,
  });

  /// Helper to convert any DateTime or ISO date string to strict UTC ISO-8601 format:
  /// YYYY-MM-DDTHH:mm:ss.sssZ (e.g. 2026-11-15T08:00:00.000Z)
  static String formatToUtcIso(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      final utc = value.toUtc();
      final y = utc.year.toString().padLeft(4, '0');
      final m = utc.month.toString().padLeft(2, '0');
      final d = utc.day.toString().padLeft(2, '0');
      final h = utc.hour.toString().padLeft(2, '0');
      final min = utc.minute.toString().padLeft(2, '0');
      final s = utc.second.toString().padLeft(2, '0');
      final ms = utc.millisecond.toString().padLeft(3, '0');
      return '$y-$m-${d}T$h:$min:${s}.${ms}Z';
    }
    final str = value.toString().trim();
    if (str.isEmpty) return '';
    final parsed = DateTime.tryParse(str);
    if (parsed != null) {
      final utc = parsed.toUtc();
      final y = utc.year.toString().padLeft(4, '0');
      final m = utc.month.toString().padLeft(2, '0');
      final d = utc.day.toString().padLeft(2, '0');
      final h = utc.hour.toString().padLeft(2, '0');
      final min = utc.minute.toString().padLeft(2, '0');
      final s = utc.second.toString().padLeft(2, '0');
      final ms = utc.millisecond.toString().padLeft(3, '0');
      return '$y-$m-${d}T$h:$min:${s}.${ms}Z';
    }
    return str;
  }

  Map<String, dynamic> toJson() {
    final bool isLocal = serviceType.trim().toLowerCase() == 'local';

    final Map<String, dynamic> json = {
      'serviceType': serviceType,
      'tripType': tripType,
      'bookingMode': bookingMode,
      'scheduledStartTime': formatToUtcIso(scheduledStartTime),
      if (isLocal)
        'durationHours': durationHours ?? durationDays ?? 1
      else
        'durationDays': durationDays ?? durationHours ?? 1,
      'pickupLocation': {
        'address': pickupAddress,
        'location': {
          'type': 'Point',
          'coordinates': [pickupLng, pickupLat],
        },
      },
      'dropLocation': {
        'address': dropAddress,
        'location': {
          'type': 'Point',
          'coordinates': [dropLng, dropLat],
        },
      },
      'vehicleType': vehicleType.trim().isNotEmpty
          ? vehicleType.trim().toLowerCase()
          : 'suv',
      'transmission': transmission.trim().isNotEmpty
          ? transmission.trim().toLowerCase()
          : 'manual',
      'vehicleNumber': vehicleNumber,
      'numberOfPassengers': numberOfPassengers,
      'driverReturnOption': driverReturnOption,
      'baseAmount': baseAmount,
      'driverFee': driverFee,
      'taxAmount': taxAmount,
      'totalAmount': totalAmount,
      'estimatedDistance': estimatedDistance,
      'userNotes': userNotes,
      if (packageNote != null && packageNote!.isNotEmpty)
        'packageNote': packageNote,
    };

    if (returnDate != null && returnDate!.isNotEmpty) {
      json['returnDate'] = formatToUtcIso(returnDate);
    }

    return json;
  }
}

/// Response model that parses backend response into [DtoDBookingEntity].
class DtoDBookingResponseModel extends DtoDBookingEntity {
  const DtoDBookingResponseModel({
    super.id,
    super.bookingId,
    required super.serviceType,
    required super.tripType,
    super.bookingMode,
    required super.scheduledStartTime,
    super.durationDays,
    super.durationHours,
    super.returnDate,
    required super.pickupAddress,
    super.pickupCoordinates,
    required super.dropAddress,
    super.dropCoordinates,
    super.vehicleType,
    super.transmission,
    super.vehicleNumber,
    super.numberOfPassengers,
    super.driverReturnOption,
    super.baseAmount,
    super.driverFee,
    super.taxAmount,
    required super.totalAmount,
    super.estimatedDistance,
    super.userNotes,
    super.status,
    super.message,
    super.createdAt,
    super.rawData,
  });

  factory DtoDBookingResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend can return data either inside 'data', 'booking', or directly in root
    Map<String, dynamic> dataMap = json;
    if (json['data'] is Map<String, dynamic>) {
      dataMap = json['data'] as Map<String, dynamic>;
    } else if (json['data'] is Map) {
      dataMap = Map<String, dynamic>.from(json['data'] as Map);
    }

    Map<String, dynamic> bookingMap = dataMap;
    if (dataMap['booking'] is Map<String, dynamic>) {
      bookingMap = dataMap['booking'] as Map<String, dynamic>;
    } else if (dataMap['booking'] is Map) {
      bookingMap = Map<String, dynamic>.from(dataMap['booking'] as Map);
    }

    // Parse pickup location
    String pickupAddress = '';
    List<double> pickupCoordinates = [];
    final pickupData = bookingMap['pickupLocation'] ?? dataMap['pickupLocation'];
    if (pickupData is Map) {
      pickupAddress = pickupData['address']?.toString() ?? '';
      final loc = pickupData['location'];
      if (loc is Map && loc['coordinates'] is List) {
        pickupCoordinates = (loc['coordinates'] as List)
            .map((c) => (c as num).toDouble())
            .toList();
      }
    }

    // Parse drop location
    String dropAddress = '';
    List<double> dropCoordinates = [];
    final dropData = bookingMap['dropLocation'] ?? dataMap['dropLocation'];
    if (dropData is Map) {
      dropAddress = dropData['address']?.toString() ?? '';
      final loc = dropData['location'];
      if (loc is Map && loc['coordinates'] is List) {
        dropCoordinates = (loc['coordinates'] as List)
            .map((c) => (c as num).toDouble())
            .toList();
      }
    }

    // Return options
    List<String> returnOptions = ['ret-bus', 'ret-train'];
    final retOptData = bookingMap['driverReturnOption'] ?? dataMap['driverReturnOption'];
    if (retOptData is List) {
      returnOptions = retOptData.map((e) => e.toString()).toList();
    }

    final id = (bookingMap['_id'] ??
            bookingMap['id'] ??
            dataMap['_id'] ??
            dataMap['id'] ??
            '')
        .toString();

    final bookingId = (bookingMap['bookingId'] ??
            bookingMap['dToDBookingId'] ??
            dataMap['bookingId'] ??
            dataMap['dToDBookingId'] ??
            id)
        .toString();

    final serviceType = (bookingMap['serviceType'] ??
            dataMap['serviceType'] ??
            'outstation')
        .toString();

    final tripType = (bookingMap['tripType'] ??
            dataMap['tripType'] ??
            'one_way')
        .toString();

    final bookingMode = (bookingMap['bookingMode'] ??
            dataMap['bookingMode'] ??
            'scheduled')
        .toString();

    final scheduledStartTime = (bookingMap['scheduledStartTime'] ??
            dataMap['scheduledStartTime'] ??
            DateTime.now().toIso8601String())
        .toString();

    final durationDays = int.tryParse(
          (bookingMap['durationDays'] ?? dataMap['durationDays'] ?? '')
              .toString(),
        );

    final durationHours = int.tryParse(
          (bookingMap['durationHours'] ?? dataMap['durationHours'] ?? '')
              .toString(),
        );

    final returnDate = (bookingMap['returnDate'] ?? dataMap['returnDate'])?.toString();

    final vehicleType = (bookingMap['vehicleType'] ?? dataMap['vehicleType'] ?? '')
        .toString();
    final transmission = (bookingMap['transmission'] ?? dataMap['transmission'] ?? '')
        .toString();
    final vehicleNumber = (bookingMap['vehicleNumber'] ?? dataMap['vehicleNumber'] ?? '')
        .toString();
    final numberOfPassengers = int.tryParse(
          (bookingMap['numberOfPassengers'] ?? dataMap['numberOfPassengers'] ?? 4)
              .toString(),
        ) ??
        4;

    final baseAmount = (bookingMap['baseAmount'] ?? dataMap['baseAmount'] ?? '')
        .toString();
    final driverFee = (bookingMap['driverFee'] ?? dataMap['driverFee'] ?? '')
        .toString();
    final taxAmount = (bookingMap['taxAmount'] ?? dataMap['taxAmount'] ?? '')
        .toString();
    final totalAmount = bookingMap['totalAmount'] ?? dataMap['totalAmount'] ?? 0;
    final estimatedDistance = (bookingMap['estimatedDistance'] ??
            dataMap['estimatedDistance'] ??
            '')
        .toString();
    final userNotes = (bookingMap['userNotes'] ?? dataMap['userNotes'] ?? '')
        .toString();

    final status = (bookingMap['status'] ??
            dataMap['status'] ??
            json['status'] ??
            'confirmed')
        .toString();

    final message = (json['message'] ?? dataMap['message'] ?? 'Booking confirmed successfully')
        .toString();

    final createdAt = (bookingMap['createdAt'] ?? dataMap['createdAt'])?.toString();

    return DtoDBookingResponseModel(
      id: id,
      bookingId: bookingId,
      serviceType: serviceType,
      tripType: tripType,
      bookingMode: bookingMode,
      scheduledStartTime: scheduledStartTime,
      durationDays: durationDays,
      durationHours: durationHours,
      returnDate: returnDate,
      pickupAddress: pickupAddress,
      pickupCoordinates: pickupCoordinates,
      dropAddress: dropAddress,
      dropCoordinates: dropCoordinates,
      vehicleType: vehicleType,
      transmission: transmission,
      vehicleNumber: vehicleNumber,
      numberOfPassengers: numberOfPassengers,
      driverReturnOption: returnOptions,
      baseAmount: baseAmount,
      driverFee: driverFee,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      estimatedDistance: estimatedDistance,
      userNotes: userNotes,
      status: status,
      message: message,
      createdAt: createdAt,
      rawData: json,
    );
  }
}

/// Paginated Model parsing GET /api/driver/d-to-d-bookings response
class DtoDBookingsPaginatedModel extends DtoDBookingsPaginatedEntity {
  const DtoDBookingsPaginatedModel({
    super.bookings,
    super.total,
    super.page,
    super.limit,
    super.totalPages,
    super.hasMore,
  });

  factory DtoDBookingsPaginatedModel.fromJson(
    Map<String, dynamic> json, {
    int requestedPage = 1,
    int requestedLimit = 10,
  }) {
    List<dynamic> listJson = [];
    int total = 0;
    int page = requestedPage;
    int limit = requestedLimit;
    int totalPages = 1;

    if (json['data'] is Map) {
      final dataMap = json['data'] as Map;
      if (dataMap['bookings'] is List) {
        listJson = dataMap['bookings'] as List;
      } else if (dataMap['dToDBookings'] is List) {
        listJson = dataMap['dToDBookings'] as List;
      } else if (dataMap['items'] is List) {
        listJson = dataMap['items'] as List;
      } else if (dataMap['rides'] is List) {
        listJson = dataMap['rides'] as List;
      }

      if (dataMap['pagination'] is Map) {
        final pagMap = dataMap['pagination'] as Map;
        total = int.tryParse(pagMap['total']?.toString() ?? '') ??
            listJson.length;
        page =
            int.tryParse(pagMap['page']?.toString() ?? '') ?? requestedPage;
        limit =
            int.tryParse(pagMap['limit']?.toString() ?? '') ?? requestedLimit;
        totalPages = int.tryParse(
              pagMap['pages']?.toString() ??
                  pagMap['totalPages']?.toString() ??
                  '',
            ) ??
            (total > 0 ? (total / limit).ceil() : 1);
      } else {
        total = int.tryParse(dataMap['total']?.toString() ?? '') ??
            listJson.length;
        totalPages = total > 0 ? (total / limit).ceil() : 1;
      }
    } else if (json['data'] is List) {
      listJson = json['data'] as List;
      total = listJson.length;
    } else if (json['bookings'] is List) {
      listJson = json['bookings'] as List;
      total = int.tryParse(json['total']?.toString() ?? '') ?? listJson.length;
    }

    final parsedBookings = listJson
        .whereType<Map>()
        .map(
          (item) => DtoDBookingResponseModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    if (total == 0) total = parsedBookings.length;
    final hasMore = (page * limit) < total;

    return DtoDBookingsPaginatedModel(
      bookings: parsedBookings,
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages > 0 ? totalPages : 1,
      hasMore: hasMore,
    );
  }
}


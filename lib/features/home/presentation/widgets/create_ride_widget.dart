import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/place_address_utils.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../data/models/d_to_d_booking_model.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Screen for Driver-to-Driver Ride Booking.
/// Designed with an ultra-clean, modern, executive mobile interface.
/// Built strictly following Clean Architecture with BLoC state management.
class BookingDriverPage extends StatefulWidget {
  final CustomerEntity? customer;
  final HomeBloc? homeBloc;

  const BookingDriverPage({super.key, this.customer, this.homeBloc});

  @override
  State<BookingDriverPage> createState() => _BookingDriverPageState();
}

/// Backward compatibility aliases for existing router definitions
typedef CreateRidePage = BookingDriverPage;
typedef CreateRideWidget = BookingDriverPage;
typedef DtoDCreateBookingPage = BookingDriverPage;
typedef DtoDCreateBookingWidget = BookingDriverPage;

class _BookingDriverPageState extends State<BookingDriverPage> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _fromAddressController = TextEditingController();
  final _toAddressController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _durationController = TextEditingController(text: '2');

  // Service & Trip Type State
  String _serviceType = 'local';
  String _tripType = 'one_way';
  String _transmission = 'manual';

  // Additional Charges State (Conditional)
  bool _rapidoChargesSelected = false;
  String? _selectedOutstationTransit; // 'bus', 'train', or null
  bool _foodAndRoomSelected = false;
  final Set<String> _selectedReturnVehicles = <String>{};

  // Coordinates
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;

  // Selected Date & Time
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    // Default vehicleType to 'suv'
    _vehicleTypeController.text = 'suv';

    // Default to next date (tomorrow) plus 30 minutes
    final now = DateTime.now();
    _selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day + 1,
      now.hour,
      now.minute,
    ).add(const Duration(minutes: 30));
    _updateDateTimeDisplay();

    // Reactive listeners for dynamic summary updates
    _priceController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _vehicleTypeController.addListener(_onFieldChanged);
    _durationController.addListener(_onFieldChanged);

    // Fetch common charges from API when BookingDriverPage screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = widget.homeBloc ?? context.read<HomeBloc>();
        bloc.add(LoadCommonChargesEvent(token: widget.customer?.token));
      }
    });
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _updateDateTimeDisplay() {
    if (_selectedDateTime != null) {
      _dateTimeController.text = DateFormat(
        'EEE, dd MMM yyyy • hh:mm a',
      ).format(_selectedDateTime!);
    } else {
      _dateTimeController.clear();
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final nextDate = DateTime(now.year, now.month, now.day + 1);
    final initialDate =
        (_selectedDateTime != null && !_selectedDateTime!.isBefore(nextDate))
            ? _selectedDateTime!
            : DateTime(
                nextDate.year,
                nextDate.month,
                nextDate.day,
                now.hour,
                now.minute,
              );
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: nextDate,
      lastDate: nextDate.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedDateTime ?? now.add(const Duration(hours: 1)),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _updateDateTimeDisplay();
    });
  }

  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _vehicleTypeController.removeListener(_onFieldChanged);
    _durationController.removeListener(_onFieldChanged);
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _fromAddressController.dispose();
    _toAddressController.dispose();
    _priceController.dispose();
    _dateTimeController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker({required bool isPickup}) async {
    FocusScope.of(context).unfocus();
    final double? initLat = isPickup ? _pickupLat : _dropLat;
    final double? initLng = isPickup ? _pickupLng : _dropLng;

    final PlaceAddressDetails? result = await context.push<PlaceAddressDetails>(
      AppRoutes.locationPickerMap,
      extra: {
        'initialLat': initLat,
        'initialLng': initLng,
        'title': isPickup ? 'Pickup Location' : 'Drop Location',
        'isPickup': isPickup,
      },
    );

    if (result != null && mounted) {
      final chosenAddress = result.shortAddress.isNotEmpty
          ? result.shortAddress
          : result.formattedAddress;
      setState(() {
        if (isPickup) {
          _fromAddressController.text = chosenAddress;
          _pickupLat = result.lat;
          _pickupLng = result.lng;
        } else {
          _toAddressController.text = chosenAddress;
          _dropLat = result.lat;
          _dropLng = result.lng;
        }
      });
    }
  }

  void _addQuickFare(int amount) {
    final current = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final updated = current + amount;
    _priceController.text = updated % 1 == 0
        ? updated.toInt().toString()
        : updated.toStringAsFixed(0);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;

    final driverPhone = _phoneController.text.trim();
    final vehicleTypeRaw = _vehicleTypeController.text.trim();
    final vehicleType = vehicleTypeRaw.isNotEmpty
        ? vehicleTypeRaw.toLowerCase()
        : 'suv';
    final transmission = _transmission.trim().toLowerCase();
    final pickupLocation = _fromAddressController.text.trim();
    final dropLocation = _toAddressController.text.trim();
    final fareText = _priceController.text.trim();
    final price = double.tryParse(fareText);
    final durationText = _durationController.text.trim();
    final durationVal = int.tryParse(durationText);

    // Identify missing required fields
    final List<String> missingFields = [];
    if (pickupLocation.isEmpty) missingFields.add('Pickup Location');
    if (dropLocation.isEmpty) missingFields.add('Drop Location');
    if (driverPhone.isEmpty) missingFields.add('Driver Phone Number');
    if (fareText.isEmpty) missingFields.add('Ride Price');
    if (_selectedDateTime == null) missingFields.add('Pickup Schedule');
    if (durationText.isEmpty) {
      missingFields.add(
        _serviceType == 'local' ? 'Duration Hours' : 'Duration Days',
      );
    }

    if (missingFields.isNotEmpty) {
      if (missingFields.length == 1) {
        final field = missingFields.first;
        if (field == 'Pickup Schedule') {
          _showErrorSnackBar('Please select $field');
        } else {
          _showErrorSnackBar('Please enter $field');
        }
      } else {
        _showErrorSnackBar(
          'Missing required fields: ${missingFields.join(", ")}',
        );
      }
      return;
    }

    // Validate driver phone format
    if (driverPhone.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(driverPhone)) {
      _showErrorSnackBar('Driver mobile number must be exactly 10 digits');
      return;
    }

    // Validate location lengths
    if (pickupLocation.length < 3) {
      _showErrorSnackBar('Please enter a valid pickup location');
      return;
    }
    if (dropLocation.length < 3) {
      _showErrorSnackBar('Please enter a valid destination location');
      return;
    }
    if (pickupLocation.toLowerCase() == dropLocation.toLowerCase()) {
      _showErrorSnackBar('Pickup and drop locations cannot be identical');
      return;
    }

    // Validate fare price
    if (price == null || price <= 0) {
      _showErrorSnackBar('Please enter a valid ride price greater than ₹0');
      return;
    }

    // Validate duration
    if (durationVal == null || durationVal <= 0) {
      _showErrorSnackBar(
        _serviceType == 'local'
            ? 'Duration hours must be a valid number greater than 0'
            : 'Duration days must be a valid number greater than 0',
      );
      return;
    }

    // Validate pickup schedule
    if (_selectedDateTime!.isBefore(
      DateTime.now().subtract(const Duration(minutes: 5)),
    )) {
      _showErrorSnackBar('Pickup schedule time cannot be in the past');
      return;
    }

    if (!isFormValid) {
      _showErrorSnackBar('Please correct highlighted fields');
      return;
    }

    // Build DtoDBookingRequestModel adhering exactly to API specs:
    // POST http://localhost:3000/api/driver/d-to-d-bookings
    // "totalAmount": pass ride price,
    // "baseAmount": "",
    // "driverFee": "",
    // "taxAmount": "",
    // "estimatedDistance": "",
    // "driverReturnOption": ["ret-bus", "ret-train"] if outstation & one_way, else []
    // "durationHours": if local replaces "durationDays"
    // "vehicleType": "",
    // "transmission": "",
    // "vehicleNumber": ""
    final bool isLocal = _serviceType.trim().toLowerCase() == 'local';
    final bool isOneWay = _tripType.trim().toLowerCase() == 'one_way';

    final List<String> returnOptions = <String>[];
    if (isOneWay) {
      if (_selectedReturnVehicles.isNotEmpty) {
        returnOptions.addAll(_selectedReturnVehicles);
      } else if (isLocal && _rapidoChargesSelected) {
        returnOptions.add('ret-rapido');
      } else if (!isLocal && _selectedOutstationTransit != null) {
        returnOptions.add('ret-$_selectedOutstationTransit');
      }
    } else if (!isLocal && !isOneWay) {
      if (_foodAndRoomSelected) {
        returnOptions.add('ret-food-room');
      }
    }

    // Format dates to strict UTC ISO format (e.g. 2026-11-15T08:00:00.000Z) before API call
    final String scheduledStartTimeUtc = DtoDBookingRequestModel.formatToUtcIso(
      _selectedDateTime!,
    );

    String? returnDateUtc;
    if (_tripType == 'round_trip' || _serviceType == 'outstation') {
      final calculatedReturnDate = isLocal
          ? _selectedDateTime!.add(Duration(hours: durationVal))
          : _selectedDateTime!.add(Duration(days: durationVal));
      returnDateUtc = DtoDBookingRequestModel.formatToUtcIso(
        calculatedReturnDate,
      );
    }

    final request = DtoDBookingRequestModel(
      serviceType: _serviceType,
      tripType: _tripType,
      bookingMode: 'scheduled',
      scheduledStartTime: scheduledStartTimeUtc,
      durationHours: isLocal ? durationVal : null,
      durationDays: !isLocal ? durationVal : null,
      returnDate: returnDateUtc,
      pickupAddress: pickupLocation,
      pickupLng: _pickupLng ?? 78.4352,
      pickupLat: _pickupLat ?? 17.4156,
      dropAddress: dropLocation,
      dropLng: _dropLng ?? 80.6480,
      dropLat: _dropLat ?? 16.5062,
      vehicleType: vehicleType,
      transmission: transmission,
      vehicleNumber: '',
      numberOfPassengers: 4,
      driverReturnOption: returnOptions,
      baseAmount: '',
      driverFee: '',
      taxAmount: '',
      totalAmount: price % 1 == 0 ? price.toInt() : price,
      estimatedDistance: '',
      userNotes: () {
        final List<String> notes = [];
        if (driverPhone.isNotEmpty) notes.add('Driver Mobile: $driverPhone');
        if (isOneWay && _selectedReturnVehicles.isNotEmpty) {
          notes.add('Return travel: ${_selectedReturnVehicles.join(", ")}');
        } else if (isLocal && isOneWay && _rapidoChargesSelected) {
          notes.add('Rapido return travel charges included');
        } else if (!isLocal && isOneWay && _selectedOutstationTransit != null) {
          notes.add(
            '${_selectedOutstationTransit == 'bus' ? 'Bus' : 'Train'} return travel charges included',
          );
        } else if (!isLocal && !isOneWay && _foodAndRoomSelected) {
          notes.add('Food & Room Maintenance included');
        }
        return notes.isNotEmpty
            ? notes.join(' • ')
            : 'Customer needs experienced highway driver';
      }(),
    );

    log('======================================================');
    log('🚀 [BookingDriverPage] Submitting D-to-D Booking API:');
    log('📦 Payload: ${request.toJson()}');
    log('======================================================');

    final messenger = ScaffoldMessenger.of(context);
    final bloc = widget.homeBloc ?? context.read<HomeBloc>();

    bloc.add(
      CreateDtoDBookingEvent(
        request: request,
        token: widget.customer?.token,
        onSuccess: (booking) {
          if (!mounted) return;
          log(
            '✅ [BookingDriverPage] Booking successfully confirmed: ${booking.bookingId}',
          );

          if (context.canPop()) {
            context.pop();
          } else {
            Navigator.of(context).pop();
          }

          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.bookingId.isNotEmpty
                              ? 'Driver booking confirmed (#${booking.bookingId})!'
                              : 'Driver booking posted successfully!',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Driver: +91 $driverPhone • ₹${price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        },
        onError: (errorMessage) {
          if (!mounted) return;
          log('❌ [BookingDriverPage] Booking submission failed: $errorMessage');
          _showErrorSnackBar(errorMessage);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F172A),
          surface: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomActionBar(),
        body: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Trip Route (Uber-style unified location picker)
                    _buildRouteCard(),

                    const SizedBox(height: 14),

                    // Section 2: Service & Trip Type (Modern Segmented Selectors)
                    _buildServiceAndTripTypeCard(),

                    const SizedBox(height: 14),

                    // Section 3: Schedule Date & Time
                    _buildScheduleCard(),

                    const SizedBox(height: 14),

                    // Section 4: Driver Phone & Fare Details
                    _buildDriverAndFareCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Modern, Clean AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8, right: 4),
        child: InkWell(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ),
      title: Text(
        'Post Driver Booking',
        style: GoogleFonts.outfit(
          color: const Color(0xFF0F172A),
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Reset Form',
          icon: const Icon(
            Icons.refresh_rounded,
            size: 20,
            color: Color(0xFF64748B),
          ),
          onPressed: () {
            setState(() {
              _fromAddressController.clear();
              _toAddressController.clear();
              _pickupLat = null;
              _pickupLng = null;
              _dropLat = null;
              _dropLng = null;
              _phoneController.clear();
              _priceController.clear();
              _vehicleTypeController.text = 'suv';
              _serviceType = 'local';
              _tripType = 'one_way';
              _transmission = 'manual';
              _rapidoChargesSelected = false;
              _selectedOutstationTransit = null;
              _foodAndRoomSelected = false;
              _selectedReturnVehicles.clear();
              _durationController.text = '2';
              final now = DateTime.now();
              _selectedDateTime = DateTime(
                now.year,
                now.month,
                now.day + 1,
                now.hour,
                now.minute,
              ).add(const Duration(minutes: 30));
              _updateDateTimeDisplay();
            });
          },
        ),
        const SizedBox(width: 6),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF1F5F9), height: 1),
      ),
    );
  }

  /// Section 1: Route Card (Minimalist Uber-Style Timeline)
  Widget _buildRouteCard() {
    final hasFrom = _fromAddressController.text.isNotEmpty;
    final hasTo = _toAddressController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: [
          // 1. Pickup Row
          InkWell(
            onTap: () => _openMapPicker(isPickup: true),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Green circular pin
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Pickup Address Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PICKUP LOCATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasFrom
                              ? _fromAddressController.text
                              : 'Tap to select pickup point on map',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasFrom
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: hasFrom
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasFrom)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _fromAddressController.clear();
                          _pickupLat = null;
                          _pickupLng = null;
                        });
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 17,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Timeline connector divider
          Padding(
            padding: const EdgeInsets.only(left: 13),
            child: Row(
              children: [
                Container(width: 2, height: 18, color: const Color(0xFFCBD5E1)),
                const SizedBox(width: 25),
                const Expanded(
                  child: Divider(
                    height: 1,
                    thickness: 0.8,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
          ),

          // 2. Drop Row
          InkWell(
            onTap: () => _openMapPicker(isPickup: false),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  // Dark Square Pin
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Drop Address Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DROP LOCATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasTo
                              ? _toAddressController.text
                              : 'Tap to select destination on map',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: hasTo
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: hasTo
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hasTo)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        setState(() {
                          _toAddressController.clear();
                          _dropLat = null;
                          _dropLng = null;
                        });
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.map_outlined,
                      size: 17,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 2: Service Type, Trip Type & Duration (Modern Segmented Selectors)
  Widget _buildServiceAndTripTypeCard() {
    final isLocal = _serviceType == 'local';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Service Type Segmented Selector
          _buildFieldSectionLabel('Service Type'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentOption(
                    title: 'Local',
                    subtitle: 'Within city',
                    icon: Icons.apartment_rounded,
                    isSelected: isLocal,
                    onTap: () {
                      if (!isLocal) {
                        setState(() {
                          _serviceType = 'local';
                          _selectedReturnVehicles.clear();
                          if (_durationController.text.trim().isEmpty ||
                              _durationController.text.trim() == '1') {
                            _durationController.text = '2';
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildSegmentOption(
                    title: 'Outstation',
                    subtitle: 'Inter-city travel',
                    icon: Icons.directions_car_rounded,
                    isSelected: !isLocal,
                    onTap: () {
                      if (isLocal) {
                        setState(() {
                          _serviceType = 'outstation';
                          _selectedReturnVehicles.clear();
                          if (_durationController.text.trim().isEmpty ||
                              _durationController.text.trim() == '2') {
                            _durationController.text = '1';
                          }
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Row 2: Trip Type Segmented Selector
          _buildFieldSectionLabel('Trip Type'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentOption(
                    title: 'One Way',
                    subtitle: 'Single drop',
                    icon: Icons.arrow_forward_rounded,
                    isSelected: _tripType == 'one_way',
                    onTap: () {
                      if (_tripType != 'one_way') {
                        setState(() {
                          _tripType = 'one_way';
                          _selectedReturnVehicles.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildSegmentOption(
                    title: 'Round Trip',
                    subtitle: 'Return journey',
                    icon: Icons.sync_alt_rounded,
                    isSelected: _tripType == 'round_trip',
                    onTap: () {
                      if (_tripType != 'round_trip') {
                        setState(() {
                          _tripType = 'round_trip';
                          _selectedReturnVehicles.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Conditional Additional Charges (Return Vehicles / Food & Room)
          if (_shouldShowAdditionalCharges) ...[
            // Case 2: Outstation + One Way -> Remove the _buildFieldSectionLabel() widget
            const SizedBox(height: 16),
            _buildFieldSectionLabel('Return Charges'),

            if (!(!isLocal && _tripType == 'one_way')) ...[
              const SizedBox(height: 16),
              _buildFieldSectionLabel(
                _serviceType == 'outstation' && _tripType == 'round_trip'
                    ? 'Driver Allowance & Maintenance'
                    : 'Additional Return Charges',
              ),
              const SizedBox(height: 8),
            ] else ...[
              const SizedBox(height: 12),
            ],
            _buildAdditionalChargesCard(),
          ],

          const SizedBox(height: 16),

          // Row 3: Duration Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFieldSectionLabel(
                isLocal ? 'Duration (Hours)' : 'Duration (Days)',
              ),
              Text(
                isLocal ? 'Min 1 hour' : 'Min 1 day',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: const Color(0xFF0F172A),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              hintText: isLocal ? 'e.g. 2, 4, 8' : 'e.g. 1, 2, 3',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Icon(
                isLocal
                    ? Icons.schedule_rounded
                    : Icons.calendar_view_day_rounded,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              suffixIcon: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Text(
                  isLocal ? 'Hours' : 'Days',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isLocal ? 'Enter duration hours' : 'Enter duration days';
              }
              final val = int.tryParse(value.trim());
              if (val == null || val <= 0) {
                return 'Duration must be greater than 0';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Determines if any additional charges widget should be rendered
  bool get _shouldShowAdditionalCharges {
    final bool isLocal = _serviceType.trim().toLowerCase() == 'local';
    final bool isOneWay = _tripType.trim().toLowerCase() == 'one_way';

    // Condition 1: Local + One Way -> Rapido Charges
    if (isLocal && isOneWay) return true;

    // Condition 2: Outstation + One Way -> Bus & Train Options
    if (!isLocal && isOneWay) return true;

    // Condition 3: Outstation + Round Trip -> Food & Room Maintenance
    if (!isLocal && !isOneWay) return true;

    // Condition 4: Local + Round Trip -> Hide all
    return false;
  }

  /// Conditional Additional Charges Widget switcher
  Widget _buildAdditionalChargesCard() {
    final bool isLocal = _serviceType.trim().toLowerCase() == 'local';
    final bool isOneWay = _tripType.trim().toLowerCase() == 'one_way';

    // Case 1: Local + One Way -> Dynamically from local.one_way.returnVehicles
    if (isLocal && isOneWay) {
      return _buildReturnVehiclesSelector(isLocal: true);
    }

    // Case 2: Outstation + One Way -> Dynamically from outstation.one_way.returnVehicles
    if (!isLocal && isOneWay) {
      return _buildReturnVehiclesSelector(isLocal: false);
    }

    // Case 3: Outstation + Round Trip -> Food & Room Maintenance Checkbox Card
    if (!isLocal && !isOneWay) {
      return _buildFoodAndRoomMaintenanceCard();
    }

    // Case 4: Local + Round Trip -> Hide all
    return const SizedBox.shrink();
  }

  /// Displays returnVehicles dynamically from API as horizontally scrollable selectable checkbox items.
  Widget _buildReturnVehiclesSelector({required bool isLocal}) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, current) =>
          prev.isLoadingCommonCharges != current.isLoadingCommonCharges ||
          prev.commonChargesList != current.commonChargesList,
      builder: (context, state) {
        final charges = state.currentCharges;
        final List<String> vehicles = isLocal
            ? (charges?.local?.oneWay?.returnVehicles ?? const [])
            : (charges?.outstation?.oneWay?.returnVehicles ?? const []);

        if (state.isLoadingCommonCharges && vehicles.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          );
        }

        if (vehicles.isEmpty) {
          return const SizedBox.shrink();
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: vehicles.map((vehicle) {
              final isSelected = _selectedReturnVehicles.contains(vehicle);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildReturnVehicleChip(
                  vehicle: vehicle,
                  isSelected: isSelected,
                  isLocal: isLocal,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedReturnVehicles.remove(vehicle);
                      } else {
                        _selectedReturnVehicles.clear();
                        _selectedReturnVehicles.add(vehicle);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Single selectable vehicle card item with checkbox
  Widget _buildReturnVehicleChip({
    required String vehicle,
    required bool isSelected,
    required bool isLocal,
    required VoidCallback onTap,
  }) {
    final Color activeBorderColor = isLocal
        ? const Color(0xFFD97706)
        : const Color(0xFF2563EB);
    final Color activeBgColor = isSelected
        ? (isLocal ? const Color(0xFFFFFBEB) : const Color(0xFFEFF6FF))
        : Colors.white;
    final Color activeIndicatorColor = isLocal
        ? const Color(0xFFD97706)
        : const Color(0xFF2563EB);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: activeBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? activeBorderColor : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0F172A,
            ).withValues(alpha: isSelected ? 0.05 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeIndicatorColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected
                          ? activeIndicatorColor
                          : const Color(0xFFCBD5E1),
                      width: 1.6,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                // Vehicle Icon
                Icon(
                  _getTransitIcon(vehicle),
                  size: 18,
                  color: isSelected
                      ? activeIndicatorColor
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                // Vehicle Name
                Text(
                  vehicle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps vehicle name to an intuitive icon
  IconData _getTransitIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bus')) {
      return Icons.directions_bus_filled_rounded;
    } else if (lower.contains('train')) {
      return Icons.train_rounded;
    } else if (lower.contains('cab') || lower.contains('taxi')) {
      return Icons.local_taxi_rounded;
    } else if (lower.contains('bike') ||
        lower.contains('rapido') ||
        lower.contains('two')) {
      return Icons.two_wheeler_rounded;
    } else {
      return Icons.directions_car_rounded;
    }
  }

  /// Condition 3: Outstation + Round Trip -> Food & Room Maintenance Checkbox Card
  Widget _buildFoodAndRoomMaintenanceCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _foodAndRoomSelected ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _foodAndRoomSelected
              ? const Color(0xFF059669)
              : const Color(0xFFE2E8F0),
          width: _foodAndRoomSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF0F172A,
            ).withValues(alpha: _foodAndRoomSelected ? 0.06 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _foodAndRoomSelected = !_foodAndRoomSelected;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _foodAndRoomSelected
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _foodAndRoomSelected
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.night_shelter_rounded,
                      size: 22,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: _foodAndRoomSelected
                              ? const Color(0xFF059669).withValues(alpha: 0.12)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.restaurant_rounded,
                              size: 11,
                              color: _foodAndRoomSelected
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'DRIVER ALLOWANCE',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: _foodAndRoomSelected
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Food & Room Maintenance',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Provide food and accommodation expenses for the driver',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Custom animated checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _foodAndRoomSelected
                          ? const Color(0xFF0F172A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _foodAndRoomSelected
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFCBD5E1),
                        width: 1.8,
                      ),
                    ),
                    child: _foodAndRoomSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Segmented pill tab button
  Widget _buildSegmentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Section 3: Schedule Date & Time Card
  Widget _buildScheduleCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldSectionLabel('Pickup Schedule'),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      color: Color(0xFF0F172A),
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date & Time',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedDateTime != null &&
                                  _dateTimeController.text.isNotEmpty
                              ? _dateTimeController.text
                              : 'Tap to select date & time',
                          style: TextStyle(
                            color: _selectedDateTime != null
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                            fontSize: 13.5,
                            fontWeight: _selectedDateTime != null
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 4: Driver Phone & Fare Details Card
  Widget _buildDriverAndFareCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Driver Mobile Number
          _buildFieldSectionLabel('Driver Mobile Number'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
            cursorColor: const Color(0xFF0F172A),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: '98765 43210',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '+91',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 16,
                      width: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ],
                ),
              ),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _phoneController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter 10-digit driver mobile number';
              }
              final trimmed = value.trim();
              if (trimmed.length != 10 ||
                  !RegExp(r'^\d{10}$').hasMatch(trimmed)) {
                return 'Driver mobile number must be 10 digits';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 2. Ride Price / Fare
          _buildFieldSectionLabel('Ride Price / Fare (₹)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: const Color(0xFF0F172A),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      height: 18,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                  ],
                ),
              ),
              suffixIcon: _priceController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _priceController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter ride price / fare';
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid price greater than ₹0';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // 3. Vehicle Type
          _buildFieldSectionLabel('vehicleType'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _vehicleTypeController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: const Color(0xFF0F172A),
            decoration: InputDecoration(
              hintText: 'e.g. suv, sedan, hatchback',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: const Icon(
                Icons.directions_car_filled_rounded,
                size: 20,
                color: Color(0xFF64748B),
              ),
              suffixIcon: _vehicleTypeController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _vehicleTypeController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['suv', 'sedan', 'hatchback'].map((type) {
              final isSelected =
                  _vehicleTypeController.text.trim().toLowerCase() == type;
              return InkWell(
                onTap: () {
                  setState(() {
                    _vehicleTypeController.text = type;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 4. Transmission
          _buildFieldSectionLabel('transmission'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentOption(
                    title: 'Manual',
                    subtitle: 'Manual gear',
                    icon: Icons.tune_rounded,
                    isSelected: _transmission == 'manual',
                    onTap: () {
                      if (_transmission != 'manual') {
                        setState(() => _transmission = 'manual');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildSegmentOption(
                    title: 'Automatic',
                    subtitle: 'Auto gear',
                    icon: Icons.directions_car_rounded,
                    isSelected: _transmission == 'automatic',
                    onTap: () {
                      if (_transmission != 'automatic') {
                        setState(() => _transmission = 'automatic');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Bar with Real-time Summary
  Widget _buildBottomActionBar() {
    final fareText = _priceController.text.trim();
    final driverPhone = _phoneController.text.trim();
    final vehicleType = _vehicleTypeController.text.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_serviceType == 'local' ? 'Local' : 'Outstation'} • ${_tripType == 'one_way' ? 'One Way' : 'Round Trip'}',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_tripType == 'one_way' &&
                            _selectedReturnVehicles.isNotEmpty) ...[
                          for (final vehicle in _selectedReturnVehicles) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _serviceType == 'local'
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '+ $vehicle',
                                style: TextStyle(
                                  color: _serviceType == 'local'
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF2563EB),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ] else if (_serviceType == 'local' &&
                            _tripType == 'one_way' &&
                            _rapidoChargesSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '+ Rapido',
                              style: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ] else if (_serviceType == 'outstation' &&
                            _tripType == 'one_way' &&
                            _selectedOutstationTransit != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _selectedOutstationTransit == 'bus'
                                  ? '+ Bus'
                                  : '+ Train',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ] else if (_serviceType == 'outstation' &&
                            _tripType == 'round_trip' &&
                            _foodAndRoomSelected) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '+ Food & Room',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        if (vehicleType.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vehicleType.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        if (driverPhone.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '+91 $driverPhone',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  fareText.isNotEmpty ? '₹$fareText' : 'Price pending',
                  style: TextStyle(
                    color: fareText.isNotEmpty
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Primary CTA button with Clean Architecture Bloc State Integration
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                final isSubmitting = state.isSubmittingDtoDBooking;
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF0F172A,
                      ).withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Confirm Driver Booking',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontWeight: FontWeight.w600,
        fontSize: 13,
        letterSpacing: 0.1,
      ),
    );
  }
}

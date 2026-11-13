import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/cache/common_charges_cache.dart';
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
  final _noteController = TextEditingController();

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
    _noteController.addListener(_onFieldChanged);

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
    _noteController.removeListener(_onFieldChanged);
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _fromAddressController.dispose();
    _toAddressController.dispose();
    _priceController.dispose();
    _dateTimeController.dispose();
    _durationController.dispose();
    _noteController.dispose();
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
    setState(() {});
  }

  void _setQuickDuration(String val) {
    _durationController.text = val;
    setState(() {});
  }

  void _incrementDuration() {
    final current = int.tryParse(_durationController.text.trim()) ?? 1;
    _durationController.text = (current + 1).toString();
    setState(() {});
  }

  void _decrementDuration() {
    final current = int.tryParse(_durationController.text.trim()) ?? 1;
    if (current > 1) {
      _durationController.text = (current - 1).toString();
      setState(() {});
    }
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

    final bool isLocal = _serviceType.trim().toLowerCase() == 'local';
    final bool isOneWay = _tripType.trim().toLowerCase() == 'one_way';

    // Validation: Outstation Round Trip requires trip inclusions checkbox selection
    if (!isLocal && !isOneWay) {
      if (!_foodAndRoomSelected) {
        _showErrorSnackBar(
          'Please select the trip inclusions checkbox before confirming booking',
        );
        return;
      }
    }

    // Resolve dynamic note text from CommonChargesCache / HomeBloc state (outstation.round_trip.note)
    final charges = context.read<HomeBloc>().state.currentCharges ??
        CommonChargesCache.instance.currentCharges;
    final dynamicNote = charges?.outstation?.roundTrip?.note.trim() ?? '';
    final String resolvedNote = dynamicNote.isNotEmpty
        ? dynamicNote
        : 'inclusive with food and room';

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
        returnOptions.add(resolvedNote);
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

    final String? packageNote = (!isLocal && !isOneWay && _foodAndRoomSelected)
        ? resolvedNote
        : null;

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
      packageNote: packageNote,
      baseAmount: '',
      driverFee: '',
      taxAmount: '',
      totalAmount: price % 1 == 0 ? price.toInt() : price,
      estimatedDistance: '',
      userNotes: _noteController.text.trim(),
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
          primary: Color(0xFFD97706),
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
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 28),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clean, Light Header Info Banner (NO black background)
                    _buildHeaderInfoStrip(),

                    const SizedBox(height: 12),

                    // Section 1: Compact Route Card (Uber-style timeline)
                    _buildRouteCard(),

                    const SizedBox(height: 12),

                    // Section 2: Service & Trip Journey Type
                    _buildServiceAndTripTypeCard(),

                    const SizedBox(height: 12),

                    // Section 3: Compact Schedule & Duration (2-Column Space-Efficient Card)
                    _buildScheduleAndDurationCard(),

                    const SizedBox(height: 12),

                    // Section 4: Compact Driver Mobile & Fare Details
                    _buildDriverAndFareCard(),

                    const SizedBox(height: 12),

                    // Section 5: Vehicle & Transmission Options
                    _buildVehicleAndTransmissionCard(),

                    const SizedBox(height: 12),

                    // Section 6: Trip Note
                    _buildTripNoteCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Clean, Modern AppBar
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

  /// Clean Light Header Strip (NO black background)
  Widget _buildHeaderInfoStrip() {
    final bool isLocal = _serviceType == 'local';
    final bool isOneWay = _tripType == 'one_way';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 18,
                  color: Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver-to-Driver Ride',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Broadcast booking to active network',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Text(
              '${isLocal ? "LOCAL" : "OUTSTATION"} • ${isOneWay ? "1-WAY" : "ROUND"}',
              style: GoogleFonts.inter(
                color: const Color(0xFFB45309),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 1: Compact Route Card (Uber-Style Timeline)
  Widget _buildRouteCard() {
    final hasFrom = _fromAddressController.text.isNotEmpty;
    final hasTo = _toAddressController.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        children: [
          // 1. Pickup Row
          InkWell(
            onTap: () => _openMapPicker(isPickup: true),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PICKUP POINT',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          hasFrom
                              ? _fromAddressController.text
                              : 'Tap to select pickup point on map',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: hasFrom ? FontWeight.w600 : FontWeight.w400,
                            color: hasFrom
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (hasFrom)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _fromAddressController.clear();
                          _pickupLat = null;
                          _pickupLng = null;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      size: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Micro Connector
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              children: [
                Container(width: 2, height: 14, color: const Color(0xFFCBD5E1)),
                const SizedBox(width: 20),
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
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DROP DESTINATION',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFD97706),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          hasTo
                              ? _toAddressController.text
                              : 'Tap to select destination on map',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: hasTo ? FontWeight.w600 : FontWeight.w400,
                            color: hasTo
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (hasTo)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _toAddressController.clear();
                          _dropLat = null;
                          _dropLng = null;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      size: 16,
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

  /// Section 2: Service & Trip Type (Compact Segmented Tabs)
  Widget _buildServiceAndTripTypeCard() {
    final isLocal = _serviceType == 'local';
    final isOneWay = _tripType == 'one_way';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Service Type Segmented Selector
          Row(
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildSegmentOption(
                  title: 'Outstation',
                  subtitle: 'Inter-city',
                  icon: Icons.explore_rounded,
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

          const SizedBox(height: 8),

          // Row 2: Trip Type Segmented Selector
          Row(
            children: [
              Expanded(
                child: _buildSegmentOption(
                  title: 'One Way',
                  subtitle: 'Single drop',
                  icon: Icons.arrow_forward_rounded,
                  isSelected: isOneWay,
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
              const SizedBox(width: 8),
              Expanded(
                child: _buildSegmentOption(
                  title: 'Round Trip',
                  subtitle: 'Return journey',
                  icon: Icons.sync_alt_rounded,
                  isSelected: !isOneWay,
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

          // Conditional Additional Charges (Return Vehicles / Trip Includes)
          if (_shouldShowAdditionalCharges) ...[
            const SizedBox(height: 10),
            _buildAdditionalChargesCard(),
          ],
        ],
      ),
    );
  }

  /// Section 3: Compact Schedule & Duration (2-Column Space-Efficient Card)
  Widget _buildScheduleAndDurationCard() {
    final isLocal = _serviceType == 'local';
    final durationVal = _durationController.text.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Column 1: Schedule Picker
                Expanded(
                  child: InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'SCHEDULE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _selectedDateTime != null &&
                                    _dateTimeController.text.isNotEmpty
                                ? _dateTimeController.text
                                : 'Select Time',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF0F172A),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to change',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Column 2: Duration Stepper
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isLocal ? 'DURATION' : 'DAYS',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Decrement
                            InkWell(
                              onTap: _decrementDuration,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.remove, size: 16, color: Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                            // Value Display
                            Text(
                              isLocal
                                  ? '$durationVal ${durationVal == "1" ? "hr" : "hrs"}'
                                  : '$durationVal ${durationVal == "1" ? "day" : "days"}',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            // Increment
                            InkWell(
                              onTap: _incrementDuration,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: const Center(
                                  child: Icon(Icons.add, size: 16, color: Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Quick Duration Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: (isLocal
                      ? ['2', '4', '6', '8', '12']
                      : ['1', '2', '3', '5', '7'])
                  .map((val) {
                final isSelected = _durationController.text.trim() == val;
                final label = isLocal ? '$val hrs' : '$val day${val == "1" ? "" : "s"}';
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _setQuickDuration(val),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF92400E) : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 4: Compact Driver Mobile & Fare Details
  Widget _buildDriverAndFareCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Driver Phone Field
          Text(
            'Driver Mobile Number',
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            cursorColor: const Color(0xFFD97706),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              hintText: '10-digit mobile number',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 10, right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 16,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '+91',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(height: 16, width: 1, color: const Color(0xFFCBD5E1)),
                  ],
                ),
              ),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _phoneController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter 10-digit driver mobile number';
              }
              final trimmed = value.trim();
              if (trimmed.length != 10 || !RegExp(r'^\d{10}$').hasMatch(trimmed)) {
                return 'Driver mobile number must be 10 digits';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // 2. Ride Fare Field
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ride Price / Fare (₹)',
                style: GoogleFonts.inter(
                  color: const Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
              Text(
                'Total Payable',
                style: GoogleFonts.inter(
                  color: const Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(
              color: const Color(0xFF0F172A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            cursorColor: const Color(0xFFD97706),
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.outfit(
                color: const Color(0xFF94A3B8),
                fontSize: 17,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(height: 18, width: 1, color: const Color(0xFFCBD5E1)),
                  ],
                ),
              ),
              suffixIcon: _priceController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _priceController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
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

          const SizedBox(height: 6),

          // Quick-Add Fare Chips (+ ₹100, + ₹200, + ₹500, + ₹1000, + ₹2000)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [100, 200, 500, 1000, 2000].map((amt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _addQuickFare(amt),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '+ ₹$amt',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Section 5: Vehicle Category & Transmission
  Widget _buildVehicleAndTransmissionCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Category',
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildVehicleCategoryCard(
                  typeKey: 'suv',
                  title: 'SUV',
                  subtitle: '6-7 Seater',
                  icon: Icons.directions_car_filled_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleCategoryCard(
                  typeKey: 'sedan',
                  title: 'Sedan',
                  subtitle: '4 Seater',
                  icon: Icons.directions_car_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildVehicleCategoryCard(
                  typeKey: 'hatchback',
                  title: 'Hatchback',
                  subtitle: 'Compact',
                  icon: Icons.minor_crash_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Transmission',
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
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
              const SizedBox(width: 8),
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
        ],
      ),
    );
  }

  /// Section 6: Trip Note
  Widget _buildTripNoteCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Notes / Special Instructions',
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _noteController,
            keyboardType: TextInputType.multiline,
            maxLines: 2,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.inter(
              color: const Color(0xFF0F172A),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: const Color(0xFFD97706),
            decoration: InputDecoration(
              hintText: 'Enter pickup notes or instructions for driver...',
              hintStyle: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              suffixIcon: _noteController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _noteController.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF94A3B8)),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vehicle Type Selection Card
  Widget _buildVehicleCategoryCard({
    required String typeKey,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _vehicleTypeController.text.trim().toLowerCase() == typeKey;

    return InkWell(
      onTap: () {
        setState(() {
          _vehicleTypeController.text = typeKey;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? const Color(0xFFD97706) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected ? const Color(0xFF92400E) : const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFFB45309) : const Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
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
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? const Color(0xFFD97706)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: isSelected
                        ? const Color(0xFF92400E)
                        : const Color(0xFF0F172A),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: isSelected
                        ? const Color(0xFFB45309)
                        : const Color(0xFF94A3B8),
                    fontSize: 9.5,
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

  /// Determines if any additional charges widget should be rendered
  bool get _shouldShowAdditionalCharges {
    final bool isLocal = _serviceType.trim().toLowerCase() == 'local';
    final bool isOneWay = _tripType.trim().toLowerCase() == 'one_way';

    if (isLocal && isOneWay) return true;
    if (!isLocal && isOneWay) return true;
    if (!isLocal && !isOneWay) return true;
    return false;
  }

  /// Conditional Additional Charges Widget switcher
  Widget _buildAdditionalChargesCard() {
    final bool isLocal = _serviceType.trim().toLowerCase() == 'local';
    final bool isOneWay = _tripType.trim().toLowerCase() == 'one_way';

    if (isLocal && isOneWay) {
      return _buildReturnVehiclesSelector(isLocal: true);
    }
    if (!isLocal && isOneWay) {
      return _buildReturnVehiclesSelector(isLocal: false);
    }
    if (!isLocal && !isOneWay) {
      return _buildFoodAndRoomMaintenanceCard();
    }
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
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFD97706),
                ),
              ),
            ),
          );
        }

        if (vehicles.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLocal ? 'Return Transit' : 'Return Travel Option',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: vehicles.map((vehicle) {
                  final isSelected = _selectedReturnVehicles.contains(vehicle);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
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
            ),
          ],
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD97706) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(width: 6),
                Icon(
                  _getTransitIcon(vehicle),
                  size: 15,
                  color: isSelected ? const Color(0xFFD97706) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  vehicle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF92400E) : const Color(0xFF334155),
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
    } else if (lower.contains('train') || lower.contains('metro')) {
      return Icons.train_rounded;
    } else if (lower.contains('cab') || lower.contains('taxi')) {
      return Icons.local_taxi_rounded;
    } else if (lower.contains('auto') || lower.contains('rickshaw')) {
      return Icons.electric_rickshaw_rounded;
    } else if (lower.contains('bike') ||
        lower.contains('rapido') ||
        lower.contains('two')) {
      return Icons.two_wheeler_rounded;
    } else {
      return Icons.directions_car_rounded;
    }
  }

  /// Condition 3: Outstation + Round Trip -> Trip Includes Checkbox Card
  Widget _buildFoodAndRoomMaintenanceCard() {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (prev, current) =>
          prev.isLoadingCommonCharges != current.isLoadingCommonCharges ||
          prev.commonChargesList != current.commonChargesList,
      builder: (context, state) {
        final charges = state.currentCharges ??
            CommonChargesCache.instance.currentCharges;
        final String noteText = charges?.outstation?.roundTrip?.note.trim() ??
            CommonChargesCache.instance.currentCharges?.outstation?.roundTrip?.note.trim() ??
            'inclusive with food and room';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _foodAndRoomSelected ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _foodAndRoomSelected
                  ? const Color(0xFF059669)
                  : const Color(0xFFE2E8F0),
              width: _foodAndRoomSelected ? 1.5 : 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _foodAndRoomSelected = !_foodAndRoomSelected;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _foodAndRoomSelected
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.hotel_rounded,
                          size: 18,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Trip Includes',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            noteText.isNotEmpty
                                ? noteText
                                : 'inclusive with food and room',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: _foodAndRoomSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _foodAndRoomSelected
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _foodAndRoomSelected
                            ? const Color(0xFF059669)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: _foodAndRoomSelected
                              ? const Color(0xFF059669)
                              : const Color(0xFFCBD5E1),
                          width: 1.6,
                        ),
                      ),
                      child: _foodAndRoomSelected
                          ? const Center(
                              child: Icon(Icons.check_rounded, size: 13, color: Colors.white),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Sticky Bottom Action Bar with Real-time Summary (NO black background)
  Widget _buildBottomActionBar() {
    final fareText = _priceController.text.trim();
    final driverPhone = _phoneController.text.trim();
    final vehicleType = _vehicleTypeController.text.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
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
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_serviceType == 'local' ? 'Local' : 'Outstation'} • ${_tripType == 'one_way' ? '1-Way' : 'Round'}',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB45309),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (vehicleType.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              vehicleType.toUpperCase(),
                              style: GoogleFonts.inter(
                                color: const Color(0xFF0F172A),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        if (driverPhone.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '+91 $driverPhone',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF64748B),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  fareText.isNotEmpty ? '₹$fareText' : 'Fare pending',
                  style: GoogleFonts.outfit(
                    color: fareText.isNotEmpty
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Primary CTA Button with Radiant Driver Yellow/Gold Gradient (NO black button)
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                final isSubmitting = state.isSubmittingDtoDBooking;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: const Color(0xFF0F172A),
                      disabledBackgroundColor: const Color(0xFFFFB800).withValues(alpha: 0.6),
                      elevation: 2,
                      shadowColor: const Color(0xFFFFB800).withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: isSubmitting
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFFFB800), Color(0xFFFF8A00)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F172A)),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Post Driver Booking',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.flash_on_rounded,
                                    size: 18,
                                    color: Color(0xFF0F172A),
                                  ),
                                ],
                              ),
                      ),
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
}

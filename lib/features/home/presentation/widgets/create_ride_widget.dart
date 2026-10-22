import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../auth/domain/entities/customer_entity.dart';
import '../../data/services/location_autocomplete_service.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

/// Screen / Widget to manually create a new ride entry for the driver.
/// Built with Clean Architecture & BLoC state management.
/// Features a modern, professional Rapido / Uber driver style interface.
class CreateRidePage extends StatefulWidget {
  final CustomerEntity? customer;
  final HomeBloc? homeBloc;

  const CreateRidePage({super.key, this.customer, this.homeBloc});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

/// Also exported as CreateRideWidget for convenience
typedef CreateRideWidget = CreateRidePage;

class _CreateRidePageState extends State<CreateRidePage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _fromAddressController = TextEditingController();
  final _toAddressController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateTimeController = TextEditingController();

  final _fromFocusNode = FocusNode();
  final _toFocusNode = FocusNode();

  final _locationService = LocationAutocompleteService();

  Timer? _debounceTimer;
  List<LocationSuggestion> _fromSuggestions = [];
  List<LocationSuggestion> _toSuggestions = [];
  bool _isLoadingFrom = false;
  bool _isLoadingTo = false;
  bool _showFromDropdown = false;
  bool _showToDropdown = false;
  String _lastFromQuery = '';
  String _lastToQuery = '';

  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      if (widget.customer!.name.isNotEmpty) {
        _usernameController.text = widget.customer!.name;
      }
      if (widget.customer!.phone.isNotEmpty) {
        _phoneController.text = widget.customer!.phone;
      }
    }
    _updateDateTimeDisplay();

    // Rebuild listeners for real-time preview updates in bottom bar
    _priceController.addListener(_onPriceChanged);
    _usernameController.addListener(_onUsernameChanged);
  }

  void _onPriceChanged() {
    setState(() {});
  }

  void _onUsernameChanged() {
    setState(() {});
  }

  void _updateDateTimeDisplay() {
    _dateTimeController.text =
        DateFormat('EEE, dd MMM yyyy • hh:mm a').format(_selectedDateTime);
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
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
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
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
    _debounceTimer?.cancel();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    _locationService.dispose();
    _priceController.removeListener(_onPriceChanged);
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    _phoneController.dispose();
    _fromAddressController.dispose();
    _toAddressController.dispose();
    _priceController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  void _onFromAddressChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();

    if (clean.length < 2) {
      setState(() {
        _fromSuggestions = [];
        _showFromDropdown = false;
        _isLoadingFrom = false;
      });
      return;
    }

    setState(() {
      _isLoadingFrom = true;
      _showFromDropdown = true;
      _showToDropdown = false;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      _lastFromQuery = clean;
      final results = await _locationService.getSuggestions(clean);

      if (mounted && _lastFromQuery == clean) {
        setState(() {
          _fromSuggestions = results;
          _isLoadingFrom = false;
          _showFromDropdown = true;
        });
      }
    });
  }

  void _onToAddressChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();

    if (clean.length < 2) {
      setState(() {
        _toSuggestions = [];
        _showToDropdown = false;
        _isLoadingTo = false;
      });
      return;
    }

    setState(() {
      _isLoadingTo = true;
      _showToDropdown = true;
      _showFromDropdown = false;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      _lastToQuery = clean;
      final results = await _locationService.getSuggestions(clean);

      if (mounted && _lastToQuery == clean) {
        setState(() {
          _toSuggestions = results;
          _isLoadingTo = false;
          _showToDropdown = true;
        });
      }
    });
  }

  Future<void> _selectFromSuggestion(LocationSuggestion suggestion) async {
    _fromAddressController.text = suggestion.fullAddress;
    setState(() {
      _showFromDropdown = false;
      _fromSuggestions = [];
    });
    _fromFocusNode.unfocus();

    final coords = await _locationService.getPlaceCoordinates(
      suggestion.placeId,
    );
    if (coords != null && mounted) {
      setState(() {
        _pickupLat = coords.lat;
        _pickupLng = coords.lng;
      });
    }
  }

  Future<void> _selectToSuggestion(LocationSuggestion suggestion) async {
    _toAddressController.text = suggestion.fullAddress;
    setState(() {
      _showToDropdown = false;
      _toSuggestions = [];
    });
    _toFocusNode.unfocus();

    final coords = await _locationService.getPlaceCoordinates(
      suggestion.placeId,
    );
    if (coords != null && mounted) {
      setState(() {
        _dropLat = coords.lat;
        _dropLng = coords.lng;
      });
    }
  }

  void _addQuickFare(int amount) {
    final current = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final updated = current + amount;
    _priceController.text = updated % 1 == 0
        ? updated.toInt().toString()
        : updated.toStringAsFixed(2);
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      if (price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid fare price greater than ₹0'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final bloc = widget.homeBloc ?? context.read<HomeBloc>();
      bloc.add(
        CreateManualRideEvent(
          userName: _usernameController.text.trim(),
          mobileNumber: _phoneController.text.trim(),
          fromAddress: _fromAddressController.text.trim(),
          toAddress: _toAddressController.text.trim(),
          price: price,
          dateTime: _selectedDateTime,
          pickupLat: _pickupLat,
          pickupLng: _pickupLng,
          dropLat: _dropLat,
          dropLng: _dropLng,
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ride created successfully for ${_usernameController.text.trim()} (₹${price.toStringAsFixed(0)})!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF10B981),
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
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _showFromDropdown = false;
                _showToDropdown = false;
              });
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Passenger Information Card
                    _buildPassengerCard(),

                    const SizedBox(height: 16),

                    // Route & Locations Card (Rapido/Uber style with visual connector)
                    _buildRouteCard(),

                    const SizedBox(height: 16),

                    // Fare & Timing Card
                    _buildFareAndScheduleCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Create New Ride',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Manual Passenger Booking',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 3),
              Text(
                'Direct Ride',
                style: TextStyle(
                  color: Color(0xFF065F46),
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFE2E8F0), height: 1),
      ),
    );
  }


  Widget _buildPassengerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.person_rounded,
            iconBgColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
            iconColor: const Color(0xFF2563EB),
            title: 'Passenger Details',
            subtitle: 'Customer identity and contact number',
          ),
          const SizedBox(height: 16),

          // Passenger Username
          _buildFieldLabel('PASSENGER NAME', isRequired: true),
          TextFormField(
            controller: _usernameController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: const Color(0xFF10B981),
            decoration: _buildInputDecoration(
              hint: 'e.g. John Doe',
              icon: Icons.person_outline_rounded,
              iconColor: const Color(0xFF3B82F6),
              suffixIcon: _usernameController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _usernameController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter passenger name';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Mobile Number
          _buildFieldLabel('MOBILE NUMBER', isRequired: true),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            cursorColor: const Color(0xFF10B981),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: _buildInputDecoration(
              hint: '98765 43210',
              prefixWidget: Container(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 18,
                      color: Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
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
                      height: 18,
                      width: 1,
                      color: const Color(0xFFCBD5E1),
                    ),
                  ],
                ),
              ),
              suffixIcon: _phoneController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _phoneController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter 10-digit mobile number';
              }
              final trimmed = value.trim();
              if (trimmed.length != 10) {
                return 'Mobile number must be exactly 10 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.alt_route_rounded,
            iconBgColor: const Color(0xFF10B981).withValues(alpha: 0.12),
            iconColor: const Color(0xFF10B981),
            title: 'Trip Route',
            subtitle: 'Enter pickup and drop addresses',
          ),
          const SizedBox(height: 16),

          // Visual Route Connector Container
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Route Indicator (Dots + Vertical Line)
              Padding(
                padding: const EdgeInsets.only(top: 28, right: 12),
                child: Column(
                  children: [
                    // Green Pickup Dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF10B981),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    // Vertical Dash/Line
                    Container(
                      width: 2,
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF10B981), Color(0xFFEF4444)],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    // Red Drop Square
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFEF4444),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Inputs Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From Location Address
                    _buildFieldLabel('PICKUP LOCATION', isRequired: true),
                    TextFormField(
                      controller: _fromAddressController,
                      focusNode: _fromFocusNode,
                      maxLines: 2,
                      minLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFF10B981),
                      decoration: _buildInputDecoration(
                        hint: 'Search pickup location',
                        icon: Icons.my_location_rounded,
                        iconColor: const Color(0xFF10B981),
                        suffixIcon: _isLoadingFrom
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              )
                            : (_fromAddressController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      onPressed: () {
                                        _fromAddressController.clear();
                                        setState(() {
                                          _showFromDropdown = false;
                                          _fromSuggestions = [];
                                        });
                                      },
                                    )
                                  : null),
                      ),
                      onChanged: _onFromAddressChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter pickup location';
                        }
                        return null;
                      },
                    ),
                    if (_showFromDropdown)
                      _buildSuggestionsDropdown(
                        suggestions: _fromSuggestions,
                        isLoading: _isLoadingFrom,
                        iconColor: const Color(0xFF10B981),
                        onSelect: _selectFromSuggestion,
                      ),

                    const SizedBox(height: 18),

                    // To Location Address
                    _buildFieldLabel('DROP-OFF DESTINATION', isRequired: true),
                    TextFormField(
                      controller: _toAddressController,
                      focusNode: _toFocusNode,
                      maxLines: 2,
                      minLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFF10B981),
                      decoration: _buildInputDecoration(
                        hint: 'Search destination address',
                        icon: Icons.location_on_rounded,
                        iconColor: const Color(0xFFEF4444),
                        suffixIcon: _isLoadingTo
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                              )
                            : (_toAddressController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear_rounded,
                                        size: 18,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      onPressed: () {
                                        _toAddressController.clear();
                                        setState(() {
                                          _showToDropdown = false;
                                          _toSuggestions = [];
                                        });
                                      },
                                    )
                                  : null),
                      ),
                      onChanged: _onToAddressChanged,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter destination address';
                        }
                        return null;
                      },
                    ),
                    if (_showToDropdown)
                      _buildSuggestionsDropdown(
                        suggestions: _toSuggestions,
                        isLoading: _isLoadingTo,
                        iconColor: const Color(0xFFEF4444),
                        onSelect: _selectToSuggestion,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareAndScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.payments_rounded,
            iconBgColor: const Color(0xFFF59E0B).withValues(alpha: 0.12),
            iconColor: const Color(0xFFD97706),
            title: 'Fare & Schedule',
            subtitle: 'Ride pricing and scheduled departure',
          ),
          const SizedBox(height: 16),

          // Price Field
          _buildFieldLabel('RIDE FARE (₹)', isRequired: true),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            cursorColor: const Color(0xFF10B981),
            decoration: _buildInputDecoration(
              hint: '0.00',
              prefixWidget: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    SizedBox(width: 8),
                    SizedBox(
                      height: 18,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
              suffixIcon: _priceController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        _priceController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter fare price';
              }
              final parsed = double.tryParse(value.trim());
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid price greater than ₹0';
              }
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Quick Add Fare Chips (Rapido/Uber feature)
          Row(
            children: [
              const Text(
                'Quick Add: ',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Wrap(
                spacing: 6,
                children: [50, 100, 200, 500].map((amt) {
                  return InkWell(
                    onTap: () => _addQuickFare(amt),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        '+₹$amt',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Date & Time Picker Tile
          _buildFieldLabel('PICKUP SCHEDULE', isRequired: true),
          InkWell(
            onTap: _pickDateTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF4F46E5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date & Departure Time',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dateTimeController.text.isNotEmpty
                              ? _dateTimeController.text
                              : 'Select date & time',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
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
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_calendar_rounded,
                          size: 14,
                          color: Color(0xFF4F46E5),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
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

  Widget _buildBottomActionBar() {
    final fareText = _priceController.text.trim();
    final passengerName = _usernameController.text.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fare and Passenger Summary Line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      passengerName.isNotEmpty
                          ? passengerName
                          : 'New Passenger',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Text(
                  fareText.isNotEmpty ? 'Total: ₹$fareText' : 'Fare not set',
                  style: TextStyle(
                    color: fareText.isNotEmpty
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Confirm & Create Ride Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Confirm & Create Ride',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (fareText.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₹$fareText',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w400,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          if (isRequired)
            const Text(
              ' *',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    IconData? icon,
    Color? iconColor,
    Widget? prefixWidget,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon:
          prefixWidget ??
          (icon != null
              ? Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF64748B),
                  size: 20,
                )
              : null),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }

  Widget _buildSuggestionsDropdown({
    required List<LocationSuggestion> suggestions,
    required bool isLoading,
    required Color iconColor,
    required ValueChanged<LocationSuggestion> onSelect,
  }) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(iconColor),
            ),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.search_off_rounded, size: 18, color: Color(0xFF94A3B8)),
            SizedBox(width: 8),
            Text(
              'No matching locations found',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: suggestions.length,
          separatorBuilder: (_, _) =>
              Divider(height: 1, thickness: 0.8, color: Colors.grey.shade100),
          itemBuilder: (context, index) {
            final item = suggestions[index];
            return InkWell(
              onTap: () => onSelect(item),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: iconColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.mainText,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.secondaryText.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.secondaryText,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

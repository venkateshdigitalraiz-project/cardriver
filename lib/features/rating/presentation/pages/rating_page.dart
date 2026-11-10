import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/rating_bloc.dart';
import '../bloc/rating_event.dart';
import '../bloc/rating_state.dart';

class RatingPageArgs {
  final String bookingId;
  final String customerName;
  final String customerId;
  final String pickupAddress;
  final String dropAddress;
  final String totalFare;
  final String? driverToken;
  final String? avatarUrl;
  final String? title;
  final String? subtitle;
  final String? prompt;
  final String? driverName;
  final String? driverPhoto;
  final String? vehicleInfo;
  final String? tripInfo;

  const RatingPageArgs({
    this.bookingId = '',
    this.customerName = '',
    this.customerId = '',
    this.pickupAddress = '',
    this.dropAddress = '',
    this.totalFare = '',
    this.driverToken,
    this.avatarUrl,
    this.title,
    this.subtitle,
    this.prompt,
    this.driverName,
    this.driverPhoto,
    this.vehicleInfo,
    this.tripInfo,
  });

  factory RatingPageArgs.fromMap(Map<String, dynamic> map) {
    return RatingPageArgs(
      bookingId: map['bookingId']?.toString() ?? '',
      customerName:
          map['customerName']?.toString() ??
          map['driverName']?.toString() ??
          '',
      customerId: map['customerId']?.toString() ?? '',
      pickupAddress: map['pickupAddress']?.toString() ?? '',
      dropAddress: map['dropAddress']?.toString() ?? '',
      totalFare: map['totalFare']?.toString() ?? '',
      driverToken: map['driverToken']?.toString(),
      avatarUrl: map['avatarUrl']?.toString() ?? map['driverPhoto']?.toString(),
      title: map['title']?.toString(),
      subtitle: map['subtitle']?.toString(),
      prompt: map['prompt']?.toString(),
      driverName: map['driverName']?.toString(),
      driverPhoto:
          map['driverPhoto']?.toString() ?? map['avatarUrl']?.toString(),
      vehicleInfo: map['vehicleInfo']?.toString(),
      tripInfo: map['tripInfo']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'customerName': customerName,
      'customerId': customerId,
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'totalFare': totalFare,
      'driverToken': driverToken,
      'avatarUrl': avatarUrl,
      'title': title,
      'subtitle': subtitle,
      'prompt': prompt,
      'driverName': driverName,
      'driverPhoto': driverPhoto,
      'vehicleInfo': vehicleInfo,
      'tripInfo': tripInfo,
    };
  }

  RatingPageArgs copyWith({
    String? bookingId,
    String? customerName,
    String? customerId,
    String? pickupAddress,
    String? dropAddress,
    String? totalFare,
    String? driverToken,
    String? avatarUrl,
    String? title,
    String? subtitle,
    String? prompt,
    String? driverName,
    String? driverPhoto,
    String? vehicleInfo,
    String? tripInfo,
  }) {
    return RatingPageArgs(
      bookingId: bookingId ?? this.bookingId,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      totalFare: totalFare ?? this.totalFare,
      driverToken: driverToken ?? this.driverToken,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      prompt: prompt ?? this.prompt,
      driverName: driverName ?? this.driverName,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      tripInfo: tripInfo ?? this.tripInfo,
    );
  }
}

class RatingPage extends StatelessWidget {
  final RatingPageArgs? args;

  const RatingPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final effectiveArgs = args ?? const RatingPageArgs();
    return BlocProvider(
      create: (_) => InjectionContainer.createRatingBloc(),
      child: _RatingView(args: effectiveArgs),
    );
  }
}

class _RatingView extends StatefulWidget {
  final RatingPageArgs args;

  const _RatingView({required this.args});

  @override
  State<_RatingView> createState() => _RatingViewState();
}

class _RatingViewState extends State<_RatingView> {
  late final TextEditingController _commentController;

  static const List<_FeedbackChipData> _chips = [
    _FeedbackChipData('Polite', Icons.sentiment_satisfied_alt_rounded),
    _FeedbackChipData('Safe Drive', Icons.check_rounded),
    _FeedbackChipData('On Time', Icons.access_time_rounded),
    _FeedbackChipData('Clean Car', Icons.directions_car_rounded),
    _FeedbackChipData('Professional', Icons.thumb_up_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return BlocConsumer<RatingBloc, RatingState>(
      listener: (context, state) {
        if (state.status == RatingSubmissionStatus.success) {
          _showCelebrationDialog(context);
        } else if (state.status == RatingSubmissionStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ??
                    'Failed to submit rating. Please try again.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF1E293B),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              widget.args.title ?? 'Rate Your Driver',
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // 1. Hero Artwork with City Skyline, White Car, Avatar & Sparkles
                  _buildHeroIllustration(),
                  const SizedBox(height: 18),

                  // 2. Headings
                  Text(
                    widget.args.prompt ?? 'How was your ride?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.args.subtitle ??
                        'Your feedback helps us improve our service',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Golden Star Rating Row (.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)
                  _buildStarRatingRow(context, state.score),
                  const SizedBox(height: 20),

                  // 4. Feedback Chips matching attached image
                  _buildChipsSection(context, state.selectedTags),
                  const SizedBox(height: 20),

                  // 5. Add Comment Box with Pencil Icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2, right: 8),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  maxLength: 200,
                                  maxLines: 2,
                                  onChanged: (val) {
                                    setState(() {});
                                    context.read<RatingBloc>().add(
                                      CommentChangedEvent(val),
                                    );
                                  },
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Add a comment (optional)...',
                                    hintStyle: TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 13.5,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_commentController.text.length}/200',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 6. Vibrant Blue Pill Submit Rating Button ->
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: primaryBlue.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed:
                            state.status == RatingSubmissionStatus.submitting
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                context.read<RatingBloc>().add(
                                  SubmitRatingEvent(
                                    bookingId: widget.args.bookingId,
                                    token: widget.args.driverToken,
                                    targetId: widget.args.customerId,
                                    targetName: widget.args.customerName,
                                  ),
                                );
                              },
                        child: state.status == RatingSubmissionStatus.submitting
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
                                    'Submit Rating',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 7. Decorative Footer Illustration (City waves & Little Blue Car)
                  const _BottomCityCarIllustration(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= 1. Hero Artwork Illustration =================
  Widget _buildHeroIllustration() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft skyline & cloud gradients
          Positioned.fill(child: CustomPaint(painter: _HeaderSkylinePainter())),

          // White Sedan Car Graphic on the Left
          Positioned(
            left: MediaQuery.of(context).size.width * 0.16,
            bottom: 44,
            child: Container(
              width: 90,
              height: 48,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const _CarVectorGraphic(color: Colors.white),
            ),
          ),

          // Central Driver Portrait Avatar with White Border
          Positioned(
            bottom: 12,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Avatar circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        widget.args.avatarUrl != null &&
                            widget.args.avatarUrl!.isNotEmpty
                        ? Image.network(
                            widget.args.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _defaultDriverAvatar(),
                          )
                        : _defaultDriverAvatar(),
                  ),
                ),

                // Blue Car Badge Icon at bottom-right
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0066FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),

                // Top-right Sparkle Yellow Rays (\ | /)
                Positioned(
                  top: -8,
                  right: -12,
                  child: CustomPaint(
                    size: const Size(26, 26),
                    painter: _SparkleRaysPainter(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultDriverAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Image.network(
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fit=crop&w=300&q=80',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            widget.args.customerName.isNotEmpty
                ? widget.args.customerName[0].toUpperCase()
                : 'D',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // ================= 3. Star Rating Row (.5 to 5.0) =================
  Widget _buildStarRatingRow(BuildContext context, double currentRating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1; // 1, 2, 3, 4, 5
        final isFull = currentRating >= starNumber;
        final isHalf = !isFull && currentRating >= (starNumber - 0.5);

        IconData iconData;
        Color starColor;

        if (isFull) {
          iconData = Icons.star_rounded;
          starColor = const Color(0xFFFFB800);
        } else if (isHalf) {
          iconData = Icons.star_half_rounded;
          starColor = const Color(0xFFFFB800);
        } else {
          iconData = Icons.star_rounded;
          starColor = const Color(
            0xFFE2E8F0,
          ); // Light grey star as in attached design
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: (isFull || isHalf) ? 1.12 : 1.0,
                  curve: Curves.easeOutBack,
                  child: Icon(iconData, size: 46, color: starColor),
                ),
                // Left half tap zone
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<RatingBloc>().add(
                        RatingScoreChangedEvent(starNumber - 0.5),
                      );
                    },
                  ),
                ),
                // Right half tap zone
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 24,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<RatingBloc>().add(
                        RatingScoreChangedEvent(starNumber.toDouble()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================= 4. Feedback Chips Section =================
  Widget _buildChipsSection(BuildContext context, List<String> selectedTags) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: Polite, Safe Drive, On Time
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChipItem(context, _chips[0], selectedTags),
              const SizedBox(width: 8),
              _buildChipItem(context, _chips[1], selectedTags),
              const SizedBox(width: 8),
              _buildChipItem(context, _chips[2], selectedTags),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: Clean Car, Professional
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChipItem(context, _chips[3], selectedTags),
              const SizedBox(width: 8),
              _buildChipItem(context, _chips[4], selectedTags),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipItem(
    BuildContext context,
    _FeedbackChipData data,
    List<String> selectedTags,
  ) {
    final isSelected = selectedTags.contains(data.label);
    const primaryBlue = Color(0xFF0066FF);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.read<RatingBloc>().add(TagToggledEvent(data.label));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryBlue : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF1E293B),
            ),
            const SizedBox(width: 6),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCelebrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your review helps us keep our service quality exceptional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FeedbackChipData {
  final String label;
  final IconData icon;
  const _FeedbackChipData(this.label, this.icon);
}

// ================= Custom Painters for Visual Fidelity =================

/// Draws the soft sky-blue city silhouette behind the avatar
class _HeaderSkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE0F2FE), Color(0xFFF0F9FF), Colors.white],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final bldgPaint = Paint()
      ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    // Draw stylized buildings silhouette
    final path = Path();
    final h = size.height * 0.72;
    path.moveTo(0, h);
    path.lineTo(size.width * 0.08, h);
    path.lineTo(size.width * 0.08, h - 30);
    path.lineTo(size.width * 0.16, h - 30);
    path.lineTo(size.width * 0.16, h - 18);
    path.lineTo(size.width * 0.24, h - 18);
    path.lineTo(size.width * 0.24, h - 45);
    path.lineTo(size.width * 0.32, h - 45);
    path.lineTo(size.width * 0.32, h - 22);
    path.lineTo(size.width * 0.68, h - 22);
    path.lineTo(size.width * 0.68, h - 40);
    path.lineTo(size.width * 0.76, h - 40);
    path.lineTo(size.width * 0.76, h - 15);
    path.lineTo(size.width * 0.84, h - 15);
    path.lineTo(size.width * 0.84, h - 32);
    path.lineTo(size.width * 0.92, h - 32);
    path.lineTo(size.width * 0.92, h);
    path.lineTo(size.width, h);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, bldgPaint);

    // Soft white bottom fade curve
    final fadePaint = Paint()
      ..shader =
          LinearGradient(
            colors: [Colors.white.withValues(alpha: 0.0), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.65,
              size.width,
              size.height * 0.35,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35),
      fadePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws 3 golden sparkle rays on the top-right of avatar
class _SparkleRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB800)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Ray 1: Top-Left
    canvas.drawLine(const Offset(4, 18), const Offset(12, 10), paint);
    // Ray 2: Top
    canvas.drawLine(const Offset(16, 20), const Offset(20, 6), paint);
    // Ray 3: Top-Right
    canvas.drawLine(const Offset(22, 22), const Offset(26, 14), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stylized Sedan Car vector
class _CarVectorGraphic extends StatelessWidget {
  final Color color;
  const _CarVectorGraphic({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CarPainter(color: color));
  }
}

class _CarPainter extends CustomPainter {
  final Color color;
  const _CarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final windowPaint = Paint()
      ..color = const Color(0xFF60A5FA).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final wheelPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final rimPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Car Body Path
    final body = Path();
    body.moveTo(w * 0.05, h * 0.65);
    body.quadraticBezierTo(w * 0.05, h * 0.45, w * 0.15, h * 0.45);
    body.lineTo(w * 0.30, h * 0.45);
    body.quadraticBezierTo(w * 0.40, h * 0.20, w * 0.55, h * 0.20);
    body.lineTo(w * 0.75, h * 0.20);
    body.quadraticBezierTo(w * 0.88, h * 0.25, w * 0.95, h * 0.50);
    body.lineTo(w * 0.98, h * 0.65);
    body.quadraticBezierTo(w * 0.98, h * 0.72, w * 0.92, h * 0.72);
    body.lineTo(w * 0.08, h * 0.72);
    body.quadraticBezierTo(w * 0.05, h * 0.72, w * 0.05, h * 0.65);
    body.close();
    canvas.drawPath(body, bodyPaint);

    // Front & Back Windows
    final window = Path();
    window.moveTo(w * 0.35, h * 0.43);
    window.lineTo(w * 0.43, h * 0.25);
    window.lineTo(w * 0.72, h * 0.25);
    window.lineTo(w * 0.82, h * 0.43);
    window.close();
    canvas.drawPath(window, windowPaint);

    // Wheels
    final wheelRadius = h * 0.16;
    canvas.drawCircle(Offset(w * 0.25, h * 0.72), wheelRadius, wheelPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), wheelRadius, wheelPaint);
    canvas.drawCircle(Offset(w * 0.25, h * 0.72), wheelRadius * 0.5, rimPaint);
    canvas.drawCircle(Offset(w * 0.78, h * 0.72), wheelRadius * 0.5, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom Decorative Skyline & Wave with little Blue Car
class _BottomCityCarIllustration extends StatelessWidget {
  const _BottomCityCarIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // City skyline silhouette & layered blue waves
          Positioned.fill(child: CustomPaint(painter: _BottomWavePainter())),
          // Little Blue Car traveling on top of the wave
          Positioned(
            bottom: 30,
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0066FF).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const _CarVectorGraphic(color: Color(0xFF0066FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle light blue skyline behind waves
    final skylinePaint = Paint()
      ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final skyline = Path();
    skyline.moveTo(w * 0.35, h * 0.6);
    skyline.lineTo(w * 0.40, h * 0.6);
    skyline.lineTo(w * 0.40, h * 0.35);
    skyline.lineTo(w * 0.45, h * 0.35);
    skyline.lineTo(w * 0.45, h * 0.45);
    skyline.lineTo(w * 0.55, h * 0.45);
    skyline.lineTo(w * 0.55, h * 0.30);
    skyline.lineTo(w * 0.60, h * 0.30);
    skyline.lineTo(w * 0.60, h * 0.50);
    skyline.lineTo(w * 0.65, h * 0.50);
    skyline.lineTo(w * 0.65, h * 0.65);
    skyline.close();
    canvas.drawPath(skyline, skylinePaint);

    // 2. Back Wave
    final backWavePaint = Paint()
      ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final backWave = Path();
    backWave.moveTo(0, h * 0.6);
    backWave.quadraticBezierTo(w * 0.25, h * 0.3, w * 0.5, h * 0.5);
    backWave.quadraticBezierTo(w * 0.75, h * 0.7, w, h * 0.4);
    backWave.lineTo(w, h);
    backWave.lineTo(0, h);
    backWave.close();
    canvas.drawPath(backWave, backWavePaint);

    // 3. Front Wave
    final frontWavePaint = Paint()
      ..color = const Color(0xFF93C5FD).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final frontWave = Path();
    frontWave.moveTo(0, h * 0.7);
    frontWave.quadraticBezierTo(w * 0.3, h * 0.45, w * 0.5, h * 0.45);
    frontWave.quadraticBezierTo(w * 0.7, h * 0.45, w, h * 0.6);
    frontWave.lineTo(w, h);
    frontWave.lineTo(0, h);
    frontWave.close();
    canvas.drawPath(frontWave, frontWavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

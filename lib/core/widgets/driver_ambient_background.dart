import 'package:flutter/material.dart';
import '../style/app_colors.dart';

class DriverAmbientBackground extends StatelessWidget {
  final Widget child;

  const DriverAmbientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Canvas
        Container(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        ),

        // Glowing Ambient Light Orb 1 (Top-Right Electric Emerald/Gold)
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        const Color(0xFF10B981).withValues(alpha: 0.18),
                        const Color(0xFF10B981).withValues(alpha: 0.04),
                        Colors.transparent,
                      ]
                    : [
                        const Color(0xFF10B981).withValues(alpha: 0.15),
                        const Color(0xFF10B981).withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Glowing Ambient Light Orb 2 (Left-Center Neon Cyan / Blue)
        Positioned(
          top: 300,
          left: -120,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        AppColors.secondary.withValues(alpha: 0.12),
                        AppColors.accentBlue.withValues(alpha: 0.03),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.accentBlue.withValues(alpha: 0.08),
                        AppColors.secondary.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Subtle Navigation Grid Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _GridBackgroundPainter(isDark: isDark),
          ),
        ),

        // Content
        child,
      ],
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  final bool isDark;

  _GridBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0x0AFFFFFF) : const Color(0x0F000000)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

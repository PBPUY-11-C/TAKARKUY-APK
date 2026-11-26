import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../planner_colors.dart';

/// Cincin gizi kustom yang terisi dari nol saat pertama tampil, seperti cincin di halaman Planner web.
class NutritionRing extends StatelessWidget {
  const NutritionRing({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.ratio,
    required this.caption,
    required this.color,
    required this.track,
  });

  final String label;
  final String value;
  final String unit;

  /// Isi cincin, 0 sampai 1.
  final double ratio;
  final String caption;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label $value $unit, $caption',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 112,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => CustomPaint(
                painter: _RingPainter(progress: progress, color: color, track: track),
                child: child,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: PlannerColors.ink)),
                    Text(unit, style: const TextStyle(fontSize: 12, color: PlannerColors.muted)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: PlannerColors.ink)),
          Text(caption, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: PlannerColors.muted)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color, required this.track});

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: (size.shortestSide - stroke) / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color || old.track != track;
}

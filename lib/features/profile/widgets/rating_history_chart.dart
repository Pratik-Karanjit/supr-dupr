import 'package:flutter/material.dart';
import '../../auth/models/user_profile.dart';
import '../../../core/theme/app_theme.dart';

class RatingHistoryChart extends StatelessWidget {
  final List<RatingHistoryPoint> points;
  final bool isDoubles;

  const RatingHistoryChart({
    super.key,
    required this.points,
    required this.isDoubles,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.pureWhiteCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: const Text(
          'Log verified matches to generate your rating trend.',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
      );
    }

    return Container(
      height: 195,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.pureWhiteCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(15, 23, 42, 0.02),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${isDoubles ? "Doubles" : "Singles"} Dynamic Progression',
                    style: const TextStyle(
                      color: AppTheme.textSlate,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Text(
                    'Verified Elo adjustments over time',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  points.last.rating.toStringAsFixed(3),
                  style: const TextStyle(
                    color: AppTheme.royalBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _RatingGraphPainter(points: points),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${points.first.date.day}/${points.first.date.month}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
              ),
              const Text(
                'Historical Matches Trajectory',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
              ),
              Text(
                '${points.last.date.day}/${points.last.date.month}',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingGraphPainter extends CustomPainter {
  final List<RatingHistoryPoint> points;

  _RatingGraphPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final ratings = points.map((p) => p.rating).toList();
    double minRating = ratings.reduce((a, b) => a < b ? a : b) - 0.15;
    double maxRating = ratings.reduce((a, b) => a > b ? a : b) + 0.15;
    if (maxRating - minRating < 0.3) {
      maxRating += 0.2;
      minRating -= 0.1;
    }

    final double range = maxRating - minRating;

    // Subtle dashed reference grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderSubtle
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Coordinates of data points
    final List<Offset> offsets = [];
    final stepX = size.width / (points.length <= 1 ? 1 : (points.length - 1));

    for (int i = 0; i < points.length; i++) {
      final x = points.length == 1 ? size.width / 2 : i * stepX;
      final normalizedY = (points[i].rating - minRating) / range;
      final y = size.height - (normalizedY * size.height);
      offsets.add(Offset(x, y));
    }

    // Gradient fill under the curve: bright cyan (#00B0FF) to transparent
    final fillPath = Path();
    fillPath.moveTo(offsets.first.x, size.height);
    for (final pt in offsets) {
      fillPath.lineTo(pt.x, pt.y);
    }
    fillPath.lineTo(offsets.last.x, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.brightCyan.withOpacity(0.25),
          AppTheme.brightCyan.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Graph Line: Bright Cyan
    final linePaint = Paint()
      ..color = AppTheme.brightCyan
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(offsets.first.x, offsets.first.y);
    for (int i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].x, offsets[i].y);
    }
    canvas.drawPath(linePath, linePaint);

    // Inner White Dot with Royal Blue Border
    final dotPaint = Paint()..color = Colors.white;
    final dotBorderPaint = Paint()
      ..color = AppTheme.royalBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (final pt in offsets) {
      canvas.drawCircle(pt, 4.5, dotPaint);
      canvas.drawCircle(pt, 4.5, dotBorderPaint);
    }

    // Highlight final point
    final lastPt = offsets.last;
    canvas.drawCircle(
      lastPt,
      7.0,
      Paint()
        ..color = AppTheme.brightCyan.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _RatingGraphPainter oldDelegate) => true;
}

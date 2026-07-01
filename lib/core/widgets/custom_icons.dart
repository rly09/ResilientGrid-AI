import 'dart:math' as math;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Generic helper: wraps a CustomPainter into a sized Widget
// ---------------------------------------------------------------------------
class IconCanvas extends StatelessWidget {
  final CustomPainter painter;
  final double size;

  const IconCanvas({super.key, required this.painter, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: painter,
    );
  }
}

// ---------------------------------------------------------------------------
// SUN / Solar Farm icon
// ---------------------------------------------------------------------------
class SolarIconPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SolarIconPainter({required this.color, this.strokeWidth = 1.8});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.22;

    // Core circle
    canvas.drawCircle(Offset(cx, cy), r, fillPaint);
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // 8 rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final innerR = r + size.width * 0.08;
      final outerR = r + size.width * 0.20;
      canvas.drawLine(
        Offset(cx + innerR * math.cos(angle), cy + innerR * math.sin(angle)),
        Offset(cx + outerR * math.cos(angle), cy + outerR * math.sin(angle)),
        paint..strokeWidth = i % 2 == 0 ? strokeWidth : strokeWidth * 0.7,
      );
    }
  }

  @override
  bool shouldRepaint(SolarIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// WIND TURBINE icon
// ---------------------------------------------------------------------------
class WindIconPainter extends CustomPainter {
  final Color color;

  WindIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Mast (vertical line)
    canvas.drawLine(Offset(cx, cy), Offset(cx, size.height * 0.95), paint);

    // Hub
    canvas.drawCircle(Offset(cx, cy), size.width * 0.08, fill);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.08, paint);

    // 3 Blades (120° apart)
    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final bladeLen = size.width * 0.38;
      final endX = cx + bladeLen * math.cos(angle);
      final endY = cy + bladeLen * math.sin(angle);

      // Blade as a tapered path
      final path = Path();
      final perpAngle = angle + math.pi / 2;
      final w = size.width * 0.055;
      path.moveTo(cx + w * math.cos(perpAngle), cy + w * math.sin(perpAngle));
      path.lineTo(endX, endY);
      path.lineTo(cx - w * math.cos(perpAngle), cy - w * math.sin(perpAngle));
      path.close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WindIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// BATTERY icon (with fill level)
// ---------------------------------------------------------------------------
class BatteryIconPainter extends CustomPainter {
  final Color color;
  final double fillLevel; // 0.0–1.0
  final double strokeWidth;

  BatteryIconPainter({required this.color, this.fillLevel = 0.7, this.strokeWidth = 1.8});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width * 0.72;
    final h = size.height * 0.58;
    final left = (size.width - w) / 2;
    final top = (size.height - h) / 2 + size.height * 0.04;

    // Battery body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, w, h),
      const Radius.circular(3),
    );
    canvas.drawRRect(bodyRect, paint);

    // Battery tip
    final tipW = size.width * 0.1;
    final tipH = size.height * 0.22;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + w, top + (h - tipH) / 2, tipW, tipH),
        const Radius.circular(2),
      ),
      fillPaint,
    );

    // Fill bar
    final padding = 3.0;
    final fillW = (w - padding * 2) * fillLevel.clamp(0, 1);
    if (fillW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left + padding, top + padding, fillW, h - padding * 2),
          const Radius.circular(2),
        ),
        fillPaint..color = color.withValues(alpha: 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(BatteryIconPainter old) => old.color != color || old.fillLevel != fillLevel;
}

// ---------------------------------------------------------------------------
// HOSPITAL CROSS icon
// ---------------------------------------------------------------------------
class HospitalIconPainter extends CustomPainter {
  final Color color;

  HospitalIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Background circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.44,
      Paint()..color = color.withValues(alpha: 0.1)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.44,
      borderPaint,
    );

    // Cross shape
    final cx = size.width / 2;
    final cy = size.height / 2;
    final armW = size.width * 0.18;
    final armLen = size.width * 0.32;

    final crossPath = Path()
      ..addRect(Rect.fromCenter(center: Offset(cx, cy), width: armW, height: armLen * 2))
      ..addRect(Rect.fromCenter(center: Offset(cx, cy), width: armLen * 2, height: armW));
    canvas.drawPath(crossPath, fillPaint);
  }

  @override
  bool shouldRepaint(HospitalIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// LIGHTNING BOLT / Power Grid icon
// ---------------------------------------------------------------------------
class GridIconPainter extends CustomPainter {
  final Color color;

  GridIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Background circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.44,
      Paint()..color = color.withValues(alpha: 0.1)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.44,
      borderPaint,
    );

    // Lightning bolt
    final cx = size.width / 2;
    final cy = size.height / 2;
    final boltPath = Path()
      ..moveTo(cx + size.width * 0.08, cy - size.height * 0.30)
      ..lineTo(cx - size.width * 0.12, cy + size.height * 0.05)
      ..lineTo(cx + size.width * 0.04, cy + size.height * 0.05)
      ..lineTo(cx - size.width * 0.08, cy + size.height * 0.30)
      ..lineTo(cx + size.width * 0.15, cy - size.height * 0.02)
      ..lineTo(cx + size.width * 0.02, cy - size.height * 0.02)
      ..close();

    canvas.drawPath(boltPath, fillPaint);
  }

  @override
  bool shouldRepaint(GridIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// AI BRAIN / Circuit Core icon
// ---------------------------------------------------------------------------
class AiBrainIconPainter extends CustomPainter {
  final Color color;
  final double progress; // for animation

  AiBrainIconPainter({required this.color, this.progress = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer circuit ring
    canvas.drawCircle(Offset(cx, cy), size.width * 0.42, strokePaint..color = color.withValues(alpha: 0.25));

    // 6 circuit nodes arranged in hexagon
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + progress * math.pi * 2;
      final nodeX = cx + size.width * 0.32 * math.cos(angle);
      final nodeY = cy + size.height * 0.32 * math.sin(angle);

      // Draw connection line to center
      canvas.drawLine(
        Offset(cx, cy),
        Offset(nodeX, nodeY),
        Paint()
          ..color = color.withValues(alpha: 0.2)
          ..strokeWidth = 0.8,
      );
      // Node dot
      canvas.drawCircle(Offset(nodeX, nodeY), size.width * 0.06,
          fillPaint..color = color.withValues(alpha: 0.2));
      canvas.drawCircle(Offset(nodeX, nodeY), size.width * 0.06,
          strokePaint..color = color..strokeWidth = 1.2);
    }

    // Center core circle
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18, fillPaint..color = color.withValues(alpha: 0.2));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.18, strokePaint..color = color..strokeWidth = 1.8);

    // Center dot
    canvas.drawCircle(Offset(cx, cy), size.width * 0.07, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(AiBrainIconPainter old) => old.color != color || old.progress != progress;
}

// ---------------------------------------------------------------------------
// BUILDING / Admin Block icon
// ---------------------------------------------------------------------------
class BuildingIconPainter extends CustomPainter {
  final Color color;

  BuildingIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillLight = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;

    // Building base
    final buildingRect = Rect.fromLTWH(
      cx - size.width * 0.3,
      size.height * 0.25,
      size.width * 0.6,
      size.height * 0.65,
    );
    canvas.drawRect(buildingRect, fillLight);
    canvas.drawRect(buildingRect, stroke);

    // Roof triangle
    final roofPath = Path()
      ..moveTo(cx - size.width * 0.38, size.height * 0.28)
      ..lineTo(cx, size.height * 0.08)
      ..lineTo(cx + size.width * 0.38, size.height * 0.28)
      ..close();
    canvas.drawPath(roofPath, paint..color = color.withValues(alpha: 0.3));
    canvas.drawPath(roofPath, stroke);

    // Windows (2x2 grid)
    final winSize = size.width * 0.12;
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 2; col++) {
        canvas.drawRect(
          Rect.fromLTWH(
            cx - size.width * 0.22 + col * (winSize + size.width * 0.1),
            size.height * 0.35 + row * (winSize + size.height * 0.1),
            winSize,
            winSize,
          ),
          paint..color = color.withValues(alpha: 0.5),
        );
      }
    }
  }

  @override
  bool shouldRepaint(BuildingIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// DASHBOARD GRID (sidebar nav icon)
// ---------------------------------------------------------------------------
class DashboardIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  DashboardIconPainter({required this.color, this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = isActive ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final gap = size.width * 0.08;
    final tileSize = (size.width - gap) / 2 - gap * 0.5;
    final r = 3.0;

    // 4 tiles grid
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 2; col++) {
        final rect = Rect.fromLTWH(
          gap + col * (tileSize + gap),
          gap + row * (tileSize + gap),
          tileSize,
          tileSize,
        );
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(DashboardIconPainter old) => old.color != color || old.isActive != isActive;
}

// ---------------------------------------------------------------------------
// MAP PIN (sidebar nav icon)
// ---------------------------------------------------------------------------
class MapIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  MapIconPainter({required this.color, this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = isActive ? color : color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final headR = size.width * 0.28;
    final headCy = size.height * 0.35;

    // Pin head
    canvas.drawCircle(Offset(cx, headCy), headR, fillPaint);
    canvas.drawCircle(Offset(cx, headCy), headR, paint);

    // Pin tail
    final pinPath = Path()
      ..moveTo(cx - headR * 0.7, headCy + headR * 0.6)
      ..lineTo(cx, size.height * 0.88)
      ..lineTo(cx + headR * 0.7, headCy + headR * 0.6);
    canvas.drawPath(pinPath, paint);

    // Inner dot
    canvas.drawCircle(Offset(cx, headCy), headR * 0.4,
        Paint()..color = isActive ? Colors.white.withValues(alpha: 0.7) : color.withValues(alpha: 0.5)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(MapIconPainter old) => old.color != color || old.isActive != isActive;
}

// ---------------------------------------------------------------------------
// ANALYTICS / Chart bars (sidebar nav icon)
// ---------------------------------------------------------------------------
class AnalyticsIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  AnalyticsIconPainter({required this.color, this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final barW = size.width * 0.16;
    final gap = size.width * 0.08;
    final totalW = barW * 4 + gap * 3;
    final startX = (size.width - totalW) / 2;
    final baseY = size.height * 0.85;

    final heights = [0.45, 0.70, 0.55, 0.85];
    for (int i = 0; i < 4; i++) {
      final barH = size.height * heights[i];
      final rect = Rect.fromLTWH(
        startX + i * (barW + gap),
        baseY - barH,
        barW,
        barH,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        isActive ? paint : paint..color = color.withValues(alpha: 0.5 + i * 0.12),
      );
    }

    // Base line
    canvas.drawLine(Offset(startX - 2, baseY), Offset(startX + totalW + 2, baseY), strokePaint);
  }

  @override
  bool shouldRepaint(AnalyticsIconPainter old) => old.color != color || old.isActive != isActive;
}

// ---------------------------------------------------------------------------
// SETTINGS / Gear icon (sidebar nav icon)
// ---------------------------------------------------------------------------
class SettingsIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;

  SettingsIconPainter({required this.color, this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = isActive ? color.withValues(alpha: 0.2) : Colors.transparent
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.42;
    final innerR = size.width * 0.24;
    final teeth = 8;
    final toothDepth = size.width * 0.10;

    // Gear outline
    final path = Path();
    for (int i = 0; i < teeth; i++) {
      final angle1 = (i / teeth) * 2 * math.pi - math.pi / (teeth * 2);
      final angle2 = angle1 + math.pi / (teeth);
      final angle3 = angle2 + math.pi / (teeth);

      final r1 = outerR + toothDepth;
      final r2 = outerR;

      if (i == 0) {
        path.moveTo(cx + r2 * math.cos(angle1), cy + r2 * math.sin(angle1));
      } else {
        path.lineTo(cx + r2 * math.cos(angle1), cy + r2 * math.sin(angle1));
      }
      path.lineTo(cx + r1 * math.cos(angle2), cy + r1 * math.sin(angle2));
      path.lineTo(cx + r2 * math.cos(angle3), cy + r2 * math.sin(angle3));
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Inner hole
    canvas.drawCircle(Offset(cx, cy), innerR, Paint()..color = isActive ? color.withValues(alpha: 0.15) : Colors.transparent..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), innerR, paint);
  }

  @override
  bool shouldRepaint(SettingsIconPainter old) => old.color != color || old.isActive != isActive;
}

// ---------------------------------------------------------------------------
// LEAF / App Logo icon
// ---------------------------------------------------------------------------
class LeafIconPainter extends CustomPainter {
  final Color color;
  final Color? strokeColor;

  LeafIconPainter({required this.color, this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor ?? color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Leaf shape using cubic bezier curves
    final path = Path();
    path.moveTo(cx, size.height * 0.1);
    path.cubicTo(
      size.width * 0.85, size.height * 0.1,
      size.width * 0.9, size.height * 0.6,
      cx, size.height * 0.92,
    );
    path.cubicTo(
      size.width * 0.1, size.height * 0.6,
      size.width * 0.15, size.height * 0.1,
      cx, size.height * 0.1,
    );

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Central vein
    canvas.drawLine(
      Offset(cx, size.height * 0.15),
      Offset(cx, size.height * 0.85),
      Paint()
        ..color = (strokeColor ?? color).withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Small lightning bolt overlay (microgrid energy)
    final boltPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final boltPath = Path()
      ..moveTo(cx + size.width * 0.07, cy - size.height * 0.20)
      ..lineTo(cx - size.width * 0.08, cy + size.height * 0.05)
      ..lineTo(cx + size.width * 0.02, cy + size.height * 0.05)
      ..lineTo(cx - size.width * 0.07, cy + size.height * 0.22)
      ..lineTo(cx + size.width * 0.1, cy - size.height * 0.02)
      ..lineTo(cx, cy - size.height * 0.02)
      ..close();

    canvas.drawPath(boltPath, boltPaint);
  }

  @override
  bool shouldRepaint(LeafIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// ENERGY WAVE icon (for frequency/status)
// ---------------------------------------------------------------------------
class WaveIconPainter extends CustomPainter {
  final Color color;

  WaveIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final w = size.width;
    final cy = size.height / 2;
    final amp = size.height * 0.32;

    path.moveTo(0, cy);
    path.cubicTo(w * 0.12, cy, w * 0.18, cy - amp, w * 0.3, cy - amp);
    path.cubicTo(w * 0.42, cy - amp, w * 0.48, cy, w * 0.5, cy);
    path.cubicTo(w * 0.52, cy, w * 0.58, cy + amp, w * 0.7, cy + amp);
    path.cubicTo(w * 0.82, cy + amp, w * 0.88, cy, w, cy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveIconPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Convenience Widget constructors
// ---------------------------------------------------------------------------
Widget solarIcon(Color color, {double size = 24}) =>
    IconCanvas(painter: SolarIconPainter(color: color), size: size);

Widget windIcon(Color color, {double size = 24}) =>
    IconCanvas(painter: WindIconPainter(color: color), size: size);

Widget batteryIcon(Color color, {double size = 24, double fillLevel = 0.7}) =>
    IconCanvas(painter: BatteryIconPainter(color: color, fillLevel: fillLevel), size: size);

Widget hospitalIcon(Color color, {double size = 24}) =>
    IconCanvas(painter: HospitalIconPainter(color: color), size: size);

Widget gridIcon(Color color, {double size = 24}) =>
    IconCanvas(painter: GridIconPainter(color: color), size: size);

Widget buildingIcon(Color color, {double size = 24}) =>
    IconCanvas(painter: BuildingIconPainter(color: color), size: size);

Widget aiBrainIcon(Color color, {double size = 24, double progress = 0}) =>
    IconCanvas(painter: AiBrainIconPainter(color: color, progress: progress), size: size);

Widget leafIcon(Color color, {double size = 24, Color? strokeColor}) =>
    IconCanvas(painter: LeafIconPainter(color: color, strokeColor: strokeColor), size: size);

Widget waveIcon(Color color, {double size = 24}) =>
    IconCanvas(painter: WaveIconPainter(color: color), size: size);

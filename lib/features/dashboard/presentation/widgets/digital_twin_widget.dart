import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/custom_icons.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/core/models/telemetry_model.dart';

class DigitalTwinWidget extends ConsumerStatefulWidget {
  const DigitalTwinWidget({super.key});

  @override
  ConsumerState<DigitalTwinWidget> createState() => _DigitalTwinWidgetState();
}

class _DigitalTwinWidgetState extends ConsumerState<DigitalTwinWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryAsync = ref.watch(telemetryProvider);
    final telemetry = telemetryAsync.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;

        final centerHub = Offset(w * 0.5, h * 0.5);
        final solarNode = Offset(w * 0.25, h * 0.18);
        final windNode = Offset(w * 0.75, h * 0.18);
        final gridNode = Offset(w * 0.15, h * 0.48);
        final batteryNode = Offset(w * 0.85, h * 0.48);
        final hospitalNode = Offset(w * 0.35, h * 0.82);
        final adminNode = Offset(w * 0.65, h * 0.82);

        return Stack(
          children: [
            // Subtle background grid pattern
            CustomPaint(
              size: Size(w, h),
              painter: _GridBackgroundPainter(),
            ),

            // Draw flowing lines
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(w, h),
                  painter: PowerFlowPainter(
                    progress: _animationController.value,
                    telemetry: telemetry,
                    centerHub: centerHub,
                    solarNode: solarNode,
                    windNode: windNode,
                    gridNode: gridNode,
                    batteryNode: batteryNode,
                    hospitalNode: hospitalNode,
                    adminNode: adminNode,
                  ),
                );
              },
            ),

            // Central AI Hub Core
            Positioned(
              left: centerHub.dx - 52,
              top: centerHub.dy - 52,
              child: _buildCentralBrainNode(),
            ),

            // Interactive Outer Nodes
            _positionedNode(
              solarNode, 'Solar Farm',
              SolarIconPainter(color: AppTheme.mossGreen),
              AppTheme.mossGreen,
              badge: telemetry != null ? '${telemetry.solarGenerationKw} kW' : 'Solar',
              onTap: () => _showControlSheet(context, 'Solar Farm', telemetry),
            ),
            _positionedNode(
              windNode, 'Wind Farm',
              WindIconPainter(color: AppTheme.mossGreen),
              AppTheme.mossGreen,
              badge: telemetry != null ? '${telemetry.windGenerationKw} kW' : 'Wind',
              onTap: () => _showControlSheet(context, 'Wind Farm', telemetry),
            ),
            _positionedNode(
              gridNode, 'External Grid',
              GridIconPainter(
                  color: telemetry?.gridStatus == 'Critical'
                      ? AppTheme.cafeNoir
                      : AppTheme.mossGreen),
              telemetry?.gridStatus == 'Critical' ? AppTheme.cafeNoir : AppTheme.mossGreen,
              badge: telemetry != null ? telemetry.gridStatus : 'Grid',
              onTap: () => _showControlSheet(context, 'External Grid', telemetry),
            ),
            _positionedNode(
              batteryNode, 'Battery Storage',
              BatteryIconPainter(
                  color: telemetry != null && telemetry.batteryPercent > 25
                      ? AppTheme.mossGreen
                      : AppTheme.cafeNoir,
                  fillLevel: telemetry != null ? telemetry.batteryPercent / 100.0 : 0.6),
              telemetry != null && telemetry.batteryPercent > 25
                  ? AppTheme.mossGreen
                  : AppTheme.cafeNoir,
              badge: telemetry != null ? '${telemetry.batteryPercent}%' : 'Battery',
              onTap: () => _showControlSheet(context, 'Battery Storage', telemetry),
            ),
            _positionedNode(
              hospitalNode, 'Hospital ICU',
              HospitalIconPainter(color: AppTheme.mossGreen),
              AppTheme.mossGreen,
              badge: 'Critical Tier 1',
              onTap: () => _showControlSheet(context, 'Hospital ICU', telemetry),
            ),
            _positionedNode(
              adminNode, 'Admin Block',
              BuildingIconPainter(
                  color: telemetry?.adminBlockOnline == true
                      ? AppTheme.mossGreen
                      : AppTheme.cafeNoir.withValues(alpha: 0.5)),
              telemetry?.adminBlockOnline == true
                  ? AppTheme.mossGreen
                  : AppTheme.cafeNoir.withValues(alpha: 0.5),
              badge: telemetry?.adminBlockOnline == true ? 'Online' : 'Shedded',
              onTap: () => _showControlSheet(context, 'Admin Block', telemetry),
            ),

            // Interactive hint overlay
            Positioned(
              top: 16,
              left: 16,
              child: _HintBadge(),
            ),
          ],
        );
      },
    );
  }

  Widget _positionedNode(
    Offset pos,
    String label,
    CustomPainter iconPainter,
    Color color, {
    required String badge,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: pos.dx - 40,
      top: pos.dy - 52,
      child: _NodeWidget(
        label: label,
        iconPainter: iconPainter,
        color: color,
        badge: badge,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCentralBrainNode() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.mossGreen
                          .withValues(alpha: 0.2 + 0.15 * _animationController.value),
                      blurRadius: 28 + 12 * _animationController.value,
                      spreadRadius: 4 * _animationController.value,
                    ),
                  ],
                ),
              ),
              // Spinning rings
              CustomPaint(
                size: const Size(104, 104),
                painter: BrainRingPainter(progress: _animationController.value),
              ),
              // Core circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.bone,
                  border: Border.all(color: AppTheme.kombuGreen, width: 2),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(38, 38),
                    painter: AiBrainIconPainter(
                      color: AppTheme.kombuGreen,
                      progress: _animationController.value * 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showControlSheet(BuildContext context, String nodeName, TelemetryModel? telemetry) {
    if (telemetry == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bone,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return NodeControlSheet(nodeName: nodeName, telemetry: telemetry, ref: ref);
      },
    );
  }
}

// ── Hint badge ────────────────────────────────────────────────────────────────
class _HintBadge extends StatefulWidget {
  @override
  State<_HintBadge> createState() => _HintBadgeState();
}

class _HintBadgeState extends State<_HintBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bone.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.mossGreen.withValues(alpha: 0.4 + 0.2 * _ctrl.value),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.mossGreen.withValues(alpha: 0.08 * _ctrl.value),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            CustomPaint(
              size: const Size(14, 14),
              painter: _TouchIconPainter(),
            ),
            const SizedBox(width: 7),
            Text(
              'Tap any node to adjust parameters live',
              style: TextStyle(
                color: AppTheme.kombuGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TouchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.kombuGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Simple finger / pointer
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.5, size.height * 0.9),
        Radius.circular(size.width * 0.2),
      ),
      p,
    );
    // tap ripple
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(size.width * 0.42, size.height * 0.55),
          width: size.width * 0.8,
          height: size.height * 0.8),
      math.pi * 1.2, math.pi * 0.6, false,
      p..color = AppTheme.mossGreen..strokeWidth = 1.0,
    );
  }

  @override bool shouldRepaint(_) => false;
}

// ── Node widget ────────────────────────────────────────────────────────────────
class _NodeWidget extends StatefulWidget {
  final String label;
  final CustomPainter iconPainter;
  final Color color;
  final String badge;
  final VoidCallback onTap;

  const _NodeWidget({
    required this.label,
    required this.iconPainter,
    required this.color,
    required this.badge,
    required this.onTap,
  });

  @override
  State<_NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<_NodeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void dispose() { _hoverCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) { setState(() => _hovered = true); _hoverCtrl.forward(); },
      onExit: (_) { setState(() => _hovered = false); _hoverCtrl.reverse(); },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverCtrl,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hovered
                      ? widget.color.withValues(alpha: 0.12)
                      : AppTheme.bone,
                  border: Border.all(
                    color: widget.color,
                    width: _hovered ? 2.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                          alpha: _hovered ? 0.3 : 0.12 + 0.08 * _hoverCtrl.value),
                      blurRadius: _hovered ? 20 : 10,
                      spreadRadius: _hovered ? 3 : 1,
                    ),
                  ],
                ),
                child: CustomPaint(
                  size: const Size(28, 28),
                  painter: widget.iconPainter,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppTheme.cafeNoir,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: widget.color.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Text(
                  widget.badge,
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Background grid painter ───────────────────────────────────────────────────
class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.tan.withValues(alpha: 0.10)
      ..strokeWidth = 0.8;

    const spacing = 40.0;
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ── PowerFlowPainter ──────────────────────────────────────────────────────────
class PowerFlowPainter extends CustomPainter {
  final double progress;
  final TelemetryModel? telemetry;
  final Offset centerHub;
  final Offset solarNode;
  final Offset windNode;
  final Offset gridNode;
  final Offset batteryNode;
  final Offset hospitalNode;
  final Offset adminNode;

  PowerFlowPainter({
    required this.progress,
    required this.telemetry,
    required this.centerHub,
    required this.solarNode,
    required this.windNode,
    required this.gridNode,
    required this.batteryNode,
    required this.hospitalNode,
    required this.adminNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.tan.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final criticalLinePaint = Paint()
      ..color = AppTheme.cafeNoir.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final isCritical = telemetry?.gridStatus == 'Critical';
    final adminOnline = telemetry?.adminBlockOnline ?? true;

    canvas.drawLine(solarNode, centerHub, linePaint);
    canvas.drawLine(windNode, centerHub, linePaint);
    if (isCritical) {
      _drawDashedLine(canvas, gridNode, centerHub, criticalLinePaint);
    } else {
      canvas.drawLine(gridNode, centerHub, linePaint);
    }
    canvas.drawLine(batteryNode, centerHub, linePaint);
    canvas.drawLine(centerHub, hospitalNode, linePaint);
    if (adminOnline) {
      canvas.drawLine(centerHub, adminNode, linePaint);
    } else {
      _drawDashedLine(canvas, centerHub, adminNode, criticalLinePaint);
    }

    if (telemetry == null) return;

    final solarFlowSpeed = (telemetry!.solarGenerationKw / 500.0).clamp(0.2, 2.0);
    final windFlowSpeed = (telemetry!.windGenerationKw / 300.0).clamp(0.2, 2.0);
    final loadFlowSpeed = (telemetry!.loadKw / 400.0).clamp(0.2, 2.0);

    _drawDotsOnPath(canvas, solarNode, centerHub, AppTheme.mossGreen, progress,
        speedFactor: solarFlowSpeed);
    _drawDotsOnPath(canvas, windNode, centerHub, AppTheme.mossGreen, progress,
        speedFactor: windFlowSpeed);

    if (!isCritical) {
      _drawDotsOnPath(canvas, gridNode, centerHub, AppTheme.mossGreen, progress);
    }

    if (isCritical) {
      _drawDotsOnPath(canvas, batteryNode, centerHub, AppTheme.cafeNoir, progress,
          speedFactor: 0.7);
    } else {
      _drawDotsOnPath(canvas, centerHub, batteryNode, AppTheme.mossGreen, progress,
          speedFactor: 0.5);
    }

    _drawDotsOnPath(canvas, centerHub, hospitalNode, AppTheme.kombuGreen, progress,
        speedFactor: loadFlowSpeed);

    if (adminOnline) {
      _drawDotsOnPath(canvas, centerHub, adminNode, AppTheme.kombuGreen, progress,
          speedFactor: loadFlowSpeed * 0.8);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final totalDist = (end - start).distance;
    const dashLen = 6.0;
    const gapLen = 4.0;
    final dir = (end - start) / totalDist;
    double traveled = 0;
    bool drawing = true;
    while (traveled < totalDist) {
      final segLen = drawing ? dashLen : gapLen;
      final nextTraveled = (traveled + segLen).clamp(0.0, totalDist);
      if (drawing) {
        canvas.drawLine(
          start + dir * traveled,
          start + dir * nextTraveled,
          paint,
        );
      }
      traveled = nextTraveled;
      drawing = !drawing;
    }
  }

  void _drawDotsOnPath(Canvas canvas, Offset start, Offset end, Color color,
      double progress, {double speedFactor = 1.0}) {
    const int dotCount = 4;
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;

    for (int i = 0; i < dotCount; i++) {
      double t = (progress * speedFactor + (i / dotCount)) % 1.0;
      final offset = Offset(start.dx + dx * t, start.dy + dy * t);
      // Larger glowing dot
      canvas.drawCircle(
        offset,
        4.5,
        Paint()
          ..color = color.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        offset,
        3.0,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PowerFlowPainter old) {
    return old.progress != progress || old.telemetry != telemetry;
  }
}

// ── BrainRingPainter ──────────────────────────────────────────────────────────
class BrainRingPainter extends CustomPainter {
  final double progress;

  BrainRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Outer dashed ring, slowly rotating
    final paint = Paint()
      ..color = AppTheme.mossGreen.withValues(alpha: 0.22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(progress * 2 * math.pi * 0.25);
    canvas.translate(-cx, -cy);

    const int dashCount = 12;
    for (int i = 0; i < dashCount; i++) {
      final angle = (i / dashCount) * 2 * math.pi;
      final startAngle = angle - 0.15;
      final sweepAngle = 0.28;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.92, height: size.height * 0.92),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
    canvas.restore();

    // Inner static ring
    canvas.drawCircle(
      Offset(cx, cy),
      size.width * 0.34,
      Paint()
        ..color = AppTheme.kombuGreen.withValues(alpha: 0.12)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant BrainRingPainter old) => old.progress != progress;
}

// ── Node Control Sheet ─────────────────────────────────────────────────────────
class NodeControlSheet extends StatefulWidget {
  final String nodeName;
  final TelemetryModel telemetry;
  final WidgetRef ref;

  const NodeControlSheet({
    super.key,
    required this.nodeName,
    required this.telemetry,
    required this.ref,
  });

  @override
  State<NodeControlSheet> createState() => _NodeControlSheetState();
}

class _NodeControlSheetState extends State<NodeControlSheet> {
  late double _overrideValue;
  late bool _isOverrideActive;

  @override
  void initState() {
    super.initState();
    if (widget.nodeName == 'Solar Farm') {
      _isOverrideActive = widget.telemetry.solarOverride != null;
      _overrideValue =
          (widget.telemetry.solarOverride ?? widget.telemetry.solarGenerationKw).toDouble();
    } else if (widget.nodeName == 'Wind Farm') {
      _isOverrideActive = widget.telemetry.windOverride != null;
      _overrideValue =
          (widget.telemetry.windOverride ?? widget.telemetry.windGenerationKw).toDouble();
    } else if (widget.nodeName == 'Hospital ICU') {
      _isOverrideActive = widget.telemetry.loadOverride != null;
      _overrideValue =
          (widget.telemetry.loadOverride ?? widget.telemetry.loadKw).toDouble();
    } else {
      _isOverrideActive = false;
      _overrideValue = 0.0;
    }
  }

  Future<void> _sendSocketMessage(Map<String, dynamic> msg) async {
    try {
      if (msg.containsKey('scenario')) {
        await runGridScenario(msg['scenario'] as String);
      } else {
        final params = <String, dynamic>{};
        final type = msg['type'];
        
        if (type == 'override') {
          if (msg.containsKey('solar')) params['solar'] = msg['solar'];
          if (msg.containsKey('wind')) params['wind'] = msg['wind'];
          if (msg.containsKey('load')) params['load'] = msg['load'];
        } else if (type == 'set_battery') {
          if (msg.containsKey('battery')) params['battery'] = (msg['battery'] as num?)?.round();
        } else if (type == 'toggle_admin') {
          if (msg.containsKey('online')) params['online'] = msg['online'];
        } else if (msg.containsKey('clear')) {
          params['clear'] = msg['clear'];
        }

        await updateGridOverrides(params);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update control: $e')),
        );
      }
    }
  }

  CustomPainter _getNodeIcon() {
    final color = AppTheme.kombuGreen;
    switch (widget.nodeName) {
      case 'Solar Farm': return SolarIconPainter(color: color);
      case 'Wind Farm': return WindIconPainter(color: color);
      case 'External Grid': return GridIconPainter(color: color);
      case 'Battery Storage': return BatteryIconPainter(color: color, fillLevel: widget.telemetry.batteryPercent / 100.0);
      case 'Hospital ICU': return HospitalIconPainter(color: color);
      case 'Admin Block': return BuildingIconPainter(color: color);
      default: return AiBrainIconPainter(color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasControls = ['Solar Farm', 'Wind Farm', 'External Grid', 'Battery Storage', 'Hospital ICU', 'Admin Block']
        .contains(widget.nodeName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                  color: AppTheme.tan, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.kombuGreen.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.4)),
                ),
                child: Center(
                  child: CustomPaint(size: const Size(24, 24), painter: _getNodeIcon()),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                widget.nodeName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLiveNodeDetails(),
          if (hasControls) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildControlContentLegacy(),
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () => _sendSocketMessage({'clear': true}),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset All Custom Overrides'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.cafeNoir.withValues(alpha: 0.6),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLiveNodeDetails() {
    final t = widget.telemetry;
    final values = <String, String>{
      'Solar Farm': '${t.solarGenerationKw} kW',
      'Wind Farm': '${t.windGenerationKw} kW',
      'External Grid': t.gridStatus,
      'Battery Storage': '${t.batteryPercent}%',
      'Hospital ICU': '${t.loadKw} kW total measured load',
      'Admin Block': t.adminBlockOnline ? 'Connected' : 'Disconnected',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          values[widget.nodeName] ?? 'Live sensor node',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Read-only live measurement from ${t.source}. Operational values cannot be simulated or overridden from the dashboard.',
          style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: .7), height: 1.5),
        ),
        if (t.timestamp != null) ...[
          const SizedBox(height: 12),
          Text('Last received: ${t.timestamp!.toLocal()}',
              style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: .55), fontSize: 12)),
        ],
      ],
    );
  }

  // ignore: unused_element
  Widget _buildControlContentLegacy() {
    final t = widget.telemetry;

    if (widget.nodeName == 'Solar Farm') {
      return _buildOverrideSection(
        desc: 'Adjust the solar generation output manually. If disabled, solar output is modeled live based on London cloud coverage (${t.weather["clouds"] ?? 20}% clouds).',
        max: 600.0,
        unit: 'kW',
        onSend: (val) => _sendSocketMessage({"type": "override", "solar": val}),
        onClear: () => _sendSocketMessage({"type": "override", "solar": null}),
      );
    }

    if (widget.nodeName == 'Wind Farm') {
      return _buildOverrideSection(
        desc: 'Adjust wind generation output manually. If disabled, wind turbines rotate dynamically based on weather conditions.',
        max: 500.0,
        unit: 'kW',
        onSend: (val) => _sendSocketMessage({"type": "override", "wind": val}),
        onClear: () => _sendSocketMessage({"type": "override", "wind": null}),
      );
    }

    if (widget.nodeName == 'External Grid') {
      final isOffline = t.gridStatus == 'Critical';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulate an emergency grid connection status. In grid failures, the microgrid isolates into islanding mode powered by battery and local wind/solar.',
            style: TextStyle(
                color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildSwitchRow(
            label: 'Grid Disconnect (Fault Simulation)',
            value: isOffline,
            activeColor: AppTheme.cafeNoir,
            onChanged: (val) {
              _sendSocketMessage({"scenario": val ? "Grid Failure" : "Normal"});
              Navigator.pop(context);
            },
          ),
        ],
      );
    }

    if (widget.nodeName == 'Battery Storage') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manually adjust the State of Charge (SoC) level of the battery storage system.',
            style: TextStyle(
                color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildSliderRow(
            value: t.batteryPercent.toDouble(),
            min: 0,
            max: 100,
            unit: '%',
            onChanged: (val) {
              _sendSocketMessage({"type": "set_battery", "battery": val});
            },
          ),
        ],
      );
    }

    if (widget.nodeName == 'Hospital ICU') {
      return _buildOverrideSection(
        desc: 'Hospital ICU represents a critical load. You can simulate load surge override here.',
        max: 450.0,
        min: 50.0,
        unit: 'kW',
        onSend: (val) => _sendSocketMessage({"type": "override", "load": val}),
        onClear: () => _sendSocketMessage({"type": "override", "load": null}),
      );
    }

    if (widget.nodeName == 'Admin Block') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Admin Block is a low priority load. It can be shed to conserve power during blackouts.',
            style: TextStyle(
                color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildSwitchRow(
            label: 'Admin Block Connected',
            value: t.adminBlockOnline,
            activeColor: AppTheme.mossGreen,
            onChanged: (val) {
              _sendSocketMessage({"type": "toggle_admin", "online": val});
            },
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildOverrideSection({
    required String desc,
    required double max,
    double min = 0.0,
    required String unit,
    required void Function(int) onSend,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          desc,
          style: TextStyle(
              color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        _buildSwitchRow(
          label: 'Enable Manual Override',
          value: _isOverrideActive,
          activeColor: AppTheme.mossGreen,
          onChanged: (val) {
            setState(() => _isOverrideActive = val);
            if (val) {
              onSend(_overrideValue.round());
            } else {
              onClear();
            }
          },
        ),
        if (_isOverrideActive) ...[
          const SizedBox(height: 16),
          _buildSliderRow(
            value: _overrideValue,
            min: min,
            max: max,
            unit: unit,
            onChanged: (val) {
              setState(() => _overrideValue = val);
              onSend(val.round());
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 14)),
        Switch(
          value: value,
          activeThumbColor: activeColor,
          activeTrackColor: activeColor.withValues(alpha: 0.2),
          inactiveThumbColor: AppTheme.tan,
          inactiveTrackColor: AppTheme.tan.withValues(alpha: 0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              activeColor: AppTheme.mossGreen,
              inactiveColor: AppTheme.tan.withValues(alpha: 0.3),
              onChanged: onChanged,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.mossGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            '${value.round()} $unit',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

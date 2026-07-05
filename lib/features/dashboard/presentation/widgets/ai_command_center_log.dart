import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/custom_icons.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';

class AiCommandCenterLog extends ConsumerStatefulWidget {
  const AiCommandCenterLog({super.key});

  @override
  ConsumerState<AiCommandCenterLog> createState() => _AiCommandCenterLogState();
}

class _AiCommandCenterLogState extends ConsumerState<AiCommandCenterLog>
    with SingleTickerProviderStateMixin {
  late AnimationController _brainCtrl;

  @override
  void initState() {
    super.initState();
    _brainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _brainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context, ) {
    final telemetryAsync = ref.watch(telemetryProvider);

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with animated brain icon
          Row(
            children: [
              AnimatedBuilder(
                animation: _brainCtrl,
                builder: (context, child) => Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.kombuGreen.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.mossGreen.withValues(
                            alpha: 0.2 + 0.15 * math.sin(_brainCtrl.value * math.pi * 2).abs()),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.mossGreen.withValues(
                            alpha: 0.12 * math.sin(_brainCtrl.value * math.pi * 2).abs()),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(20, 20),
                      painter: AiBrainIconPainter(
                        color: AppTheme.kombuGreen,
                        progress: _brainCtrl.value * 0.15,
                      ),
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
                      'AI Command Center',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Autonomous decision log',
                      style: TextStyle(
                        color: AppTheme.kombuGreen.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Thin separator
          Container(height: 1, color: AppTheme.tan.withValues(alpha: 0.4)),
          const SizedBox(height: 12),

          Expanded(
            child: telemetryAsync.when(
              data: (data) {
                if (data.gridStatus == 'Normal') {
                  return _buildLogList([
                    _LogEntry(
                      title: 'System Operating Normally',
                      desc: 'All loads powered. Battery maintaining float charge at optimal threshold.',
                      color: AppTheme.mossGreen,
                      icon: _StatusIconPainter(AppTheme.mossGreen, isOk: true),
                    ),
                  ]);
                } else if (data.gridStatus == 'Warning') {
                  return _buildLogList([
                    _LogEntry(
                      title: 'Grid Instability Detected',
                      desc: 'AI preparing to island the microgrid if voltage drops further.',
                      color: AppTheme.tan,
                      icon: _StatusIconPainter(AppTheme.tan, isOk: false),
                    ),
                  ]);
                } else {
                  return _buildLogList([
                    _LogEntry(
                      title: 'Grid Failure Detected',
                      desc: 'Islanding mode engaged. Severing external grid connection.',
                      color: AppTheme.cafeNoir,
                      icon: _StatusIconPainter(AppTheme.cafeNoir, isOk: false),
                    ),
                    _LogEntry(
                      title: 'Load Shedding Active',
                      desc: 'Admin block disconnected to preserve battery reserves.',
                      color: AppTheme.cafeNoir,
                      icon: _StatusIconPainter(AppTheme.cafeNoir, isOk: false),
                    ),
                    _LogEntry(
                      title: 'Hospital Critical Load',
                      desc: 'ICU remains powered securely via battery + local renewables.',
                      color: AppTheme.mossGreen,
                      icon: _StatusIconPainter(AppTheme.mossGreen, isOk: true),
                    ),
                    _LogEntry(
                      title: 'Predicted Backup Runtime',
                      desc: '6 days 11 hours remaining at current load consumption.',
                      color: AppTheme.kombuGreen,
                      icon: _StatusIconPainter(AppTheme.kombuGreen, isOk: true),
                    ),
                  ]);
                }
              },
              loading: () =>
                  Center(child: CircularProgressIndicator(color: AppTheme.mossGreen)),
              error: (e, s) =>
                  Text('Error loading AI logs', style: TextStyle(color: AppTheme.cafeNoir)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogList(List<_LogEntry> entries) {
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (context, index) =>
          Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 6), color: AppTheme.tan.withValues(alpha: 0.2)),
      itemBuilder: (context, i) {
        final entry = entries[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon column
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: CustomPaint(size: const Size(16, 16), painter: entry.icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      color: entry.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.desc,
                    style: TextStyle(
                      color: AppTheme.kombuGreen.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LogEntry {
  final String title;
  final String desc;
  final Color color;
  final CustomPainter icon;

  _LogEntry({
    required this.title,
    required this.desc,
    required this.color,
    required this.icon,
  });
}

class _StatusIconPainter extends CustomPainter {
  final Color color;
  final bool isOk;

  _StatusIconPainter(this.color, {required this.isOk});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.45;

    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);

    if (isOk) {
      // Checkmark
      final p = Paint()..color = color..strokeWidth = 1.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      final path = Path()
        ..moveTo(cx - r * 0.45, cy)
        ..lineTo(cx - r * 0.1, cy + r * 0.4)
        ..lineTo(cx + r * 0.5, cy - r * 0.35);
      canvas.drawPath(path, p);
    } else {
      // Exclamation
      canvas.drawLine(Offset(cx, cy - r * 0.45), Offset(cx, cy + r * 0.05),
          Paint()..color = color..strokeWidth = 1.8..strokeCap = StrokeCap.round);
      canvas.drawCircle(Offset(cx, cy + r * 0.38), 1.2,
          Paint()..color = color..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_StatusIconPainter old) => old.color != color || old.isOk != isOk;
}

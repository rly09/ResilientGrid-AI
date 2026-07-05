import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/core/models/telemetry_model.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/custom_icons.dart';

class LiveStatusPanel extends ConsumerStatefulWidget {
  const LiveStatusPanel({super.key});

  @override
  ConsumerState<LiveStatusPanel> createState() => _LiveStatusPanelState();
}

class _LiveStatusPanelState extends ConsumerState<LiveStatusPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    final telemetryAsync = ref.watch(telemetryProvider);

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Telemetry',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontSize: 16),
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final status =
                      telemetryAsync.value?.gridStatus ?? 'Connecting';
                  final color = _getStatusColor(status);
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: color.withValues(
                                  alpha: 0.2 + 0.15 * _pulseController.value)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(
                                    alpha: 0.7 * _pulseController.value),
                                blurRadius: 6 * _pulseController.value,
                                spreadRadius: 1.5 * _pulseController.value,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: color,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stat grid
          Expanded(
            child: telemetryAsync.when(
              data: (data) => _buildTelemetryGrid(data, context),
              loading: () => Center(
                  child:
                      CircularProgressIndicator(color: AppTheme.mossGreen)),
              error: (error, stack) => Center(
                child: Text(
                  'Connecting to API...',
                  style: TextStyle(
                      color: AppTheme.kombuGreen.withValues(alpha: 0.6),
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(TelemetryModel data, BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.15,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildStatCard('Grid Status', data.gridStatus,
            _getStatusColor(data.gridStatus),
            iconPainter: GridIconPainter(color: _getStatusColor(data.gridStatus))),
        _buildBatteryCard(data.batteryPercent),
        _buildStatCard('Solar', '${data.solarGenerationKw} kW',
            AppTheme.kombuGreen,
            iconPainter: SolarIconPainter(color: AppTheme.kombuGreen)),
        _buildStatCard('Wind', '${data.windGenerationKw} kW',
            AppTheme.kombuGreen,
            iconPainter: WindIconPainter(color: AppTheme.kombuGreen)),
        _buildStatCard('Load', '${data.loadKw} kW', AppTheme.cafeNoir,
            iconPainter: HospitalIconPainter(color: AppTheme.cafeNoir)),
        _buildStatCard('Frequency', '${data.frequencyHz} Hz',
            AppTheme.cafeNoir,
            iconPainter: WaveIconPainter(color: AppTheme.cafeNoir)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Normal': return AppTheme.mossGreen;
      case 'Warning': return AppTheme.tan;
      case 'Critical': return AppTheme.cafeNoir;
      default: return AppTheme.tan;
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color valueColor, {
    required CustomPainter iconPainter,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: valueColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: valueColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 3,
              color: valueColor.withValues(alpha: 0.65),
            ),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CustomPaint(size: const Size(12, 12), painter: iconPainter),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: AppTheme.kombuGreen.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryCard(int percent) {
    Color batteryColor = percent > 50
        ? AppTheme.mossGreen
        : (percent > 25 ? AppTheme.tan : AppTheme.cafeNoir);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: batteryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: batteryColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(
              width: 3,
              color: batteryColor.withValues(alpha: 0.65),
            ),
            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        CustomPaint(
                          size: const Size(12, 12),
                          painter: BatteryIconPainter(
                              color: batteryColor, fillLevel: percent / 100.0),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Battery',
                          style: TextStyle(
                            color: AppTheme.kombuGreen.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        color: batteryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 4,
                        child: Stack(
                          children: [
                            Container(color: AppTheme.tan.withValues(alpha: 0.2)),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percent / 100.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: batteryColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

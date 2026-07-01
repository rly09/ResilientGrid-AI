import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/core/models/telemetry_model.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(telemetryHistoryProvider);

    return historyAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
            child: Text(
              'Waiting for telemetry data streams...',
              style: TextStyle(color: AppTheme.kombuGreen, fontSize: 16),
            ),
          );
        }

        return _buildAnalyticsContent(logs, context);
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.kombuGreen)),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildAnalyticsContent(List<TelemetryModel> logs, BuildContext context) {
    // 1. Calculate Aggregate Metrics
    final int avgSolar = (logs.map((e) => e.solarGenerationKw).reduce((a, b) => a + b) / logs.length).round();
    final int avgWind = (logs.map((e) => e.windGenerationKw).reduce((a, b) => a + b) / logs.length).round();
    final int avgLoad = (logs.map((e) => e.loadKw).reduce((a, b) => a + b) / logs.length).round();
    final int peakGen = logs.map((e) => e.solarGenerationKw + e.windGenerationKw).reduce((a, b) => a > b ? a : b);
    
    // Self-sufficiency index (what % of load was covered by renewable gen over historical window)
    double selfSufficiency = 0.0;
    double totalGen = logs.map((e) => e.solarGenerationKw + e.windGenerationKw).reduce((a, b) => a + b).toDouble();
    double totalLoad = logs.map((e) => e.loadKw).reduce((a, b) => a + b).toDouble();
    if (totalLoad > 0) {
      selfSufficiency = (totalGen / totalLoad) * 100;
      if (selfSufficiency > 100) selfSufficiency = 100.0;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of Aggregate metrics
          Row(
            children: [
              Expanded(child: _buildMetricCard('Avg Renewables', '${avgSolar + avgWind} kW', 'Solar: $avgSolar | Wind: $avgWind kW', AppTheme.mossGreen)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Peak Generation', '$peakGen kW', 'Combined renewable peak', AppTheme.kombuGreen)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Avg Demand Load', '$avgLoad kW', 'Grid consumption average', AppTheme.cafeNoir)),
              const SizedBox(width: 16),
              Expanded(child: _buildMetricCard('Self-Sufficiency', '${selfSufficiency.toStringAsFixed(1)}%', 'Renewable cover ratio', AppTheme.mossGreen)),
            ],
          ),
          const SizedBox(height: 24),

          // Generation vs Demand Load Chart
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Generation vs Demand Profile (kW)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
                          Row(
                            children: [
                              _buildLegendDot('Generation', AppTheme.mossGreen),
                              const SizedBox(width: 16),
                              _buildLegendDot('Load Demand', AppTheme.cafeNoir),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 220,
                        child: LineChart(_buildPowerChartData(logs)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Battery SOC Chart
              Expanded(
                flex: 2,
                child: PremiumCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Battery State of Charge (%)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 220,
                        child: LineChart(_buildBatteryChartData(logs)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detailed Table of Recent Logs
          PremiumCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Historical Telemetry Stream logs', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
                const SizedBox(height: 16),
                _buildLogsTable(logs),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle, Color color) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.5), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.cafeNoir, fontWeight: FontWeight.w600)),
      ],
    );
  }

  LineChartData _buildPowerChartData(List<TelemetryModel> logs) {
    final genSpots = <FlSpot>[];
    final loadSpots = <FlSpot>[];

    for (int i = 0; i < logs.length; i++) {
      final log = logs[i];
      final gen = log.solarGenerationKw + log.windGenerationKw;
      genSpots.add(FlSpot(i.toDouble(), gen.toDouble()));
      loadSpots.add(FlSpot(i.toDouble(), log.loadKw.toDouble()));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppTheme.tan.withValues(alpha: 0.25),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 5,
            getTitlesWidget: (value, meta) {
              return Text(
                'T-${(logs.length - 1 - value.toInt()) * 2}s',
                style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.5), fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}kW',
                style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.5), fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: genSpots,
          isCurved: true,
          color: AppTheme.mossGreen,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.mossGreen.withValues(alpha: 0.1),
          ),
        ),
        LineChartBarData(
          spots: loadSpots,
          isCurved: true,
          color: AppTheme.cafeNoir,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.cafeNoir.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  LineChartData _buildBatteryChartData(List<TelemetryModel> logs) {
    final batterySpots = <FlSpot>[];

    for (int i = 0; i < logs.length; i++) {
      batterySpots.add(FlSpot(i.toDouble(), logs[i].batteryPercent.toDouble()));
    }

    return LineChartData(
      minY: 0,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppTheme.tan.withValues(alpha: 0.25),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 5,
            getTitlesWidget: (value, meta) {
              return Text(
                'T-${(logs.length - 1 - value.toInt()) * 2}s',
                style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.5), fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()}%',
                style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.5), fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: batterySpots,
          isCurved: true,
          color: AppTheme.kombuGreen,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppTheme.kombuGreen.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildLogsTable(List<TelemetryModel> logs) {
    // Show last 10 entries in reverse chronological order
    final recentLogs = logs.reversed.take(10).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 800),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppTheme.tan.withValues(alpha: 0.15)),
          horizontalMargin: 12,
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('Metric Time Offset', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Grid Status', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Battery SoC', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Solar Gen', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Wind Gen', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total Load', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Frequency', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
            DataColumn(label: Text('RMS Voltage', style: TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.bold))),
          ],
          rows: List<DataRow>.generate(recentLogs.length, (index) {
            final log = recentLogs[index];
            final int offsetSeconds = index * 2;
            final isCritical = log.gridStatus == 'Critical';
            
            return DataRow(
              cells: [
                DataCell(Text(offsetSeconds == 0 ? 'Live (Now)' : '- $offsetSeconds seconds ago', style: const TextStyle(fontWeight: FontWeight.w500))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isCritical ? AppTheme.cafeNoir : AppTheme.mossGreen).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.gridStatus,
                      style: TextStyle(
                        color: isCritical ? AppTheme.cafeNoir : AppTheme.mossGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('${log.batteryPercent}%')),
                DataCell(Text('${log.solarGenerationKw} kW')),
                DataCell(Text('${log.windGenerationKw} kW')),
                DataCell(Text('${log.loadKw} kW')),
                DataCell(Text('${log.frequencyHz} Hz')),
                DataCell(Text('${log.voltageV} V')),
              ],
            );
          }),
        ),
      ),
    );
  }

  // String helper for clean formatting in metric cards
  static String get windGenValue => 'Wind Gen';
}

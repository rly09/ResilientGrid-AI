import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/widgets/custom_icons.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/core/models/telemetry_model.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _autoIslanding = true;
  bool _peakShaving = true;
  double _minBatterySoC = 30.0;
  double _criticalFreq = 49.5;
  String _selectedThemeAccent = 'Earthy Sage';
  
  bool _isDraggingSoC = false;

  void _sendSocketMessage(Map<String, dynamic> msg) {
    final channel = ref.read(webSocketProvider);
    channel.sink.add(jsonEncode(msg));
  }

  @override
  Widget build(BuildContext context) {
    final telemetryAsync = ref.watch(telemetryProvider);
    final currentScenario = telemetryAsync.value?.scenario ?? 'Normal';

    // Synchronize state from backend if not actively dragging
    ref.listen<AsyncValue<TelemetryModel>>(telemetryProvider, (prev, next) {
      next.whenData((data) {
        if (!_isDraggingSoC) {
          setState(() {
            _minBatterySoC = data.minBatterySoc;
          });
        }
        setState(() {
          _autoIslanding = data.autoIslanding;
          _peakShaving = data.peakShaving;
        });
      });
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Core Grid Controls & Scenarios
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Scenario Card
                    PremiumCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Grid Scenario Simulation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20)),
                          const SizedBox(height: 8),
                          Text(
                            'Manually inject scenarios to test the autonomous AI controller response, islanding capabilities, and load shedding decisions.',
                            style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildScenarioOption(
                                  scenarioName: 'Normal',
                                  iconPainter: SolarIconPainter(color: AppTheme.mossGreen),
                                  color: AppTheme.mossGreen,
                                  isActive: currentScenario == 'Normal',
                                  desc: 'Nominal grid input, battery charging float',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildScenarioOption(
                                  scenarioName: 'Grid Failure',
                                  iconPainter: GridIconPainter(color: AppTheme.cafeNoir),
                                  color: AppTheme.cafeNoir,
                                  isActive: currentScenario == 'Grid Failure',
                                  desc: 'Loss of external power, islanding mode active',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildScenarioOption(
                                  scenarioName: 'Storm',
                                  iconPainter: _StormIconPainter(color: AppTheme.cafeNoir),
                                  color: AppTheme.cafeNoir,
                                  isActive: currentScenario == 'Storm',
                                  desc: 'Severe weather limits solar generation',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Smart Grid Settings
                    PremiumCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Autonomous Optimization Rules', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20)),
                          const SizedBox(height: 20),
                          _buildSwitchSetting(
                            title: 'Autonomous Islanding mode',
                            desc: 'Automatically isolate microgrid if main grid voltage drop is detected',
                            value: _autoIslanding,
                            onChanged: (val) {
                              setState(() => _autoIslanding = val);
                              _sendSocketMessage({
                                "type": "thresholds",
                                "auto_islanding": val
                              });
                            },
                          ),
                          const Divider(color: AppTheme.tan, height: 24, thickness: 0.5),
                          _buildSwitchSetting(
                            title: 'Active Peak Shaving policy',
                            desc: 'Deploy battery reserves during peak local demand periods to reduce costs',
                            value: _peakShaving,
                            onChanged: (val) {
                              setState(() => _peakShaving = val);
                              _sendSocketMessage({
                                "type": "thresholds",
                                "peak_shaving": val
                              });
                            },
                          ),
                          const Divider(color: AppTheme.tan, height: 24, thickness: 0.5),
                          _buildSwitchSetting(
                            title: 'Dynamic Load Shedding strategy',
                            desc: 'Prioritize tier 1 loads (e.g. ICU) by dropping low priority loads (e.g. Offices)',
                            value: true,
                            onChanged: (_) {},
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column: System Threshold Limits & Themes
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // System Bounds (Sliders)
                    PremiumCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Safety Threshold Bounds', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20)),
                          const SizedBox(height: 20),
                          
                          // Battery SoC threshold slider
                          const Text('Min Reserve Battery SoC', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 14)),
                          Text('Reserve level preserved for Tier 1 critical backup', style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.6), fontSize: 12)),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _minBatterySoC,
                                  min: 10.0,
                                  max: 80.0,
                                  divisions: 14,
                                  activeColor: AppTheme.mossGreen,
                                  inactiveColor: AppTheme.tan.withValues(alpha: 0.35),
                                  onChanged: (val) {
                                    setState(() {
                                      _minBatterySoC = val;
                                      _isDraggingSoC = true;
                                    });
                                  },
                                  onChangeEnd: (val) {
                                    setState(() => _isDraggingSoC = false);
                                    _sendSocketMessage({
                                      "type": "thresholds",
                                      "min_battery_soc": val
                                    });
                                  },
                                ),
                              ),
                              Text('${_minBatterySoC.round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir)),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Frequency warning slider
                          const Text('Low Frequency Warning (Hz)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 14)),
                          Text('Threshold triggering microgrid safety alarm', style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.6), fontSize: 12)),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _criticalFreq,
                                  min: 47.0,
                                  max: 49.8,
                                  divisions: 28,
                                  activeColor: AppTheme.kombuGreen,
                                  inactiveColor: AppTheme.tan.withValues(alpha: 0.35),
                                  onChanged: (val) => setState(() => _criticalFreq = val),
                                ),
                              ),
                              Text('${_criticalFreq.toStringAsFixed(1)} Hz', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Styling & Personalization
                    PremiumCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UI Themes & Accents', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20)),
                          const SizedBox(height: 8),
                          Text('Customize the theme color palette.', style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 13)),
                          const SizedBox(height: 16),
                          ...['Earthy Sage', 'Luxury Gold', 'Sunset Amber'].map((theme) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Radio<String>(
                                value: theme,
                                groupValue: _selectedThemeAccent,
                                activeColor: AppTheme.cafeNoir,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedThemeAccent = val);
                                  }
                                },
                              ),
                              title: Text(theme, style: const TextStyle(color: AppTheme.cafeNoir, fontWeight: FontWeight.w600, fontSize: 14)),
                              onTap: () => setState(() => _selectedThemeAccent = theme),
                            );
                          }),
                        ],
                      ),
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

  Widget _buildScenarioOption({
    required String scenarioName,
    required CustomPainter iconPainter,
    required Color color,
    required bool isActive,
    required String desc,
  }) {
    return GestureDetector(
      onTap: () {
        _sendSocketMessage({"scenario": scenarioName});
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.1) : AppTheme.bone,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : AppTheme.tan.withValues(alpha: 0.5),
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isActive ? 0.12 : 0.0),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomPaint(size: const Size(22, 22), painter: iconPainter),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                scenarioName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isActive ? color : AppTheme.cafeNoir,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.kombuGreen.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: 0.6), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.mossGreen,
            activeTrackColor: AppTheme.kombuGreen.withValues(alpha: 0.2),
            inactiveThumbColor: AppTheme.tan,
            inactiveTrackColor: AppTheme.bone,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

// Storm icon painter
class _StormIconPainter extends CustomPainter {
  final Color color;
  _StormIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final f = Paint()..color = color.withValues(alpha: 0.15)..style = PaintingStyle.fill;

    // Cloud shape
    final cloudPath = Path();
    final cx = size.width * 0.52;
    final cy = size.height * 0.38;
    cloudPath.addOval(Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.44, height: size.height * 0.32));
    cloudPath.addOval(Rect.fromCenter(center: Offset(cx - size.width * 0.18, cy + size.height * 0.06), width: size.width * 0.32, height: size.height * 0.28));
    cloudPath.addOval(Rect.fromCenter(center: Offset(cx + size.width * 0.14, cy + size.height * 0.08), width: size.width * 0.28, height: size.height * 0.24));
    canvas.drawPath(cloudPath, f);
    canvas.drawPath(cloudPath, p);

    // Lightning bolt from cloud
    final boltPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.58)
      ..lineTo(size.width * 0.40, size.height * 0.75)
      ..lineTo(size.width * 0.50, size.height * 0.75)
      ..lineTo(size.width * 0.38, size.height * 0.94);
    canvas.drawPath(boltPath, p);

    // Rain drops
    for (int i = 0; i < 3; i++) {
      final rx = size.width * (0.28 + i * 0.20);
      canvas.drawLine(
        Offset(rx, size.height * 0.62),
        Offset(rx - size.width * 0.04, size.height * 0.72),
        p..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_StormIconPainter old) => old.color != color;
}

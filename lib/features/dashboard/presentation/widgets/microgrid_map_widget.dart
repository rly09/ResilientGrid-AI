import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/models/telemetry_model.dart';
import 'package:frontend/core/widgets/custom_icons.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';

class MicrogridMapWidget extends ConsumerStatefulWidget {
  const MicrogridMapWidget({super.key});

  @override
  ConsumerState<MicrogridMapWidget> createState() => _MicrogridMapWidgetState();
}

class _MicrogridMapWidgetState extends ConsumerState<MicrogridMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedNode;

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

  void _sendSocketMessage(Map<String, dynamic> msg) {
    final channel = ref.read(webSocketProvider);
    channel.sink.add(jsonEncode(msg));
  }

  @override
  Widget build(BuildContext context) {
    final telemetryAsync = ref.watch(telemetryProvider);

    return telemetryAsync.when(
      data: (data) => _buildMapLayout(data),
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppTheme.kombuGreen)),
      error: (e, s) => Center(
          child: Text('Error loading map metrics: $e',
              style: const TextStyle(color: AppTheme.cafeNoir))),
    );
  }

  Widget _buildMapLayout(TelemetryModel data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        final hubOffset = Offset(width * 0.5, height * 0.4);
        final solarOffset = Offset(width * 0.2, height * 0.15);
        final windOffset = Offset(width * 0.8, height * 0.15);
        final gridOffset = Offset(width * 0.15, height * 0.5);
        final batteryOffset = Offset(width * 0.85, height * 0.5);
        final hospitalOffset = Offset(width * 0.35, height * 0.8);
        final adminOffset = Offset(width * 0.65, height * 0.8);

        return Column(
          children: [
            Expanded(
              child: PremiumCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Background with subtle grid dots
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.bone,
                              AppTheme.tan.withValues(alpha: 0.12),
                              AppTheme.bone,
                            ],
                          ),
                        ),
                      ),

                      // Dot-grid background pattern
                      CustomPaint(
                        size: Size(width, height),
                        painter: _DotGridPainter(),
                      ),

                      // Animated power flow lines
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(width, height),
                            painter: GridMapPainter(
                              progress: _animationController.value,
                              hub: hubOffset,
                              solar: solarOffset,
                              wind: windOffset,
                              grid: gridOffset,
                              battery: batteryOffset,
                              hospital: hospitalOffset,
                              admin: adminOffset,
                              telemetry: data,
                              selectedNode: _selectedNode,
                            ),
                          );
                        },
                      ),

                      // AI Core Hub (larger, center)
                      Positioned(
                        left: hubOffset.dx - 52,
                        top: hubOffset.dy - 52,
                        child: _buildHubNode(data),
                      ),

                      // Peripheral nodes
                      _buildNode(solarOffset, 'Solar Farm', 'Solar Gen',
                          SolarIconPainter(color: AppTheme.mossGreen), AppTheme.mossGreen,
                          '${data.solarGenerationKw} kW'),
                      _buildNode(windOffset, 'Wind Farm', 'Wind Gen',
                          WindIconPainter(color: AppTheme.mossGreen), AppTheme.mossGreen,
                          '${data.windGenerationKw} kW'),
                      _buildNode(gridOffset, 'Power Grid', 'External Grid',
                          GridIconPainter(color: data.gridStatus == 'Critical' ? AppTheme.cafeNoir : AppTheme.mossGreen),
                          data.gridStatus == 'Critical' ? AppTheme.cafeNoir : AppTheme.mossGreen,
                          data.gridStatus),
                      _buildNode(batteryOffset, 'Battery Bank', 'Storage',
                          BatteryIconPainter(
                              color: data.batteryPercent > 25 ? AppTheme.mossGreen : AppTheme.cafeNoir,
                              fillLevel: data.batteryPercent / 100.0),
                          data.batteryPercent > 25 ? AppTheme.mossGreen : AppTheme.cafeNoir,
                          '${data.batteryPercent}%'),
                      _buildNode(hospitalOffset, 'Hospital ICU', 'Hospital (ICU)',
                          HospitalIconPainter(color: AppTheme.mossGreen), AppTheme.mossGreen,
                          'Tier 1 Critical'),
                      _buildNode(adminOffset, 'Admin Block', 'Office Admin',
                          BuildingIconPainter(
                              color: data.adminBlockOnline ? AppTheme.mossGreen : AppTheme.cafeNoir.withValues(alpha: 0.5)),
                          data.adminBlockOnline ? AppTheme.mossGreen : AppTheme.cafeNoir.withValues(alpha: 0.5),
                          data.adminBlockOnline ? 'Online' : 'Shedded'),

                      // Info overlay
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.bone.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppTheme.tan.withValues(alpha: 0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.cafeNoir.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CustomPaint(
                                size: const Size(16, 16),
                                painter: _InfoIconPainter(),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Interactive Schematic — Click any node',
                                style: TextStyle(
                                  color: AppTheme.kombuGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
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
            ),
            const SizedBox(height: 16),
            _buildInspectorCard(data),
          ],
        );
      },
    );
  }

  Widget _buildHubNode(TelemetryModel data) {
    final isSelected = _selectedNode == 'AI Hub';
    return GestureDetector(
      onTap: () => setState(() => _selectedNode = _selectedNode == 'AI Hub' ? null : 'AI Hub'),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) => SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection glow
              if (isSelected)
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cafeNoir.withValues(alpha: 0.25),
                        blurRadius: 22,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
              // Rotating ring
              CustomPaint(
                size: const Size(104, 104),
                painter: _HubRingPainter(progress: _animationController.value, isSelected: isSelected),
              ),
              // Core
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.tan : AppTheme.bone,
                  border: Border.all(
                    color: isSelected ? AppTheme.cafeNoir : AppTheme.kombuGreen,
                    width: isSelected ? 2.5 : 2,
                  ),
                ),
                child: Center(
                  child: CustomPaint(
                    size: const Size(36, 36),
                    painter: AiBrainIconPainter(
                      color: isSelected ? AppTheme.cafeNoir : AppTheme.kombuGreen,
                      progress: _animationController.value * 0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNode(Offset pos, String id, String label, CustomPainter iconPainter, Color color, String badge) {
    final isActive = _selectedNode == id;
    return Positioned(
      left: pos.dx - 36,
      top: pos.dy - 36,
      child: GestureDetector(
        onTap: () => setState(() => _selectedNode = _selectedNode == id ? null : id),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.tan : AppTheme.bone,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppTheme.cafeNoir : color,
                    width: isActive ? 2.5 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? AppTheme.cafeNoir : color)
                          .withValues(alpha: isActive ? 0.30 : 0.12),
                      blurRadius: isActive ? 22 : 10,
                      spreadRadius: isActive ? 4 : 1,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomPaint(size: const Size(30, 30), painter: iconPainter),
                ),
              ),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.cafeNoir)),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
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

  Widget _buildInspectorCard(TelemetryModel data) {
    if (_selectedNode == null) {
      return PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.mossGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(22, 22),
                  painter: _InspectorPlaceholderPainter(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Node Inspector',
                      style: TextStyle(
                          color: AppTheme.cafeNoir,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    'Select any node in the schematic above to view real-time diagnostics, prioritizations, and load distributions.',
                    style: TextStyle(
                        color: AppTheme.kombuGreen.withValues(alpha: 0.65),
                        fontSize: 12,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final id = _selectedNode!;
    CustomPainter nodeIcon = AiBrainIconPainter(color: AppTheme.cafeNoir);
    Color nodeColor = AppTheme.cafeNoir;
    List<Widget> metrics = [];
    String desc = '';
    Widget? controls;

    switch (id) {
      case 'AI Hub':
        nodeIcon = AiBrainIconPainter(color: AppTheme.kombuGreen);
        nodeColor = AppTheme.kombuGreen;
        desc = 'Central autonomous dispatch brain. Balances generation sources against load demands.';
        metrics = [
          _buildMetricRow('Optimization', data.gridStatus == 'Critical' ? 'Islanding & Shedding' : 'Peak Shaving'),
          _buildMetricRow('Active Generation', '${data.solarGenerationKw + data.windGenerationKw} kW'),
          _buildMetricRow('System Load', '${data.loadKw} kW'),
          _buildMetricRow('Safety Mode', data.gridStatus != 'Normal' ? 'High Alert' : 'Nominal'),
        ];
        break;
      case 'Solar Farm':
        nodeIcon = SolarIconPainter(color: AppTheme.mossGreen);
        nodeColor = AppTheme.mossGreen;
        desc = 'Clean solar photovoltaic array. Susceptible to cloud coverage and sunlight angle.';
        metrics = [
          _buildMetricRow('Output', '${data.solarGenerationKw} kW'),
          _buildMetricRow('Cloud Cover', '${data.weather["clouds"] ?? 20}%'),
          _buildMetricRow('Temperature', '${data.weather["temp"] ?? 25}°C'),
        ];
        controls = _buildInspectorSlider(
          label: 'Solar Output Override (kW)',
          value: (data.solarOverride ?? data.solarGenerationKw).toDouble(),
          min: 0, max: 600,
          isOverride: data.solarOverride != null,
          onToggle: (val) => _sendSocketMessage({"type": "override", "solar": val ? (data.solarOverride ?? data.solarGenerationKw) : null}),
          onChanged: (val) => _sendSocketMessage({"type": "override", "solar": val.round()}),
        );
        break;
      case 'Wind Farm':
        nodeIcon = WindIconPainter(color: AppTheme.mossGreen);
        nodeColor = AppTheme.mossGreen;
        desc = 'High-altitude turbine systems generating green kinetic electricity.';
        metrics = [
          _buildMetricRow('Output', '${data.windGenerationKw} kW'),
          _buildMetricRow('Wind Condition', '${data.weather["description"] ?? "Clear"}'),
        ];
        controls = _buildInspectorSlider(
          label: 'Wind Output Override (kW)',
          value: (data.windOverride ?? data.windGenerationKw).toDouble(),
          min: 0, max: 500,
          isOverride: data.windOverride != null,
          onToggle: (val) => _sendSocketMessage({"type": "override", "wind": val ? (data.windOverride ?? data.windGenerationKw) : null}),
          onChanged: (val) => _sendSocketMessage({"type": "override", "wind": val.round()}),
        );
        break;
      case 'Power Grid':
        nodeIcon = GridIconPainter(color: data.gridStatus == 'Critical' ? AppTheme.cafeNoir : AppTheme.mossGreen);
        nodeColor = data.gridStatus == 'Critical' ? AppTheme.cafeNoir : AppTheme.mossGreen;
        desc = 'Municipal grid connection supplying or receiving supplemental power.';
        metrics = [
          _buildMetricRow('Connectivity', data.gridStatus),
          _buildMetricRow('Frequency', '${data.frequencyHz} Hz'),
          _buildMetricRow('RMS Voltage', '${data.voltageV} V'),
        ];
        controls = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Simulate Grid Failure (Blackout)',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 13)),
            Switch(
              value: data.gridStatus == 'Critical',
              activeColor: AppTheme.cafeNoir,
              onChanged: (val) => _sendSocketMessage({"scenario": val ? "Grid Failure" : "Normal"}),
            ),
          ],
        );
        break;
      case 'Battery Bank':
        nodeIcon = BatteryIconPainter(
            color: data.batteryPercent > 25 ? AppTheme.mossGreen : AppTheme.cafeNoir,
            fillLevel: data.batteryPercent / 100.0);
        nodeColor = data.batteryPercent > 25 ? AppTheme.mossGreen : AppTheme.cafeNoir;
        desc = 'Lithium storage units for emergency backup and peak demand shaving.';
        metrics = [
          _buildMetricRow('Current SoC', '${data.batteryPercent}%'),
          _buildMetricRow('Charge Mode', data.gridStatus == 'Critical' ? 'Discharging' : 'Float Charge'),
        ];
        controls = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manual Battery SoC Override',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: data.batteryPercent.toDouble(),
                    min: 0, max: 100, divisions: 20,
                    activeColor: AppTheme.mossGreen,
                    inactiveColor: AppTheme.tan.withValues(alpha: 0.3),
                    onChanged: (val) => _sendSocketMessage({"type": "set_battery", "battery": val}),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.mossGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
                  ),
                  child: Text('${data.batteryPercent}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 12)),
                ),
              ],
            ),
          ],
        );
        break;
      case 'Hospital ICU':
        nodeIcon = HospitalIconPainter(color: AppTheme.mossGreen);
        nodeColor = AppTheme.mossGreen;
        desc = 'Tier 1 Critical infrastructure. Guaranteed continuous supply by AI policy.';
        metrics = [
          _buildMetricRow('Priority Level', 'Tier 1 (Critical)'),
          _buildMetricRow('Load Draw', '${data.loadKw} kW'),
        ];
        controls = _buildInspectorSlider(
          label: 'Hospital ICU Load Surge Override (kW)',
          value: (data.loadOverride ?? data.loadKw).toDouble(),
          min: 50, max: 450,
          isOverride: data.loadOverride != null,
          onToggle: (val) => _sendSocketMessage({"type": "override", "load": val ? (data.loadOverride ?? data.loadKw) : null}),
          onChanged: (val) => _sendSocketMessage({"type": "override", "load": val.round()}),
        );
        break;
      case 'Admin Block':
        nodeIcon = BuildingIconPainter(color: data.adminBlockOnline ? AppTheme.mossGreen : AppTheme.cafeNoir);
        nodeColor = data.adminBlockOnline ? AppTheme.mossGreen : AppTheme.cafeNoir;
        desc = 'Administrative offices. Sheddable load disconnected during emergency grid failures.';
        metrics = [
          _buildMetricRow('Shedding Tier', 'Tier 3 (Low Priority)'),
          _buildMetricRow('Current Status', data.adminBlockOnline ? 'Online' : 'Shedded'),
        ];
        controls = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Admin Block Connected State',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 13)),
            Switch(
              value: data.adminBlockOnline,
              activeColor: AppTheme.mossGreen,
              onChanged: (val) => _sendSocketMessage({"type": "toggle_admin", "online": val}),
            ),
          ],
        );
        break;
    }

    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Node icon with color accent
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: nodeColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: nodeColor.withValues(alpha: 0.35)),
            ),
            child: Center(
              child: CustomPaint(size: const Size(24, 24), painter: nodeIcon),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(id,
                        style: TextStyle(
                            color: nodeColor, fontSize: 17, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _selectedNode = null),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppTheme.tan.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: CustomPaint(size: const Size(12, 12), painter: _CloseIconPainter()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        color: AppTheme.kombuGreen.withValues(alpha: 0.7), fontSize: 12, height: 1.4)),
                const SizedBox(height: 12),
                Wrap(spacing: 20, runSpacing: 8, children: metrics),
                if (controls != null) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppTheme.tan.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  controls,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required bool isOverride,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 13)),
            ),
            Row(
              children: [
                Text(isOverride ? 'Override On' : 'Auto',
                    style: TextStyle(
                        fontSize: 11,
                        color: isOverride ? AppTheme.mossGreen : AppTheme.kombuGreen.withValues(alpha: 0.55))),
                const SizedBox(width: 6),
                Switch(
                  value: isOverride,
                  activeColor: AppTheme.mossGreen,
                  onChanged: onToggle,
                ),
              ],
            ),
          ],
        ),
        if (isOverride)
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.clamp(min, max),
                  min: min, max: max,
                  activeColor: AppTheme.mossGreen,
                  inactiveColor: AppTheme.tan.withValues(alpha: 0.3),
                  onChanged: onChanged,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.mossGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.mossGreen.withValues(alpha: 0.3)),
                ),
                child: Text('${value.round()} kW',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppTheme.cafeNoir, fontSize: 12)),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.kombuGreen.withValues(alpha: 0.55), fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.cafeNoir, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.tan.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    const spacing = 32.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, p);
      }
    }
  }

  @override bool shouldRepaint(_) => false;
}

class _HubRingPainter extends CustomPainter {
  final double progress;
  final bool isSelected;

  _HubRingPainter({required this.progress, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(progress * 2 * math.pi * 0.3);
    canvas.translate(-cx, -cy);

    const dashCount = 10;
    for (int i = 0; i < dashCount; i++) {
      final angle = (i / dashCount) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: size.width * 0.92, height: size.height * 0.92),
        angle, 0.25, false,
        Paint()
          ..color = (isSelected ? AppTheme.cafeNoir : AppTheme.mossGreen)
              .withValues(alpha: 0.3)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
    }
    canvas.restore();
  }

  @override bool shouldRepaint(_HubRingPainter old) => old.progress != progress || old.isSelected != isSelected;
}

class _InfoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppTheme.kombuGreen..style = PaintingStyle.stroke..strokeWidth = 1.5;
    final f = Paint()..color = AppTheme.kombuGreen.withValues(alpha: 0.1)..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, f);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, p);
    // i dot and line
    canvas.drawCircle(Offset(cx, cy - size.height * 0.22), 1.5, Paint()..color = AppTheme.kombuGreen..style = PaintingStyle.fill);
    canvas.drawLine(Offset(cx, cy - size.height * 0.05), Offset(cx, cy + size.height * 0.28),
        Paint()..color = AppTheme.kombuGreen..strokeWidth = 1.8..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(_) => false;
}

class _InspectorPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppTheme.mossGreen..strokeWidth = 1.8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    // magnifying glass
    canvas.drawCircle(Offset(cx - 2, cy - 2), size.width * 0.32, p);
    canvas.drawLine(Offset(cx + size.width * 0.18, cy + size.height * 0.18),
        Offset(cx + size.width * 0.42, cy + size.height * 0.42), p);
  }
  @override bool shouldRepaint(_) => false;
}

class _CloseIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = AppTheme.kombuGreen..strokeWidth = 1.8..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), p);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), p);
  }
  @override bool shouldRepaint(_) => false;
}

// ── GridMapPainter ─────────────────────────────────────────────────────────────
class GridMapPainter extends CustomPainter {
  final double progress;
  final Offset hub, solar, wind, grid, battery, hospital, admin;
  final TelemetryModel telemetry;
  final String? selectedNode;

  GridMapPainter({
    required this.progress,
    required this.hub,
    required this.solar,
    required this.wind,
    required this.grid,
    required this.battery,
    required this.hospital,
    required this.admin,
    required this.telemetry,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isCritical = telemetry.gridStatus == 'Critical';
    final adminOnline = telemetry.adminBlockOnline;

    final linePaint = Paint()
      ..color = AppTheme.tan.withValues(alpha: 0.28)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final criticalPaint = Paint()
      ..color = AppTheme.cafeNoir.withValues(alpha: 0.22)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw static paths
    canvas.drawLine(solar, hub, linePaint);
    canvas.drawLine(wind, hub, linePaint);
    canvas.drawLine(grid, hub, isCritical ? criticalPaint : linePaint);
    canvas.drawLine(battery, hub, linePaint);
    canvas.drawLine(hub, hospital, linePaint);
    canvas.drawLine(hub, admin, adminOnline ? linePaint : criticalPaint);

    final solarFlowSpeed = (telemetry.solarGenerationKw / 500.0).clamp(0.2, 2.0);
    final windFlowSpeed = (telemetry.windGenerationKw / 300.0).clamp(0.2, 2.0);
    final loadFlowSpeed = (telemetry.loadKw / 400.0).clamp(0.2, 2.0);

    _drawFlowingDots(canvas, solar, hub, AppTheme.mossGreen, false, speedFactor: solarFlowSpeed);
    _drawFlowingDots(canvas, wind, hub, AppTheme.mossGreen, false, speedFactor: windFlowSpeed);

    if (!isCritical) {
      _drawFlowingDots(canvas, grid, hub, AppTheme.mossGreen, false);
    }

    if (isCritical) {
      _drawFlowingDots(canvas, battery, hub, AppTheme.cafeNoir, false, speedFactor: 0.7);
    } else {
      _drawFlowingDots(canvas, hub, battery, AppTheme.mossGreen, true, speedFactor: 0.5);
    }

    _drawFlowingDots(canvas, hub, hospital, AppTheme.kombuGreen, true, speedFactor: loadFlowSpeed);
    if (adminOnline) {
      _drawFlowingDots(canvas, hub, admin, AppTheme.kombuGreen, true, speedFactor: loadFlowSpeed * 0.8);
    }
  }

  void _drawFlowingDots(Canvas canvas, Offset start, Offset end, Color color, bool forward, {double speedFactor = 1.0}) {
    const int dotCount = 4;
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;

    for (int i = 0; i < dotCount; i++) {
      double t = (progress * speedFactor + (i / dotCount)) % 1.0;
      if (!forward) t = 1.0 - t;
      final offset = Offset(start.dx + dx * t, start.dy + dy * t);
      // Glowing dot
      canvas.drawCircle(offset, 5.0,
          Paint()..color = color.withValues(alpha: 0.12)..style = PaintingStyle.fill);
      canvas.drawCircle(offset, 3.0,
          Paint()..color = color..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant GridMapPainter old) =>
      old.progress != progress || old.telemetry != telemetry || old.selectedNode != selectedNode;
}

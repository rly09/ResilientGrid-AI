import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';

class ScenarioDialog extends ConsumerWidget {
  const ScenarioDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: AppTheme.bone,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: Text('Scenario Simulator', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildScenarioButton(context, ref, 'Normal', Icons.wb_sunny, AppTheme.mossGreen),
            _buildScenarioButton(context, ref, 'Grid Failure', Icons.power_off, AppTheme.cafeNoir),
            _buildScenarioButton(context, ref, 'Storm', Icons.thunderstorm, AppTheme.cafeNoir),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close', style: TextStyle(color: AppTheme.kombuGreen)),
        ),
      ],
    );
  }

  Widget _buildScenarioButton(BuildContext context, WidgetRef ref, String scenario, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(scenario, style: TextStyle(color: AppTheme.kombuGreen, fontWeight: FontWeight.w600)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.tan),
        ),
        tileColor: AppTheme.tan.withValues(alpha: 0.3),
        onTap: () {
          final channel = ref.read(webSocketProvider);
          channel.sink.add(jsonEncode({"scenario": scenario}));
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

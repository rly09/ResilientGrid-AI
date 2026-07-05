import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/telemetry_model.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/dashboard/data/telemetry_provider.dart';
import 'package:frontend/features/shared/widgets/premium_card.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _autoIslanding = true;
  bool _peakShaving = true;
  bool _loadShedding = true;
  double _minBatterySoC = 30;
  double _criticalFreq = 49.5;
  bool _editing = false;
  String? _message;

  Future<void> _save(Map<String, dynamic> values) async {
    try {
      await updateGridSettings(values);
      if (mounted) setState(() => _message = 'Saved to live controller');
    } catch (error) {
      if (mounted) setState(() => _message = 'Could not save: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<TelemetryModel>>(telemetryProvider, (_, next) {
      next.whenData((data) {
        if (!mounted || _editing) return;
        setState(() {
          _minBatterySoC = data.minBatterySoc;
          _autoIslanding = data.autoIslanding;
          _peakShaving = data.peakShaving;
          _criticalFreq = data.criticalFrequencyHz;
          _loadShedding = data.dynamicLoadShedding;
        });
      });
    });

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PremiumCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live controller policies', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('These rules are sent to the backend controller. No measurements are generated or overridden here.',
                      style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: .7))),
                  const SizedBox(height: 24),
                  _switch('Automatic islanding', 'Isolate when live frequency crosses the safety limit', _autoIslanding, (value) {
                    setState(() => _autoIslanding = value);
                    _save({'auto_islanding': value});
                  }),
                  const Divider(height: 32),
                  _switch('Peak shaving', 'Use stored energy when measured demand peaks', _peakShaving, (value) {
                    setState(() => _peakShaving = value);
                    _save({'peak_shaving': value});
                  }),
                  const Divider(height: 32),
                  _switch('Dynamic load shedding', 'Preserve critical loads when supply is constrained', _loadShedding, (value) {
                    setState(() => _loadShedding = value);
                    _save({'dynamic_load_shedding': value});
                  }),
                  if (_message != null) ...[
                    const SizedBox(height: 20),
                    Text(_message!, style: TextStyle(color: AppTheme.kombuGreen)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                PremiumCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Safety thresholds', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      _slider('Minimum battery reserve', '${_minBatterySoC.round()}%', _minBatterySoC, 10, 80, (value) {
                        setState(() { _minBatterySoC = value; _editing = true; });
                      }, (value) {
                        setState(() => _editing = false);
                        _save({'min_battery_soc': value});
                      }),
                      const SizedBox(height: 24),
                      _slider('Low frequency alarm', '${_criticalFreq.toStringAsFixed(1)} Hz', _criticalFreq, 47, 49.8, (value) {
                        setState(() { _criticalFreq = value; _editing = true; });
                      }, (value) {
                        setState(() => _editing = false);
                        _save({'critical_frequency_hz': value});
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PremiumCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                          ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                          ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(Icons.settings_brightness_outlined)),
                        ],
                        selected: {ref.watch(themeModeProvider)},
                        onSelectionChanged: (value) => ref.read(themeModeProvider.notifier).setThemeMode(value.first),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switch(String title, String subtitle, bool value, ValueChanged<bool> changed) => Row(
    children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: AppTheme.kombuGreen.withValues(alpha: .65))),
      ])),
      Switch(value: value, onChanged: changed),
    ],
  );

  Widget _slider(String title, String valueLabel, double value, double min, double max,
      ValueChanged<double> changed, ValueChanged<double> ended) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))), Text(valueLabel)]),
      Slider(value: value.clamp(min, max), min: min, max: max, onChanged: changed, onChangeEnd: ended),
    ],
  );
}

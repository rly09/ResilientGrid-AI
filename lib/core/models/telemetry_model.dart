class TelemetryModel {
  final String gridStatus;
  final int batteryPercent;
  final int solarGenerationKw;
  final int windGenerationKw;
  final int loadKw;
  final double frequencyHz;
  final double voltageV;
  final String scenario;
  final Map<String, dynamic> weather;
  final bool adminBlockOnline;
  final double minBatterySoc;
  final bool autoIslanding;
  final bool peakShaving;
  final int? solarOverride;
  final int? windOverride;
  final int? loadOverride;

  TelemetryModel({
    required this.gridStatus,
    required this.batteryPercent,
    required this.solarGenerationKw,
    required this.windGenerationKw,
    required this.loadKw,
    required this.frequencyHz,
    required this.voltageV,
    required this.scenario,
    required this.weather,
    required this.adminBlockOnline,
    required this.minBatterySoc,
    required this.autoIslanding,
    required this.peakShaving,
    this.solarOverride,
    this.windOverride,
    this.loadOverride,
  });

  factory TelemetryModel.fromJson(Map<String, dynamic> json) {
    return TelemetryModel(
      gridStatus: json['grid_status'] as String,
      batteryPercent: json['battery_percent'] as int,
      solarGenerationKw: json['solar_generation_kw'] as int,
      windGenerationKw: json['wind_generation_kw'] as int,
      loadKw: json['load_kw'] as int,
      frequencyHz: (json['frequency_hz'] as num).toDouble(),
      voltageV: (json['voltage_v'] as num).toDouble(),
      scenario: (json['scenario'] as String?) ?? 'Normal',
      weather: (json['weather'] as Map<String, dynamic>?) ?? const {
        'temp': 25.0,
        'clouds': 20,
        'description': 'Clear',
      },
      adminBlockOnline: json['admin_block_online'] as bool? ?? true,
      minBatterySoc: (json['min_battery_soc'] as num? ?? 30.0).toDouble(),
      autoIslanding: json['auto_islanding'] as bool? ?? true,
      peakShaving: json['peak_shaving'] as bool? ?? true,
      solarOverride: json['solar_override'] as int?,
      windOverride: json['wind_override'] as int?,
      loadOverride: json['load_override'] as int?,
    );
  }

  factory TelemetryModel.initial() {
    return TelemetryModel(
      gridStatus: 'Connecting...',
      batteryPercent: 0,
      solarGenerationKw: 0,
      windGenerationKw: 0,
      loadKw: 0,
      frequencyHz: 0.0,
      voltageV: 0.0,
      scenario: 'Normal',
      weather: const {
        'temp': 25.0,
        'clouds': 20,
        'description': 'Clear',
      },
      adminBlockOnline: true,
      minBatterySoc: 30.0,
      autoIslanding: true,
      peakShaving: true,
      solarOverride: null,
      windOverride: null,
      loadOverride: null,
    );
  }
}

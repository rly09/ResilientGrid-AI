import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:frontend/core/models/telemetry_model.dart';

// ── Backend URL constants ─────────────────────────────────────────────────────
const String backendUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://127.0.0.1:8000',
);
String get _wsUrl => '${backendUrl.replaceFirst(RegExp(r'^http'), 'ws')}/ws/telemetry';

// ── WebSocket provider (auto-reconnecting) ────────────────────────────────────
final webSocketProvider = Provider<WebSocketChannel>((ref) {
  final channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
  ref.onDispose(() => channel.sink.close());
  return channel;
});

// ── Telemetry stream with auto-reconnect ─────────────────────────────────────
final telemetryProvider = StreamProvider<TelemetryModel>((ref) {
  return _reconnectingTelemetryStream(ref);
});

Stream<TelemetryModel> _reconnectingTelemetryStream(Ref ref) async* {
  while (true) {
    try {
      final channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Wait for the connection to be ready
      await channel.ready.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('WebSocket connection timed out'),
      );

      await for (final message in channel.stream) {
        try {
          final Map<String, dynamic> data = jsonDecode(message as String);
          yield TelemetryModel.fromJson(data);
        } catch (parseError) {
          // Skip bad messages but keep connection alive
          continue;
        }
      }

      await channel.sink.close();
    } catch (e) {
      // Connection failed — wait 2 seconds and retry
      yield* Stream.error(e);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}

// ── Telemetry history provider ────────────────────────────────────────────────
final telemetryHistoryProvider =
    AsyncNotifierProvider<TelemetryHistoryNotifier, List<TelemetryModel>>(() {
  return TelemetryHistoryNotifier();
});

class TelemetryHistoryNotifier extends AsyncNotifier<List<TelemetryModel>> {
  @override
  Future<List<TelemetryModel>> build() async {
    List<TelemetryModel> initialLogs = [];
    try {
      final response = await http
          .get(Uri.parse('$backendUrl/api/telemetry/history'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        initialLogs =
            data.map((json) => TelemetryModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Silently fall through — history is optional
    }

    // Subscribe to new live telemetry and append to history
    ref.listen<AsyncValue<TelemetryModel>>(telemetryProvider, (prev, next) {
      next.whenData((newTelemetry) {
        final current = state.value ?? [];
        final updated = List<TelemetryModel>.from(current)..add(newTelemetry);
        if (updated.length > 50) updated.removeAt(0);
        state = AsyncValue.data(updated);
      });
    });

    return initialLogs;
  }
}

Future<void> updateGridSettings(Map<String, dynamic> values) async {
  final response = await http.patch(
    Uri.parse('$backendUrl/api/settings'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode(values),
  ).timeout(const Duration(seconds: 5));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError('Settings update failed (${response.statusCode})');
  }
}

Future<void> updateGridOverrides(Map<String, dynamic> values) async {
  final response = await http.patch(
    Uri.parse('$backendUrl/api/override'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode(values),
  ).timeout(const Duration(seconds: 5));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError('Override update failed (${response.statusCode})');
  }
}

Future<void> runGridScenario(String scenario) async {
  final response = await http.post(
    Uri.parse('$backendUrl/api/scenario'),
    headers: const {'Content-Type': 'application/json'},
    body: jsonEncode({'scenario': scenario}),
  ).timeout(const Duration(seconds: 5));
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw StateError('Scenario request failed (${response.statusCode})');
  }
}

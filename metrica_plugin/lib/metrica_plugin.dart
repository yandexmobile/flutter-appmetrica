import 'dart:async';
import 'package:flutter/services.dart';

class MetricaPlugin {
  static const MethodChannel _channel = const MethodChannel('metrica_plugin');

  static Future<void> activate(String apiKey) async {
    await _channel.invokeMethod("activate", {"apiKey": apiKey});
  }

  static Future<void> reportEvent(String name, {Map<String, String> attributes}) async {
    await _channel.invokeMethod("reportEvent", {"name": name, "attributes": attributes});
  }
}

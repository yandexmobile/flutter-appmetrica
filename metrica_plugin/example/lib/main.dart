import 'package:flutter/material.dart';
import 'package:metrica_plugin/metrica_plugin.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MetricaPlugin.activate("09126f9a-f624-4a80-a0f1-f04b8552c621");

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            child: Text("Отправить событие"),
            onPressed: () {
              MetricaPlugin.reportEvent("Клик по кнопке", attributes: {"date": DateTime.now().toIso8601String()});
            },
          ),
        ),
      ),
    );
  }
}

# metrica_app

```yaml
  metrica_plugin:
    git: 
      url: https://github.com/yandexmobile/flutter-appmetrica
      ref: main
      path: metrica_plugin
```

```dart
    /// init
    await MetricaPlugin.activate('00000000-0000-0000-0000-000000000000');
    /// track
    await MetricaPlugin.reportEvent(name, attributes: parameters);
```
[instructions.md](instructions.md)



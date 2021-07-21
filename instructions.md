# Подключение метрики к Flutter
Для работы метрики на Flutter используются нативные реализации плагина для каждой платформы
Интегрировать метрику в свое приложение на Flutter можно поискав подходящий плагин на `pub.dev` либо написав собственную интеграцию с нативными реализациями плагина. Далее инструкция для самостоятельной интеграции:
## 1. Создаем в своем проекте плагин под метрику для Flutter
[Иструкцию по создания плагина на Flutter](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#step-1-create-the-package)
В данной инструкции использовался `flutter` версии `2.0.5` и команда:
```
flutter create --org com.example --template=plugin --platforms=android,ios -a kotlin metrica_plugin
```
### 1.1 Добавляем в Dart plugin методы для инициализации и отправки событий
Эти методы будем вызывать из `dart` кода приложения.
```dart
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
```
Похожим образом можно будет пробросить обращение и к любым другим платформенным методам метрики

## 2. Добавляем интеграцию с Android
### 2.1 Подключаем метрику для Android
При интеграции с Android можно следовать [инструкции](https://appmetrica.yandex.ru/docs/mobile-sdk-dg/concepts/android-initialize.html)

- Добавляем зависимость в `build.gradle` файл плагина
`implementation 'com.yandex.android:mobmetricalib:3.21.0'`

### 2.2 Добавляем поддержку платформенных методов
```kotlin
class MetricaPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private var context : Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "metrica_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "activate") {
      val apiKey = call.argument<String>("apiKey")
       // Здесь можно пробросить дополнительные параметры для конфигурации
      val config = YandexMetricaConfig.newConfigBuilder(apiKey!!).build()

      YandexMetrica.activate(context!!, config)
      YandexMetrica.enableActivityAutoTracking(context as Application)

      result.success(null)
    } else if (call.method == "reportEvent") {
      val name = call.argument<String>("name")
      val attributes = call.argument<Map<String, Any>>("attributes")

      YandexMetrica.reportEvent(name!!, attributes)

      result.success(null)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
  }
}
```
## 3. Добавляем интеграцию с iOS
### 3.1 Подключаем метрику для iOS
При интеграции с iOS можно следовать [инструкции](https://appmetrica.yandex.ru/docs/mobile-sdk-dg/tasks/ios-quickstart.html)
Чтобы посмотреть как подключить `pod` к iOS плагину можно обратиться к [документации Flutter](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#ios)

- В `.podspec` файл плагина добавляем строчку: `s.dependency 'YandexMobileMetrica/Dynamic', '3.16.0'`
- Перед запуском приложения на `ios` обязательно сделать `pod install` в директории с `ios` кодом

### 3.2 Добавляем поддержку платформенных методов
```swift
import Flutter
import UIKit
import YandexMobileMetrica

public class SwiftMetricaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "metrica_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftMetricaPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    switch method {
    case "activate":
        let args = call.arguments as! [String: Any]
        let apiKey = args["apiKey"] as! String
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: apiKey)
        
        YMMYandexMetrica.activate(with: configuration!)
        
        result(nil)
    case "reportEvent":
        let args = call.arguments as! [String: Any]
        let attributes = args["attributes"] as? [String : Any]
        let name = args["name"] as! String
        
        if attributes != nil {
            YMMYandexMetrica.reportEvent(name, parameters: attributes, onFailure: { err in
                print("Failed to send event: \(err)")
            })
        } else {
            YMMYandexMetrica.reportEvent(name, onFailure: { err in
                print("Failed to send event: \(err)")
            })
        }
        
        result(nil)
    default:
        result(nil)
    }
  }
}
```
## 4. Использование плагина
### 4.1 Инициализируем плагин
- В `pubspec` своего приложения добавляем зависимость от плагина. Например, так:
```
  metrica_plugin:
    path: ./metrica_plugin
```
- В `main.dart` вашего приложения активируем метрику:
```dart
    import 'package:metrica_plugin/metrica_plugin.dart';
    ...
    ...
    WidgetsFlutterBinding.ensureInitialized();
    MetricaPlugin.activate("your-api-key");
```
### 1.3 Отправляем события
События можно будет отправлять из любого места вашего приложения с помощью вызова:
```dart
  import 'package:metrica_plugin/metrica_plugin.dart';
  ...
  MetricaPlugin.reportEvent("EventName", {"attribute_1": "value_1", "attribute_2": "value_2"});
```

## 4. Интегрируемся с другими платформами
На данном этапе метрика успешно проинтегрирована в ваше приложение и ее можно будет использовать с платформами Android & iOS.
Для интеграции с другими платформами (например, `web`) достаточно будет так же добавить соответствующие реализации методов для конкретной платформы.

## 5. Ссылки на файлы с примерами кода
[Тестовое приложение с интеграцией метрики](./metrica_plugin/example/lib/main.dart)

[Android plugin](./metrica_plugin/android/src/main/kotlin/com/example/metrica_plugin/MetricaPlugin.kt)

[Swift plugin](./metrica_plugin/ios/Classes/SwiftMetricaPlugin.swift)

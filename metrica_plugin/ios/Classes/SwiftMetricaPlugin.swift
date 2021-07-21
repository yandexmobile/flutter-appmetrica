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

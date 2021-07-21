package com.example.metrica_plugin

import android.app.Application
import android.content.Context
import androidx.annotation.NonNull
import com.yandex.metrica.YandexMetrica
import com.yandex.metrica.YandexMetricaConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


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

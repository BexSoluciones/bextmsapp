package com.example.bexdeliveries

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.util.Log

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import plugin_receivers.PowerStatusReceiver
import plugin_utils.HEADLEASS_DISPATCHER_HANDLE
import plugin_utils.PluginPreferences

/** ChargerStatusPlugin */
class ChargerStatusPlugin : MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var context: Context? = null

    fun onAttachedToEngine(flutterEngine: FlutterEngine) {
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.bexdeliveries:method_channel")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.bexdeliveries:event_channel")
        eventChannel.setStreamHandler(PluginEventEmitter)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBatteryLevel" -> {
                val intent: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
                    context?.registerReceiver(null, ifilter)
                }
                Log.d("Intent", intent.toString());
                val batteryLevel = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                val scale: Int = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
                batteryLevel * 100 / scale.toFloat()
                result.success("Android Battery Level $batteryLevel")
            }
            "getChargerStatus" -> {
                val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { ifilter ->
                    context?.registerReceiver(null, ifilter)
                }
                val chargingStatus = when (batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1) {
                    BatteryManager.BATTERY_STATUS_CHARGING -> {
                        "Charging"
                    }
                    BatteryManager.BATTERY_STATUS_FULL -> {
                        "Full"
                    }
                    else -> {
                        "Disconnected"
                    }
                }
                result.success("Charging state: $chargingStatus")
            }
            "registerHeadlessDispatcher" -> { //called from dart with headless dispatcher id
                val dispatcherHandler = call.argument<Number>("dispatcherHandler") as Long?
                Log.i("ChargerStatusPlugin", "registerHeadlessDispatcher: dispatcherHandler: $dispatcherHandler")
                dispatcherHandler?.let {  noneNullHandle ->
                    context?.let {
                        //Saving the handle in persistence storage for later and use when native side wakes up in background
                        PluginPreferences.saveLongValue(it, HEADLEASS_DISPATCHER_HANDLE, noneNullHandle)
                        result.success(null)
                    }
                }
            }
            "startPowerChangesListener" -> {
                context?.let {
                    PowerStatusReceiver.registerPowerChangesBroadcast(it)
                    result.success(null)
                } ?: result.error("", "", "")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

}
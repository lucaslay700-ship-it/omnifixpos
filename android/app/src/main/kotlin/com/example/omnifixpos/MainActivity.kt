package com.example.omnifixpos

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
package com.example.omnifixpos

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.omnifixpos.security/hardware"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getHardwareUUID" -> {
                    val hardwareUUID = getDeviceHardwareId()
                    result.success(hardwareUUID)
                }
                "getDeviceModel" -> {
                    val modelInfo = "${Build.MANUFACTURER} ${Build.MODEL}"
                    result.success(modelInfo)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getDeviceHardwareId(): String {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Build.getSerial()
            } else {
                Build.SERIAL
            }
        } catch (e: SecurityException) {
            "PERM_DENIED_UUID_${Build.MODEL}"
        } catch (e: Exception) {
            "UNKNOWN_DEVICE_UUID"
        }
    }
}
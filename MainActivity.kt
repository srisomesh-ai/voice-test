package com.bharatgps.voice_test

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bharatgps/assistant"
    private var channel: MethodChannel? = null
    private var launchCommand: String = ""

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "getLaunchCommand") {
                result.success(launchCommand)
            } else {
                result.notImplemented()
            }
        }
        // read the command from the intent that launched us
        launchCommand = extractCommand(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val cmd = extractCommand(intent)
        if (cmd.isNotEmpty()) {
            launchCommand = cmd
            channel?.invokeMethod("onCommand", cmd)
        }
    }

    // The shortcut deep links use a "command" query param, e.g. app://open?command=map
    private fun extractCommand(intent: Intent?): String {
        if (intent == null) return ""
        val data = intent.data
        if (data != null) {
            val c = data.getQueryParameter("command")
            if (c != null) return c
            // fall back to the path (e.g. /map)
            val path = data.path
            if (path != null && path.length > 1) return path.substring(1)
        }
        return ""
    }
}

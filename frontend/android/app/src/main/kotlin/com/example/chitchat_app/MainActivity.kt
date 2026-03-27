package com.example.chitchat_app

import android.media.AudioManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.chitchat.app/ringer"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getRingerMode") {
                val audioManager = 
                    getSystemService(Context.AUDIO_SERVICE) as AudioManager
                val mode = when (audioManager.ringerMode) {
                    AudioManager.RINGER_MODE_SILENT -> "silent"
                    AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
                    else -> "normal"
                }
                result.success(mode)
            } else {
                result.notImplemented()
            }
        }
    }
}

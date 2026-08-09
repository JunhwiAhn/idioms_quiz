package com.junhwiahn.spanishworddojo

import android.content.ActivityNotFoundException
import android.content.Intent
import android.media.AudioManager
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val CHANNEL = "com.junhwiahn.spanishworddojo/tts_setup"
private const val SCREEN_AWAKE_CHANNEL =
    "com.junhwiahn.spanishworddojo/screen_awake"

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Without this the volume keys adjust the ringtone stream whenever no
        // sound happens to be playing, so the user cannot turn quiz audio up.
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Google TTS ships only the system-language voice, so a Korean or
        // Japanese phone has no Spanish data and pronunciation stays silent.
        // These send the user somewhere they can install it.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "installVoiceData" ->
                        result.success(
                            startTtsIntent(TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA)
                        )
                    "openTtsSettings" ->
                        result.success(startTtsIntent("com.android.settings.TTS_SETTINGS"))
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_AWAKE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "setEnabled") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val enabled = call.argument<Boolean>("enabled") == true
                runOnUiThread {
                    if (enabled) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    result.success(true)
                }
            }
    }

    private fun startTtsIntent(action: String): Boolean =
        try {
            startActivity(Intent(action).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
}

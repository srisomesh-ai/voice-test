package com.bharatgps.voice_test

import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val CHANNEL = "bharatgps/voice"
    private var channel: MethodChannel? = null
    private var recognizer: SpeechRecognizer? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "listen") {
                startListening()
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startListening() {
        runOnUiThread {
            try {
                if (recognizer == null) {
                    recognizer = SpeechRecognizer.createSpeechRecognizer(this)
                    recognizer?.setRecognitionListener(object : RecognitionListener {
                        override fun onReadyForSpeech(params: Bundle?) { channel?.invokeMethod("onReady", null) }
                        override fun onResults(results: Bundle?) {
                            val list = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                            val text = if (list != null && list.isNotEmpty()) list[0] else ""
                            channel?.invokeMethod("onResult", text)
                        }
                        override fun onError(error: Int) { channel?.invokeMethod("onError", "code $error") }
                        override fun onBeginningOfSpeech() {}
                        override fun onEndOfSpeech() {}
                        override fun onPartialResults(partialResults: Bundle?) {}
                        override fun onEvent(eventType: Int, params: Bundle?) {}
                        override fun onBufferReceived(buffer: ByteArray?) {}
                        override fun onRmsChanged(rmsdB: Float) {}
                    })
                }
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-IN")
                intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, false)
                recognizer?.startListening(intent)
            } catch (e: Exception) {
                channel?.invokeMethod("onError", e.message ?: "unknown")
            }
        }
    }

    override fun onDestroy() {
        recognizer?.destroy()
        super.onDestroy()
    }
}

package com.akshaynjarangal.myyoutube
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        flutterEngine?.dartExecutor?.binaryMessenger?.let {
            MethodChannel(it, "com.akshay").setMethodCallHandler { call, result ->
                when (call.method) {
                    "loadUrl" -> {
                        val url = call.argument<String>("url")
                        val title = call.argument<String>("title")
                        if (url != null) {
                            val intent = Intent(this, YoutubeWebActivity::class.java)
                            intent.putExtra("url", url)
                            intent.putExtra("title",title)
                            startActivity(intent)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
        }
    }
}

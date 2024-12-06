package com.sneekin.app

import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sneekin/path"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFileName") {
                val filePath = call.argument<String>("path")
                val fileName = getFileNameFromPath(filePath)
                if (fileName != null) {
                    result.success(fileName)
                } else {
                    result.error("UNAVAILABLE", "File name not found", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getFileNameFromPath(filePath: String?): String? {
        filePath?.let {
            val uri = Uri.parse(it)
            contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                cursor.moveToFirst()
                return cursor.getString(nameIndex)
            }
        }
        return null
    }
}

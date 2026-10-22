package com.example.youtube

import android.content.ContentValues
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException

/**
 * Launcher activity. Extends audio_service's activity (background playback) and adds a small
 * channel that saves files into the public Downloads folder with the right MIME type.
 */
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ftube/public_downloads")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sdkVersion" -> result.success(Build.VERSION.SDK_INT)
                    "save" -> {
                        val path = call.argument<String>("path")
                        val name = call.argument<String>("name")
                        val mimeType = call.argument<String>("mimeType")
                        if (path == null || name == null || mimeType == null) {
                            result.error("ARGUMENTS", "path, name and mimeType are required", null)
                            return@setMethodCallHandler
                        }
                        Thread {
                            try {
                                val location = save(path, name, mimeType)
                                runOnUiThread { result.success(location) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("SAVE_FAILED", e.toString(), null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /** Copies [path] into Download/FTube as [name]; returns where it was saved. */
    private fun save(path: String, name: String, mimeType: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, "${Environment.DIRECTORY_DOWNLOADS}/FTube")
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                ?: throw IOException("MediaStore refused the file")
            try {
                val output = resolver.openOutputStream(uri) ?: throw IOException("No output stream")
                output.use { out -> FileInputStream(path).use { input -> input.copyTo(out) } }
                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(uri, values, null, null)
            } catch (e: Exception) {
                resolver.delete(uri, null, null)
                throw e
            }
            return uri.toString()
        }
        // Android 9 and older: write the public folder directly (WRITE_EXTERNAL_STORAGE).
        @Suppress("DEPRECATION")
        val directory = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            "FTube",
        )
        if (!directory.exists() && !directory.mkdirs()) throw IOException("Cannot create $directory")
        val dot = name.lastIndexOf('.')
        val base = if (dot > 0) name.substring(0, dot) else name
        val extension = if (dot > 0) name.substring(dot) else ""
        var target = File(directory, name)
        var n = 2
        while (target.exists()) target = File(directory, "$base (${n++})$extension")
        File(path).copyTo(target)
        MediaScannerConnection.scanFile(this, arrayOf(target.path), arrayOf(mimeType), null)
        return target.path
    }
}

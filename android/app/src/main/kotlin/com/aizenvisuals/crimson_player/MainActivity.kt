package com.aizenvisuals.crimson_player

import android.content.ContentUris
import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Build
import android.provider.MediaStore.Audio.Media
import android.util.Size
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(
            messenger,
            "crimson_player/local_library",
            StandardMethodCodec.INSTANCE,
            messenger.makeBackgroundTaskQueue()
        ).setMethodCallHandler { call, result ->
            val response = try {
                when (call.method) {
                    "songs" -> songs()
                    "artwork" -> artwork(requireNotNull(call.argument<Number>("id")).toLong())
                    else -> {
                        result.notImplemented()
                        return@setMethodCallHandler
                    }
                }
            } catch (error: Exception) {
                result.error("media_store", error.message, null)
                return@setMethodCallHandler
            }
            result.success(response)
        }
    }

    private fun songs(): List<Map<String, Any?>> {
        val projection = arrayOf(
            Media._ID, Media.TITLE, Media.ARTIST, Media.ALBUM, Media.DURATION, Media.DATA
        )
        val tracks = mutableListOf<Map<String, Any?>>()
        contentResolver.query(
            Media.EXTERNAL_CONTENT_URI, projection, null, null,
            "${Media.TITLE} COLLATE NOCASE ASC"
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                val path = cursor.getString(5)
                if (path.isNullOrEmpty()) continue
                tracks.add(mapOf(
                    "id" to cursor.getLong(0),
                    "title" to cursor.getString(1),
                    "artist" to cursor.getString(2),
                    "album" to cursor.getString(3),
                    "duration" to if (cursor.isNull(4)) null else cursor.getLong(4),
                    "path" to path
                ))
            }
        }
        return tracks
    }

    private fun artwork(id: Long): ByteArray? {
        val uri = ContentUris.withAppendedId(Media.EXTERNAL_CONTENT_URI, id)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val bitmap = contentResolver.loadThumbnail(uri, Size(200, 200), null)
            return ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 90, output)
                output.toByteArray()
            }
        }

        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(this, uri)
            retriever.embeddedPicture
        } finally {
            retriever.release()
        }
    }
}

package jhass.eu.insporation

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

private const val SHARE_RECEIVER_CHANNEL = "insporation/share_receiver"

class ShareEventStream {
  private val intentQueue = Channel<Intent>()

  fun push(intent: Intent) {
    GlobalScope.launch {
      intentQueue.send(intent)
    }
  }

  fun setup(context: Context, flutterEngine: FlutterEngine) {
    val shareReceiverChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_RECEIVER_CHANNEL)
    shareReceiverChannel.setStreamHandler(QueueEventHandler(intentQueue) { event -> process(context, event) })
  }

  private suspend fun process(context: Context, event: Intent): Map<String, Any?>? {
    when (event.action) {
      Intent.ACTION_SEND -> {
        if (event.type == "text/plain") {
          return mapOf(
            "type" to "text",
            "subject" to event.getStringExtra(Intent.EXTRA_SUBJECT),
            "text" to event.getStringExtra(Intent.EXTRA_TEXT)
          )
        } else if (event.type?.startsWith("image/") == true) {
           return mapOf(
            "type" to "images",
            "images" to listOf(fetchImage(context, event.getParcelableExtra(Intent.EXTRA_STREAM)))
          )
        }
      }
      Intent.ACTION_SEND_MULTIPLE -> {
        if (event.type?.startsWith("image/") == true) {
          return mapOf(
            "type" to "images",
            "images" to event.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM).map { uri -> fetchImage(context, uri) }
          )
        }
      }
    }

    return null
  }

  private suspend fun fetchImage(context: Context, uri: Uri): String {
    if (uri.scheme == "content") {
      // There's no sane way to resolve a content URI from flutter side, so we copy the file into our local cache first so we can pass flutter a file URI
      val cachePath = File(context.cacheDir, uri.lastPathSegment)
      withContext(Dispatchers.IO) {
        context.contentResolver.openInputStream(uri)?.use { source ->
          cachePath.outputStream().use { cache ->
            source.copyTo(cache)
          }
        }
      }
      return Uri.fromFile(cachePath).toString()
    }

    return uri.toString()
  }
}

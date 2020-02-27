package jhass.eu.insporation

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.annotation.UiThread
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import java.io.File
import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue

const val SHARE_RECEIVER_CHANNEL = "insporation/share_receiver";

class ShareEventStream {
  private val intentQueue = LinkedBlockingQueue<Intent>()

  fun push(intent : Intent) {
    intentQueue.add(intent)
  }

  fun setup(context : Context, flutterEngine: FlutterEngine) {
    val shareReceiverChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_RECEIVER_CHANNEL)
    shareReceiverChannel.setStreamHandler(StreamHandler(context, intentQueue))
  }
}

private class StreamHandler(private val context : Context, private val queue : BlockingQueue<Intent>) : EventChannel.StreamHandler {
  private var listener : ListenerThread? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (events == null) {
      return
    }

    listener?.cancel()
    listener = ListenerThread(context, events, queue)
    listener?.start()
  }

  override fun onCancel(arguments: Any?) {
    listener?.cancel()
    listener = null
  }
}

private class ListenerThread(private val context : Context, private val events : EventChannel.EventSink, private val queue: BlockingQueue<Intent>) : Thread("ShareQueueListener") {
  private var canceled = false

  fun cancel() {
    canceled = true
    interrupt()
  }

  override fun run() {
    val handler = Handler(Looper.getMainLooper())
    while (true) {
      try {
        val intent = queue.take()
        val event = processIntent(intent)
        if (event != null) {
          handler.post { events.success(event) }
        }
      } catch (e: InterruptedException) {
        if (canceled) {
          break
        }
      }
    }
  }

  @UiThread
  private fun processIntent(intent : Intent) : Map<String, Any>? {
    when (intent.action) {
      Intent.ACTION_SEND -> {
        if (intent.type == "text/plain") {
          return mapOf(
            "type" to "text",
            "subject" to intent.getStringExtra(Intent.EXTRA_SUBJECT),
            "text" to intent.getStringExtra(Intent.EXTRA_TEXT)
          )
        } else if (intent.type?.startsWith("image/") == true) {
           return mapOf(
            "type" to "images",
            "images" to listOf(fetchImage(intent.getParcelableExtra(Intent.EXTRA_STREAM)))
          )
        }
      }
      Intent.ACTION_SEND_MULTIPLE -> {
        if (intent.type?.startsWith("image/") == true) {
          return mapOf(
            "type" to "images",
            "images" to intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM).map(this::fetchImage)
          )
        }
      }
    }

    return null
  }

  private fun fetchImage(uri : Uri) : String {
    if (uri.scheme == "content") {
      // There's no sane way to resolve a content URI from flutter side, so we copy the file into our local cache first so we can pass flutter a file URI
      val cachePath = File(context.cacheDir, uri.lastPathSegment)
      context.contentResolver.openInputStream(uri)?.use { source ->
        cachePath.outputStream().use { cache ->
            source.copyTo(cache)
          return Uri.fromFile(cachePath).toString()
        }
      }
    }

    return uri.toString()
  }
}

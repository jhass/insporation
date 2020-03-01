package jhass.eu.insporation

import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

typealias ProcessEvent<T> = suspend (event: T) -> Map<String, Any?>?

class QueueEventHandler<T>(private val queue: Channel<T>, private val onEvent: ProcessEvent<T>) : EventChannel.StreamHandler {
  private var currentSink: Channel<T>? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (events == null) {
      return
    }

    val sink = Channel<T>()
    currentSink?.cancel()
    currentSink = sink

    GlobalScope.launch {
      for (event in queue) {
        sink.send(event)
      }
    }

    GlobalScope.launch {
      for (event in sink) {
        val result = onEvent(event)
        if (result != null) {
          withContext(Dispatchers.Main) {
            events.success(result)
          }
        }
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    currentSink?.cancel()
  }
}
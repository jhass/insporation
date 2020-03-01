package jhass.eu.insporation

import android.content.Intent
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import java.lang.ref.WeakReference

private const val APP_AUTH_REQUEST_CODE = 1
private const val STATE_AUTHORIZING_DATA = "authorizing_data"

class MainActivity: FlutterActivity() {
  private val appAuthHandler = AppAuthHandler()
  private val shareEventStream = ShareEventStream()
  var authorizingData: String? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    shareEventStream.push(intent)
  }

  override fun onRestoreInstanceState(savedInstanceState: Bundle?) {
    super.onRestoreInstanceState(savedInstanceState)

    authorizingData = savedInstanceState?.getString(STATE_AUTHORIZING_DATA)
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine)

    val self = WeakReference(this)
    appAuthHandler.setup(applicationContext, flutterEngine) { intent, data ->
      self.get()?.authorizingData = data
      self.get()?.startActivityForResult(intent, APP_AUTH_REQUEST_CODE)
    }
    shareEventStream.setup(applicationContext, flutterEngine)
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    shareEventStream.push(intent)
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == APP_AUTH_REQUEST_CODE) {
      val authorizingData = this.authorizingData
      if (data != null && authorizingData != null) {
        appAuthHandler.process(data, authorizingData)
        this.authorizingData = null
      }
    } else {
      super.onActivityResult(requestCode, resultCode, data)
    }
  }

  override fun onSaveInstanceState(outState: Bundle?) {
    super.onSaveInstanceState(outState)

    outState?.putString(STATE_AUTHORIZING_DATA, authorizingData)
  }
}

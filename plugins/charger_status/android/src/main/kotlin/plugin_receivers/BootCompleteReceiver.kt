package plugin_receivers

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import com.bexsoluciones.charger_status.PluginEvent
import com.bexsoluciones.charger_status.PluginEventEmitter

private const val TAG = "BootCompleteReceiver"
class BootCompleteReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.i(TAG, "onReceive: ${intent.action}")

        when(intent.action){
            "android.intent.action.BOOT_COMPLETED" -> {
                PluginEventEmitter.emitEvent(PluginEvent.BootCompleted)
            }
        }
    }
}
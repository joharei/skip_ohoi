package app.reitan.skip_ohoi

import androidx.arch.core.util.Function
import dev.thinkng.flt_worker.FltWorkerPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        FltWorkerPlugin.registerPluginsForWorkers = Function { registry: PluginRegistry ->
            io.flutter.plugins.pathprovider.PathProviderPlugin.registerWith(
                    registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"))
            com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin.registerWith(
                    registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
            null
        }
    }
}

package com.elitesync.syntheticdemo

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun getInitialRoute(): String = "/home"

    private fun fixedEndpoints(): BootstrapEndpointPolicy.Endpoints {
        require(BuildConfig.DEBUG && BuildConfig.ELITESYNC_SYNTHETIC_DEMO) {
            "Synthetic host requires debug and the explicit synthetic marker"
        }
        return BootstrapEndpointPolicy.resolve(synthetic = true, debug = BuildConfig.DEBUG)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        fixedEndpoints()
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        fixedEndpoints()
        super.onNewIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        fixedEndpoints()
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "elitesync/bootstrap")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBootstrap" -> {
                        val endpoints = fixedEndpoints()
                        result.success(
                            mapOf(
                                "apiBaseUrl" to endpoints.apiBaseUrl,
                                "wsBaseUrl" to endpoints.wsBaseUrl,
                                "initialRoute" to "/home",
                                "appVersionName" to BuildConfig.VERSION_NAME,
                                "appVersionCode" to BuildConfig.VERSION_CODE.toString(),
                                "debugBuild" to BuildConfig.DEBUG.toString(),
                            ),
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

package com.elitesync

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        setIntent(intent)
        ensureBootstrapDefaults()
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        ensureBootstrapDefaults()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "elitesync/bootstrap")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBootstrap" -> {
                        val extras = intent?.extras
                        val synthetic = BuildConfig.ELITESYNC_SYNTHETIC_DEMO
                        val syntheticEndpoints = if (synthetic) {
                            BootstrapEndpointPolicy.resolve(synthetic = true, debug = BuildConfig.DEBUG)
                        } else {
                            null
                        }
                        val fileBootstrap = readBootstrapFile(includeEndpoints = !synthetic)
                        val endpoints = syntheticEndpoints ?: BootstrapEndpointPolicy.resolve(
                            synthetic = false,
                            debug = BuildConfig.DEBUG,
                            intentApi = extras?.getString("elitesync_api_base_url"),
                            intentWs = extras?.getString("elitesync_ws_base_url"),
                            fileApi = fileBootstrap["elitesync_api_base_url"],
                            fileWs = fileBootstrap["elitesync_ws_base_url"],
                        )
                        result.success(
                            mapOf(
                                "apiBaseUrl" to endpoints.apiBaseUrl,
                                "wsBaseUrl" to endpoints.wsBaseUrl,
                                "initialRoute" to firstNonBlank(
                                    extras?.getString("elitesync_initial_route"),
                                    fileBootstrap["elitesync_initial_route"],
                                ),
                                "appVersionName" to BuildConfig.VERSION_NAME,
                                "appVersionCode" to BuildConfig.VERSION_CODE.toString(),
                                "debugBuild" to BuildConfig.DEBUG.toString(),
                            ),
                        )
                    }

                    "clearBootstrap" -> {
                        clearBootstrapFile()
                        result.success(true)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun ensureBootstrapDefaults() {
        val syntheticEndpoints = if (BuildConfig.ELITESYNC_SYNTHETIC_DEMO) {
            BootstrapEndpointPolicy.resolve(synthetic = true, debug = BuildConfig.DEBUG)
        } else {
            null
        }
        val currentIntent = intent ?: return
        if (syntheticEndpoints != null) {
            currentIntent.putExtra("elitesync_api_base_url", syntheticEndpoints.apiBaseUrl)
            currentIntent.putExtra("elitesync_ws_base_url", syntheticEndpoints.wsBaseUrl)
            return
        }
        if (currentIntent.getStringExtra("elitesync_api_base_url").isNullOrBlank()) {
            currentIntent.putExtra("elitesync_api_base_url", BuildConfig.API_BASE_URL)
        }
        if (currentIntent.getStringExtra("elitesync_ws_base_url").isNullOrBlank()) {
            currentIntent.putExtra("elitesync_ws_base_url", BuildConfig.WS_BASE_URL)
        }
    }

    private fun readBootstrapFile(includeEndpoints: Boolean): Map<String, String> {
        val bootstrapFile = File(filesDir, "elitesync_bootstrap.json")
        if (!bootstrapFile.exists()) return emptyMap()
        return runCatching {
            val json = JSONObject(bootstrapFile.readText())
            buildMap {
                json.keys().forEach { key ->
                    if (includeEndpoints || (key != "elitesync_api_base_url" && key != "elitesync_ws_base_url")) {
                        put(key, json.optString(key, ""))
                    }
                }
            }
        }.getOrDefault(emptyMap())
    }

    private fun clearBootstrapFile() {
        runCatching {
            File(filesDir, "elitesync_bootstrap.json").delete()
        }
    }

    private fun firstNonBlank(first: String?, second: String?): String {
        val firstValue = first?.trim().orEmpty()
        if (firstValue.isNotEmpty()) return firstValue
        return second?.trim().orEmpty()
    }

}

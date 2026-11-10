package com.elitesync

object BootstrapEndpointPolicy {
    data class Endpoints(val apiBaseUrl: String, val wsBaseUrl: String)

    fun resolve(
        synthetic: Boolean,
        debug: Boolean,
        intentApi: String? = null,
        intentWs: String? = null,
        fileApi: String? = null,
        fileWs: String? = null,
        compiledApi: String = "",
        compiledWs: String = "",
    ): Endpoints {
        if (synthetic) {
            require(debug) { "Synthetic bootstrap requires a debug build" }
            return Endpoints("http://127.0.0.1:8080/", "ws://127.0.0.1:8080/")
        }
        // The exported Activity must not let another app replace the service
        // receiving release credentials, even with an otherwise valid TLS URL.
        if (!debug) return Endpoints(compiledApi.trim(), compiledWs.trim())
        return Endpoints(firstNonBlank(intentApi, fileApi), firstNonBlank(intentWs, fileWs))
    }

    private fun firstNonBlank(first: String?, second: String?): String {
        val firstValue = first?.trim().orEmpty()
        if (firstValue.isNotEmpty()) return firstValue
        return second?.trim().orEmpty()
    }
}

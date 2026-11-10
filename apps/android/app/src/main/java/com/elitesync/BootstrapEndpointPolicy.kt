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
    ): Endpoints {
        if (synthetic) {
            require(debug) { "Synthetic bootstrap requires a debug build" }
            return Endpoints("http://127.0.0.1:8080/", "ws://127.0.0.1:8080/")
        }
        return Endpoints(firstNonBlank(intentApi, fileApi), firstNonBlank(intentWs, fileWs))
    }

    private fun firstNonBlank(first: String?, second: String?): String {
        val firstValue = first?.trim().orEmpty()
        if (firstValue.isNotEmpty()) return firstValue
        return second?.trim().orEmpty()
    }
}

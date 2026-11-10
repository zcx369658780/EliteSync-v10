package com.elitesync

object BootstrapEndpointPolicyJvmTest {
    @JvmStatic
    fun main(args: Array<String>) {
        var cases = 0
        val expected = BootstrapEndpointPolicy.Endpoints("http://127.0.0.1:8080/", "ws://127.0.0.1:8080/")
        fun case(name: String, body: () -> Unit) {
            body()
            cases += 1
            println("PASS $name")
        }
        case("synthetic rejects external Intent and file endpoints") {
            check(BootstrapEndpointPolicy.resolve(true, true, "https://external.invalid/", "wss://external.invalid/", "https://file.invalid/", "wss://file.invalid/") == expected)
        }
        case("synthetic ignores null endpoints") {
            check(BootstrapEndpointPolicy.resolve(true, true) == expected)
        }
        case("synthetic ignores blank endpoints") {
            check(BootstrapEndpointPolicy.resolve(true, true, "", " ", "\t", "") == expected)
        }
        case("synthetic ignores malformed endpoints") {
            check(BootstrapEndpointPolicy.resolve(true, true, "htp://typo", "wss:/typo", "not a URL", "ws::bad") == expected)
        }
        case("synthetic initial and new input resolve identically") {
            val initial = BootstrapEndpointPolicy.resolve(true, true, "https://initial.invalid/", "wss://initial.invalid/")
            val next = BootstrapEndpointPolicy.resolve(true, true, "https://new.invalid/", "wss://new.invalid/", "https://file.invalid/", "wss://file.invalid/")
            check(initial == next && next == expected)
        }
        case("synthetic nondebug fails with no inputs") {
            check(runCatching { BootstrapEndpointPolicy.resolve(true, false) }.exceptionOrNull() is IllegalArgumentException)
        }
        case("synthetic nondebug fails with external inputs") {
            check(runCatching { BootstrapEndpointPolicy.resolve(true, false, "https://external.invalid/", "wss://external.invalid/") }.exceptionOrNull() is IllegalArgumentException)
        }
        case("debug Intent wins and trims") {
            check(BootstrapEndpointPolicy.resolve(false, true, "  https://intent.invalid/  ", "  wss://intent.invalid/  ", "https://file.invalid/", "wss://file.invalid/") == BootstrapEndpointPolicy.Endpoints("https://intent.invalid/", "wss://intent.invalid/"))
        }
        case("ordinary blank Intent falls back to trimmed file") {
            check(BootstrapEndpointPolicy.resolve(false, true, " ", "\t", "  https://file.invalid/  ", " wss://file.invalid/ ") == BootstrapEndpointPolicy.Endpoints("https://file.invalid/", "wss://file.invalid/"))
        }
        case("debug null Intent falls back to file") {
            check(BootstrapEndpointPolicy.resolve(false, true, fileApi = "https://file.invalid/", fileWs = "wss://file.invalid/") == BootstrapEndpointPolicy.Endpoints("https://file.invalid/", "wss://file.invalid/"))
        }
        case("ordinary API and WS resolve independently") {
            check(BootstrapEndpointPolicy.resolve(false, true, "https://intent.invalid/", null, "https://file.invalid/", "wss://file.invalid/") == BootstrapEndpointPolicy.Endpoints("https://intent.invalid/", "wss://file.invalid/"))
        }
        case("ordinary absent inputs return empty strings") {
            check(BootstrapEndpointPolicy.resolve(false, false) == BootstrapEndpointPolicy.Endpoints("", ""))
        }
        case("ordinary blank file inputs return empty strings") {
            check(BootstrapEndpointPolicy.resolve(false, true, " ", "", "\t", " ") == BootstrapEndpointPolicy.Endpoints("", ""))
        }
        case("debug leaves malformed values for the downstream URL validator") {
            check(BootstrapEndpointPolicy.resolve(false, true, " bad-api ", " bad-ws ") == BootstrapEndpointPolicy.Endpoints("bad-api", "bad-ws"))
        }
        case("nondebug rejects injected Intent and file endpoints") {
            check(BootstrapEndpointPolicy.resolve(false, false, "https://injected.invalid/", "wss://injected.invalid/", "https://file.invalid/", "wss://file.invalid/") == BootstrapEndpointPolicy.Endpoints("", ""))
        }
        case("nondebug uses only the compiled API and websocket authority") {
            check(BootstrapEndpointPolicy.resolve(false, false,
                intentApi = "https://injected.invalid/", intentWs = "wss://injected.invalid/",
                fileApi = "https://file.invalid/", fileWs = "wss://file.invalid/",
                compiledApi = " https://configured.invalid/ ", compiledWs = " wss://configured.invalid/ ") ==
                BootstrapEndpointPolicy.Endpoints("https://configured.invalid/", "wss://configured.invalid/"))
        }
        println("TOTAL $cases/16 PASS")
        check(cases == 16)
    }
}

# v10.1.5 USB device continuation — bounded review

PARTIAL / OPEN_BLOCKERS / AC05_OPEN / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE.

Same frozen task, latest Task Blob `43b2396b2fba046d5c0ab00bea87293783d1c2fd`. Build input `c445554f01fbd8c9aef641302f3f090900703786`; underlying RTC implementation `67f83b053096b181ff64366f3eaad0e5e44815f8`. Product trees are unchanged in this continuation. All 735 tracked app files matched the actual isolated build copy.

Ordinary main.dart R1 APK built and updated onto the single Owner-authorized Xiaomi Android 16 phone; installed readback matched APK SHA. Actual phone UI text send, incoming reject/accept, early hangup and next call, unexpired-token authorization negative, notification GUI preferences and permission lifecycle, and cold-start lock were observed. Detailed limitations remain in device-results and transport-summary. This is CODEX_REPORTED / DEVICE_NEW_RUN. PC fake devices were a TEST_ONLY endpoint and did not establish media.

No bidirectional RTP, media reconnect, physical AEC, or flowing-media five-second stop is proven. `in_call` and RoomConnected events do not imply successful media. Gate 2, full 37 cases, conditional SDK/Producer/libs.jar/30 resolutions remain NOT_RUN. No new Gate 2 budget or original entry was used.

Only sanitized summaries and hashes are published. APK, SQL, serial, tokens, raw device logs, UI XML and complete LOCAL_ONLY files are not in this package. Original commands, bytes and results remain local. This package is derived evidence, not byte-identical copies of private raw logs. No production/main integration or v10.1.6 start.

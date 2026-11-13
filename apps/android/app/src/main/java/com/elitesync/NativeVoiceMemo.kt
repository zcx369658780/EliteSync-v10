package com.elitesync

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

/** Owns one temporary memo and one player. Business authorization stays with the caller. */
class NativeVoiceMemo(private val context: Context) : MethodChannel.MethodCallHandler {
    // Leave room for AAC frames/container padding below the server's strict 60-second cap.
    private val maximumRecordingMs = 59900L
    private val handler = Handler(Looper.getMainLooper())
    private val memoDirectory = File(context.cacheDir, "voice-memos")
    private var recorder: MediaRecorder? = null
    private var player: MediaPlayer? = null
    private var preview: File? = null
    private var recordingStartedAt = 0L
    private var durationMs = 0L
    private var playbackState = "idle"
    private var completedPlaybackDurationMs = 0
    private var errorCode: String? = null
    private val recordingDeadline = Runnable { finishRecording() }

    init {
        check(memoDirectory.isDirectory || memoDirectory.mkdirs()) { "voice_storage_unavailable" }
        // MainActivity owns the sole bridge. Recover only this bridge's orphaned files.
        memoDirectory.listFiles()?.forEach { file ->
            if (file.isFile && file.name.startsWith("voice-memo-") && file.name.endsWith(".m4a")) {
                file.delete()
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "start" -> startRecording()
                "stop" -> finishRecording()
                "status" -> Unit
                "discard" -> discard()
                "play" -> play(call)
                "pausePlayback" -> {
                    if (playbackState == "playing") {
                        player?.pause()
                        playbackState = "paused"
                    }
                }
                "resumePlayback" -> {
                    check(recorder == null) { "recording_active" }
                    check(playbackState != "completed") { "replay_requires_source" }
                    if (playbackState == "paused") {
                        player?.start()
                        playbackState = "playing"
                    }
                }
                "stopPlayback" -> stopPlayback()
                "release" -> discard()
                else -> {
                    result.notImplemented()
                    return
                }
            }
            result.success(snapshot())
        } catch (error: Exception) {
            val code = when (error) {
                is SecurityException -> "microphone_denied"
                is IllegalArgumentException -> "invalid_voice_source"
                else -> error.message?.takeIf { it.matches(Regex("[a-z_]+")) }
                    ?: "voice_operation_failed"
            }
            errorCode = code
            result.error(code, "Voice memo operation could not be completed", null)
        }
    }

    @Suppress("DEPRECATION")
    private fun startRecording() {
        check(recorder == null) { "recording_active" }
        if (context.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            throw SecurityException("microphone_denied")
        }
        discard()
        errorCode = null
        val file = File.createTempFile("voice-memo-", ".m4a", memoDirectory)
        val next = if (Build.VERSION.SDK_INT >= 31) MediaRecorder(context) else MediaRecorder()
        try {
            next.setAudioSource(MediaRecorder.AudioSource.MIC)
            next.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
            next.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            next.setAudioChannels(1)
            next.setAudioSamplingRate(44100)
            next.setAudioEncodingBitRate(96000)
            next.setMaxDuration(maximumRecordingMs.toInt())
            next.setMaxFileSize(5L * 1024L * 1024L)
            next.setOutputFile(file.absolutePath)
            next.setOnInfoListener { current, what, _ ->
                if (recorder === current && (what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_DURATION_REACHED ||
                    what == MediaRecorder.MEDIA_RECORDER_INFO_MAX_FILESIZE_REACHED)) {
                    finishRecording(alreadyStopped = true)
                }
            }
            next.setOnErrorListener { current, _, _ ->
                if (recorder === current) abandonRecording("recording_failed")
            }
            next.prepare()
            next.start()
            preview = file
            recorder = next
            recordingStartedAt = SystemClock.elapsedRealtime()
            handler.postDelayed(recordingDeadline, maximumRecordingMs)
        } catch (error: Exception) {
            runCatching { next.release() }
            file.delete()
            throw error
        }
    }

    private fun finishRecording(alreadyStopped: Boolean = false) {
        val current = recorder ?: return
        recorder = null
        handler.removeCallbacks(recordingDeadline)
        val elapsed = SystemClock.elapsedRealtime() - recordingStartedAt
        val stopped = runCatching { current.stop() }.isSuccess
        runCatching { current.release() }
        val metadata = MediaMetadataRetriever()
        durationMs = try {
            runCatching {
                metadata.setDataSource(preview!!.absolutePath)
                metadata.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)?.toLongOrNull() ?: 0L
            }.getOrDefault(0L)
        } finally {
            runCatching { metadata.release() }
        }
        val size = preview?.length() ?: 0L
        if ((!stopped && !alreadyStopped) || elapsed < 1000L || durationMs !in 1000L..60000L ||
            size !in 1L..(5L * 1024L * 1024L)) {
            val durationTooLong = durationMs > 60000L
            preview?.delete()
            preview = null
            durationMs = 0
            errorCode = when {
                durationTooLong -> "recording_too_long"
                elapsed < 1000L -> "recording_too_short"
                else -> "recording_failed"
            }
        }
    }

    private fun abandonRecording(code: String) {
        handler.removeCallbacks(recordingDeadline)
        recorder?.let { current ->
            recorder = null
            runCatching { current.stop() }
            runCatching { current.release() }
        }
        preview?.delete()
        preview = null
        durationMs = 0
        errorCode = code
    }

    private fun play(call: MethodCall) {
        check(recorder == null) { "recording_active" }
        val source = call.argument<String>("source") ?: throw IllegalArgumentException()
        val uri = Uri.parse(source)
        val remote = uri.scheme == "http" || uri.scheme == "https"
        if (remote) {
            val api = Uri.parse(BuildConfig.API_BASE_URL)
            require(uri.scheme == api.scheme && uri.host == api.host && uri.port == api.port)
            require(uri.userInfo == null && uri.query == null && uri.fragment == null)
            require(Regex("/api/v1/media/[1-9][0-9]*/content").matches(uri.path.orEmpty()))
        } else {
            require(uri.scheme == null || uri.scheme == "file")
            val file = File(if (uri.scheme == "file") uri.path.orEmpty() else source).canonicalFile
            require(file == preview?.canonicalFile && file.isFile)
        }
        stopPlayback()
        errorCode = null
        val next = MediaPlayer()
        player = next
        playbackState = "preparing"
        try {
            next.setOnPreparedListener { prepared ->
                if (player === prepared) {
                    prepared.start()
                    playbackState = "playing"
                }
            }
            next.setOnCompletionListener { completed ->
                if (player === completed) {
                    val finalDuration = runCatching { completed.duration }.getOrDefault(0)
                    stopPlayback()
                    completedPlaybackDurationMs = finalDuration
                    playbackState = "completed"
                }
            }
            next.setOnErrorListener { failed, _, _ ->
                if (player === failed) {
                    stopPlayback()
                    errorCode = "playback_failed"
                }
                true
            }
            if (remote) {
                val headers = call.argument<Map<String, String>>("headers").orEmpty()
                val authorization = headers["Authorization"]
                require(!authorization.isNullOrBlank())
                next.setDataSource(context, uri, mapOf("Authorization" to authorization))
            } else {
                next.setDataSource(preview!!.absolutePath)
            }
            next.prepareAsync()
        } catch (error: Exception) {
            stopPlayback()
            throw error
        }
    }

    private fun stopPlayback() {
        val current = player
        player = null
        playbackState = "idle"
        completedPlaybackDurationMs = 0
        runCatching { current?.reset() }
        runCatching { current?.release() }
    }

    private fun snapshot(): Map<String, Any?> = mapOf(
        "recording" to (recorder != null),
        "previewPath" to preview?.absolutePath,
        "durationMs" to durationMs,
        "sizeBytes" to (preview?.length() ?: 0L),
        "recordingElapsedMs" to if (recorder != null) SystemClock.elapsedRealtime() - recordingStartedAt else 0L,
        "playbackState" to playbackState,
        "positionMs" to if (playbackState == "completed") completedPlaybackDurationMs
            else if (playbackState in listOf("playing", "paused"))
            runCatching { player?.currentPosition ?: 0 }.getOrDefault(0) else 0,
        "playbackDurationMs" to if (playbackState == "completed") completedPlaybackDurationMs
            else if (playbackState in listOf("playing", "paused"))
            runCatching { player?.duration ?: 0 }.getOrDefault(0) else 0,
        "errorCode" to errorCode,
    )

    /** No native capture or playback survives a background transition. */
    fun onPause() {
        finishRecording()
        stopPlayback()
    }

    fun discard() {
        abandonRecording("cancelled")
        stopPlayback()
        errorCode = null
    }
}

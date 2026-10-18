import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.File
import java.util.Properties
import java.net.URI

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val baiduAkFromProp = (project.findProperty("BAIDU_MAP_AK") as String?)
    ?: localProps.getProperty("BAIDU_MAP_AK", "")
val baiduSecurityCodeFromProp = (project.findProperty("BAIDU_MAP_SECURITY_CODE") as String?)
    ?: localProps.getProperty("BAIDU_MAP_SECURITY_CODE", "")

val flutterModuleDir = rootProject.file("../flutter_elitesync_module")
val flutterModuleLocalProps = Properties().apply {
    val f = rootProject.file("../flutter_elitesync_module/.android/local.properties")
    if (f.exists()) {
        f.inputStream().use { load(it) }
    }
}
val flutterSdkPath = flutterModuleLocalProps.getProperty("flutter.sdk")
    ?: localProps.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_HOME")
val flutterExecutable = when {
    !flutterSdkPath.isNullOrBlank() -> {
        val suffix = if (System.getProperty("os.name").lowercase().contains("windows")) "flutter.bat" else "flutter"
        File(flutterSdkPath, "bin/$suffix").absolutePath
    }
    System.getProperty("os.name").lowercase().contains("windows") -> "flutter.bat"
    else -> "flutter"
}

val flutterDartDefines = (
    providers.gradleProperty("flutterDartDefines").orNull
        ?: rootProject.findProperty("flutterDartDefines") as String?
        ?: project.findProperty("flutterDartDefines") as String?
    )
    ?.trim()
    .orEmpty()
val flutterDartDefineArgs = flutterDartDefines
    .split(Regex("[;,]"))
    .map { it.trim() }
    .filter { it.isNotEmpty() }
    .flatMap { listOf("--dart-define=$it") }
val isV1006LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .any { it == "ELITESYNC_V1006_LOCAL_BUILD=true" || it == "ELITESYNC_V1007_LOCAL_BUILD=true" || it == "ELITESYNC_V1008_LOCAL_BUILD=true" || it == "ELITESYNC_V1009_LOCAL_BUILD=true" || it == "ELITESYNC_V1010_LOCAL_BUILD=true" || it == "ELITESYNC_V1011_LOCAL_BUILD=true" }
val isV1011LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1011_LOCAL_BUILD=true")
val isV1010LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1010_LOCAL_BUILD=true")
val isV1009LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1009_LOCAL_BUILD=true")
val pilotDefines = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
val isV10100PilotBuild = pilotDefines.contains("ELITESYNC_V10_1_0_PILOT_BUILD=true")
fun pilotDefine(name: String): String {
    val values = pilotDefines.filter { it.startsWith("$name=") }
    require(values.size <= 1) { "Duplicate pilot build parameter: $name" }
    return values.singleOrNull()?.substringAfter('=')?.trim().orEmpty()
}
if (isV10100PilotBuild) {
    require(pilotDefine("ELITESYNC_V10_1_0_PILOT_BUILD") == "true")
}
fun validatePilotEndpoint(value: String, webSocket: Boolean = false): String {
    if (webSocket && value.isEmpty()) return value
    val uri = runCatching { URI(value) }.getOrNull()
    val secureScheme = if (webSocket) "wss" else "https"
    val loopbackScheme = if (webSocket) "ws" else "http"
    require(uri != null && uri.isAbsolute && !uri.host.isNullOrBlank() &&
        uri.rawUserInfo == null && uri.rawQuery == null && uri.rawFragment == null &&
        (uri.scheme == secureScheme ||
            (uri.scheme == loopbackScheme && uri.rawAuthority == "127.0.0.1:8030" &&
                (webSocket || value == "http://127.0.0.1:8030/")))) {
        "Pilot endpoint requires HTTPS/WSS or the controlled 127.0.0.1:8030 forwarding entry"
    }
    return value
}
val pilotApiBaseUrl = if (isV10100PilotBuild) validatePilotEndpoint(pilotDefine("ELITESYNC_PILOT_API_BASE_URL")) else ""
val pilotWsBaseUrl = if (isV10100PilotBuild) validatePilotEndpoint(pilotDefine("ELITESYNC_PILOT_WS_BASE_URL"), true) else ""
require(!isV10100PilotBuild || (!isV1006LocalBuild &&
    !pilotDefines.contains("ELITESYNC_SYNTHETIC_DEMO=true"))) {
    "Pilot build cannot be combined with a legacy restoration or synthetic build"
}
// The pilot is an isolated debug APK; do not silently emit a production/profile variant.
require(!isV10100PilotBuild || gradle.startParameter.taskNames.all {
    !it.contains("release", ignoreCase = true) && !it.contains("profile", ignoreCase = true)
}) { "Pilot build is debug-only" }
fun buildConfigString(value: String) = "\"" + value.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
val v1009DualDeviceBuild = providers.gradleProperty("v1009DualDeviceBuild").orNull == "true"
require(!v1009DualDeviceBuild || isV1009LocalBuild) {
    "Dual-device test builds require the V1009 local restoration gate"
}
val isC2LocalInternalBuild = flutterDartDefines
    .split(Regex("[;,]"))
    .map { it.trim() }
    .contains("ELITESYNC_C2_LOCAL_BUILD=true") || isV1006LocalBuild
val flutterReleaseAarRepo =
    File(flutterModuleDir, "build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0")
val isCiBuild = System.getenv("CI")?.equals("true", ignoreCase = true) == true

val syncFlutterAar by tasks.registering(Exec::class) {
    group = "build"
    description = "Build latest Flutter module AAR before Android preBuild"
    workingDir = flutterModuleDir
    onlyIf {
        if (isCiBuild && flutterReleaseAarRepo.exists() && !isV10100PilotBuild) {
            logger.lifecycle("Skipping syncFlutterAar because CI prebuilt Flutter release AAR at $flutterReleaseAarRepo")
            false
        } else {
            true
        }
    }
    commandLine(
        listOf(
            flutterExecutable,
            "build",
            "aar",
            "--no-pub",
            "--no-debug",
            "--no-profile",
        ) + (if (v1009DualDeviceBuild) listOf("--target-platform=android-x64,android-arm64")
            else if (isV1006LocalBuild || isV10100PilotBuild) listOf("--target-platform=android-x64") else emptyList()) + flutterDartDefineArgs
    )
    inputs.dir(File(flutterModuleDir, "lib"))
    inputs.file(File(flutterModuleDir, "pubspec.yaml"))
    inputs.property("flutterDartDefines", flutterDartDefines)
    inputs.property("v1009DualDeviceBuild", v1009DualDeviceBuild)
    outputs.dir(flutterReleaseAarRepo)
}

tasks.named("preBuild") {
    dependsOn(syncFlutterAar)
}

android {
    namespace = "com.elitesync"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.elitesync"
        buildConfigField("boolean", "ELITESYNC_SYNTHETIC_DEMO", "false")
        buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", "false")
        buildConfigField("boolean", "ELITESYNC_V10_1_0_PILOT_BUILD", "false")
        minSdk = 26
        targetSdk = 35
        // Versioning rule: major.minor.patch[alpha suffix]
        // versionCode uses an expanded numeric form to keep suffix releases ordered.
        versionCode = if (isV10100PilotBuild) 1010000 else 80400
        versionName = if (isV10100PilotBuild) "10.1.0-devpilot" else "0.08.04"
        ndk {
            // Google Play 16KB page-size compliance: avoid x86_64 native libs from third-party SDKs.
            // Keep ARM ABIs for real-device testing and release publishing.
            abiFilters += if (v1009DualDeviceBuild) {
                listOf("x86_64", "arm64-v8a")
            } else if (isC2LocalInternalBuild || isV10100PilotBuild) {
                listOf("x86_64")
            } else {
                listOf("arm64-v8a")
            }
        }
        buildConfigField("String", "API_BASE_URL", "\"https://slowdate.top/\"")
        buildConfigField("String", "WS_BASE_URL", "\"wss://slowdate.top/\"")
        buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
        buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
        buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
        manifestPlaceholders["BAIDU_MAP_AK"] = baiduAkFromProp

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        debug {
            // Keep Owner's existing application and its data untouched on both test devices.
            if (v1009DualDeviceBuild) applicationIdSuffix = ".v1009test"
            if (isV1010LocalBuild) applicationIdSuffix = ".v1010test"
            if (isV1011LocalBuild) applicationIdSuffix = ".v1011test"
            if (isV10100PilotBuild) applicationIdSuffix = ".v10100pilot"
            buildConfigField("boolean", "ELITESYNC_V10_1_0_PILOT_BUILD", isV10100PilotBuild.toString())
            buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", isV1006LocalBuild.toString())
            buildConfigField("String", "API_BASE_URL", if (isV1011LocalBuild) "\"http://127.0.0.1:8011/\"" else if (isV1010LocalBuild) "\"http://127.0.0.1:8010/\"" else if (isV1006LocalBuild) "\"http://127.0.0.1:8000/\"" else "\"http://101.133.161.203/\"")
            buildConfigField("String", "WS_BASE_URL", if (isV1006LocalBuild) "\"\"" else "\"ws://101.133.161.203:8081/\"")
            if (isV10100PilotBuild) {
                buildConfigField("String", "API_BASE_URL", buildConfigString(pilotApiBaseUrl))
                buildConfigField("String", "WS_BASE_URL", buildConfigString(pilotWsBaseUrl))
            }
            buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
            buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
            buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
        }
        create("profile") {
            initWith(getByName("debug"))
            buildConfigField("boolean", "ELITESYNC_V10_1_0_PILOT_BUILD", "false")
            matchingFallbacks += listOf("debug")
        }
        release {
            isMinifyEnabled = false
            buildConfigField("String", "API_BASE_URL", "\"https://slowdate.top/\"")
            buildConfigField("String", "WS_BASE_URL", "\"wss://slowdate.top/\"")
            buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
            buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
            buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures { buildConfig = true }

    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("libs")
        }
    }

    packaging {
        jniLibs {
            excludes += setOf("**/libVkLayer_khronos_validation.so")
        }
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

androidComponents {
    beforeVariants(selector().all()) { variant ->
        if (isV10100PilotBuild && variant.buildType != "debug") {
            variant.enable = false
        }
    }
}

kotlin {
    jvmToolchain(17)
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.3")
    // XML theme resources like Theme.Material3.DayNight.NoActionBar
    implementation("com.google.android.material:material:1.12.0")

    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    implementation(files("libs/BaiduLBS_Android.jar"))
    implementation("cn.6tail:lunar:1.7.7")
    implementation("com.google.android.gms:play-services-location:21.3.0")
    // Use release AAR for debug installs to reduce APK size and startup/runtime jank.
    debugImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")
    add("profileImplementation", "com.elitesync.flutter_elitesync_module:flutter_profile:1.0")
    releaseImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")
}

configurations.all {
    resolutionStrategy {
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.browser:browser:1.8.0")
    }
}

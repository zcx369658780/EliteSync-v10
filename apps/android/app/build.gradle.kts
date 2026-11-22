import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.File
import java.security.MessageDigest
import java.security.cert.CertificateFactory
import java.security.cert.X509Certificate
import java.util.Base64
import java.util.HexFormat
import java.util.Properties

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
val flutterSourceDebug = providers.gradleProperty("flutterSourceDebug").orNull == "true"
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

val requestedFlutterDartDefines = (
    providers.gradleProperty("flutterDartDefines").orNull
        ?: rootProject.findProperty("flutterDartDefines") as String?
        ?: project.findProperty("flutterDartDefines") as String?
    )
    ?.trim()
    .orEmpty()
val requestedDartDefineValues = requestedFlutterDartDefines.split(Regex("[;,]"))
    .map { it.trim() }.filter { it.isNotEmpty() }
val functionCertificatePath = providers.gradleProperty("elitesyncFunctionCertificate").orNull
val remoteStagingHost = providers.gradleProperty("elitesyncRemoteStagingHost").orNull
val isRemoteStagingBuild = remoteStagingHost != null
val isFunctionCandidateBuild = functionCertificatePath != null || isRemoteStagingBuild
val isFunctionR1CandidateBuild = providers.gradleProperty("elitesyncFunctionR1Candidate").orNull == "true"
val isStagingLoginBuild = providers.gradleProperty("elitesyncStagingLoginCandidate").orNull == "true"
require(!isFunctionR1CandidateBuild || isFunctionCandidateBuild) {
    "The P0.4.2 R1 candidate requires a local certificate or a remote Staging host"
}
require(!isStagingLoginBuild || isFunctionR1CandidateBuild) {
    "The Staging login candidate requires the V2 function R1 build"
}
if (remoteStagingHost != null) {
    val dnsName = Regex("""(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}""")
    require(isFunctionR1CandidateBuild && !isStagingLoginBuild && functionCertificatePath == null
        && remoteStagingHost.length <= 253 && dnsName.matches(remoteStagingHost)
        && remoteStagingHost != "slowdate.top") {
        "Remote Staging requires a dedicated HTTPS DNS hostname and the R1 build"
    }
}
val functionOrigin = when {
    remoteStagingHost != null -> "https://$remoteStagingHost/"
    isStagingLoginBuild -> "https://127.0.0.1:18446/"
    else -> "https://127.0.0.1:18444/"
}
val functionCertificate = functionCertificatePath?.let { path ->
    val file = rootProject.file(path)
    require(file.readText().trim().matches(Regex("-----BEGIN CERTIFICATE-----[\\sA-Za-z0-9+/=]+-----END CERTIFICATE-----"))) {
        "The V2 function build requires one public PEM certificate"
    }
    val certificate = file.inputStream().use {
        CertificateFactory.getInstance("X.509").generateCertificate(it) as X509Certificate
    }
    certificate.checkValidity()
    require(certificate.subjectAlternativeNames.orEmpty().any { it[0] == 7 && it[1] == "127.0.0.1" }) {
        "The certificate must cover the V2 loopback endpoint"
    }
    if (isStagingLoginBuild) {
        val fingerprint = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(certificate.encoded))
        require(fingerprint == "20cb9f36030b22f6b07a726f3070bb3af5edf78cbace658c0904359eeea23b46") {
            "The Staging login candidate requires the verified Staging TLS certificate"
        }
    }
    Base64.getEncoder().encodeToString(certificate.encoded)
}.orEmpty()
require(requestedDartDefineValues.none {
    it.startsWith("ELITESYNC_V2_FUNCTION_BUILD=") || it.startsWith("ELITESYNC_V2_STAGING_LOGIN_BUILD=")
        || it.startsWith("ELITESYNC_V2_REMOTE_STAGING_BUILD=") || it.startsWith("ELITESYNC_REMOTE_STAGING_HOST=")
}) {
    "Use the dedicated V2 build options to set the matching native and Dart configuration"
}
val isV1015LocalBuild = requestedDartDefineValues.contains("ELITESYNC_V1015_LOCAL_BUILD=true")
val isV1017LocalBuild = requestedDartDefineValues.contains("ELITESYNC_V1017_LOCAL_BUILD=true")
val isV1018LocalBuild = requestedDartDefineValues.contains("ELITESYNC_V1018_LOCAL_BUILD=true")
require(!isV1018LocalBuild || isV1017LocalBuild) {
    "v10.1.18 requires the integrated local journeys"
}
require(!isV1017LocalBuild || isV1015LocalBuild) {
    "v10.1.17 requires the existing local restoration runtime"
}
require(!isFunctionCandidateBuild || (isV1018LocalBuild && !flutterSourceDebug &&
    requestedDartDefineValues.none {
        it.startsWith("ELITESYNC_API_BASE_URL=") ||
            it.startsWith("ELITESYNC_WS_BASE_URL=") || it.startsWith("ELITESYNC_SYNTHETIC_DEMO=")
    })) {
    "The V2 function candidate needs the integrated AAR and its fixed HTTPS endpoint"
}
// v10.1.5 continues the accepted v10.1.4 product routes. Carry that Dart gate
// into the new build instead of silently returning to the legacy app entry.
val integratedDartDefines = if (isV1015LocalBuild) {
    require(!requestedDartDefineValues.contains("ELITESYNC_V1014_LOCAL_BUILD=false")) {
        "v10.1.5 requires the accepted v10.1.4 product routes"
    }
    (requestedDartDefineValues + "ELITESYNC_V1014_LOCAL_BUILD=true").distinct().joinToString(";")
} else {
    requestedFlutterDartDefines
}
val flutterDartDefines = if (isFunctionCandidateBuild) {
    "$integratedDartDefines;ELITESYNC_V2_FUNCTION_BUILD=true;" +
        "ELITESYNC_V2_STAGING_LOGIN_BUILD=$isStagingLoginBuild;ELITESYNC_API_BASE_URL=$functionOrigin;" +
        "ELITESYNC_V2_REMOTE_STAGING_BUILD=$isRemoteStagingBuild;ELITESYNC_REMOTE_STAGING_HOST=${remoteStagingHost.orEmpty()}"
} else {
    integratedDartDefines
}
val flutterDartDefineArgs = flutterDartDefines
    .split(Regex("[;,]"))
    .map { it.trim() }
    .filter { it.isNotEmpty() }
    .flatMap { listOf("--dart-define=$it") }
val isRelationshipDevBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_RELATIONSHIP_DEV_BUILD=true")
val isV1006LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .any { it == "ELITESYNC_V1014_LOCAL_BUILD=true" || it == "ELITESYNC_V1013_LOCAL_BUILD=true" || it == "ELITESYNC_V1012_LOCAL_BUILD=true" || it == "ELITESYNC_RELATIONSHIP_DEV_BUILD=true" || it == "ELITESYNC_V1006_LOCAL_BUILD=true" || it == "ELITESYNC_V1007_LOCAL_BUILD=true" || it == "ELITESYNC_V1008_LOCAL_BUILD=true" || it == "ELITESYNC_V1009_LOCAL_BUILD=true" || it == "ELITESYNC_V1010_LOCAL_BUILD=true" || it == "ELITESYNC_V1011_LOCAL_BUILD=true" }
val isV1014LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_V1014_LOCAL_BUILD=true")
val isV1013LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_V1013_LOCAL_BUILD=true")
val isV1012LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1012_LOCAL_BUILD=true")
val isV1011LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1011_LOCAL_BUILD=true")
val isV1010LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1010_LOCAL_BUILD=true")
val isV1009LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .contains("ELITESYNC_V1009_LOCAL_BUILD=true")
val v1009DualDeviceBuild = providers.gradleProperty("v1009DualDeviceBuild").orNull == "true"
val relationshipDualDeviceBuild = providers.gradleProperty("relationshipDualDeviceBuild").orNull == "true"
require(!relationshipDualDeviceBuild || isRelationshipDevBuild || isV1012LocalBuild || isV1013LocalBuild || isV1014LocalBuild) {
    "Relationship dual-device builds require the relationship development gate"
}
val dualDeviceBuild = v1009DualDeviceBuild || relationshipDualDeviceBuild
require(!v1009DualDeviceBuild || isV1009LocalBuild) {
    "Dual-device test builds require the V1009 local restoration gate"
}
val isC2LocalInternalBuild = flutterDartDefines
    .split(Regex("[;,]"))
    .map { it.trim() }
    .contains("ELITESYNC_C2_LOCAL_BUILD=true") || isV1006LocalBuild
val isCiBuild = System.getenv("CI")?.equals("true", ignoreCase = true) == true
val prebuiltFlutterRepo = providers.gradleProperty("elitesyncPrebuiltFlutterRepo").orNull
val candidateBuildDir = providers.gradleProperty("elitesyncCandidateBuildDir").orNull
require((prebuiltFlutterRepo == null && candidateBuildDir == null) || isCiBuild && isFunctionCandidateBuild) {
    "Separate build output is limited to the offline V2 candidate build"
}
candidateBuildDir?.let { layout.buildDirectory.set(file(it)) }
val flutterReleaseAarRepo = File(
    prebuiltFlutterRepo?.let(::File) ?: File(flutterModuleDir, "build/host/outputs/repo"),
    "com/elitesync/flutter_elitesync_module/flutter_release/1.0",
)

val syncFlutterAar by tasks.registering(Exec::class) {
    group = "build"
    description = "Build latest Flutter module AAR before Android preBuild"
    workingDir = flutterModuleDir
    onlyIf {
        if (flutterSourceDebug) {
            false
        } else if (isCiBuild && flutterReleaseAarRepo.exists()) {
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
        ) + (if (dualDeviceBuild) listOf("--target-platform=android-x64,android-arm64")
            else if (isV1015LocalBuild) listOf("--target-platform=android-arm64")
            else if (isV1006LocalBuild) listOf("--target-platform=android-x64") else emptyList()) + flutterDartDefineArgs
    )
    inputs.dir(File(flutterModuleDir, "lib"))
    inputs.file(File(flutterModuleDir, "pubspec.yaml"))
    inputs.property("flutterDartDefines", flutterDartDefines)
    inputs.property("v1009DualDeviceBuild", v1009DualDeviceBuild)
    inputs.property("relationshipDualDeviceBuild", relationshipDualDeviceBuild)
    outputs.dir(flutterReleaseAarRepo)
}

tasks.named("preBuild") {
    if (!flutterSourceDebug) dependsOn(syncFlutterAar)
}

android {
    // Match the existing source-debug module toolchain instead of fetching the AGP default.
    if (flutterSourceDebug) ndkVersion = "28.2.13676358"
    namespace = "com.elitesync"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.elitesync"
        buildConfigField("boolean", "ELITESYNC_SYNTHETIC_DEMO", "false")
        buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", "false")
        buildConfigField("boolean", "ELITESYNC_V1015_LOCAL_BUILD", "false")
        buildConfigField("boolean", "ELITESYNC_V2_FUNCTION_BUILD", "false")
        buildConfigField("boolean", "ELITESYNC_V2_STAGING_LOGIN_BUILD", "false")
        buildConfigField("boolean", "ELITESYNC_V2_REMOTE_STAGING_BUILD", "false")
        buildConfigField("String", "ELITESYNC_V2_FUNCTION_CERTIFICATE", "\"\"")
        minSdk = 26
        targetSdk = 35
        // Versioning rule: major.minor.patch[alpha suffix]
        // versionCode uses an expanded numeric form to keep suffix releases ordered.
        versionCode = if (isFunctionR1CandidateBuild) 1011807 else if (isFunctionCandidateBuild) 1011806 else if (isV1018LocalBuild) 1011804 else if (isV1017LocalBuild) 1011703 else if (isV1015LocalBuild) 1011601 else if (isV1014LocalBuild) 1010401 else if (isV1013LocalBuild) 1010301 else if (isV1012LocalBuild) 1010201 else if (isRelationshipDevBuild) 1010101 else 80400
        versionName = if (isFunctionR1CandidateBuild) "10.1.18-v2-function-p042-r1" else if (isFunctionCandidateBuild) "10.1.18-v2-function-p04" else if (isV1018LocalBuild) "10.1.18-dev" else if (isV1017LocalBuild) "10.1.17-dev" else if (isV1015LocalBuild) "10.1.16-dev" else if (isV1014LocalBuild) "10.1.4-dev" else if (isV1013LocalBuild) "10.1.3-dev" else if (isV1012LocalBuild) "10.1.2-dev" else if (isRelationshipDevBuild) "10.1.1-dev" else "0.08.04"
        if (isStagingLoginBuild) {
            versionCode = 1011808
            versionName = "10.1.18-v2-staging-login"
        }
        if (isRemoteStagingBuild) {
            versionCode = 1011809
            versionName = "10.1.18-v2-remote-staging"
        }
        manifestPlaceholders["appLabel"] = when {
            isRemoteStagingBuild -> "EliteSync Remote Staging"
            isStagingLoginBuild -> "EliteSync Staging"
            else -> "EliteSync"
        }
        manifestPlaceholders["allowAppBackup"] = (!isStagingLoginBuild && !isRemoteStagingBuild).toString()
        manifestPlaceholders["flutterPlatformDeepLinks"] = if (isFunctionCandidateBuild) "false" else "true"
        ndk {
            // Google Play 16KB page-size compliance: avoid x86_64 native libs from third-party SDKs.
            // Keep ARM ABIs for real-device testing and release publishing.
            abiFilters += if (dualDeviceBuild) {
                listOf("x86_64", "arm64-v8a")
            } else if (isV1015LocalBuild) {
                listOf("arm64-v8a")
            } else if (isC2LocalInternalBuild) {
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
            if (isRelationshipDevBuild) { applicationIdSuffix = ".v10x.relationshipdev" }
            if (isV1013LocalBuild) { applicationIdSuffix = ".v1013dev" }
            if (isV1014LocalBuild) { applicationIdSuffix = ".v1014dev" }
            if (isV1012LocalBuild) { applicationIdSuffix = ".v1012dev" }
            if (isFunctionCandidateBuild) {
                applicationIdSuffix = when {
                    isRemoteStagingBuild -> ".v2stagingremote"
                    isStagingLoginBuild -> ".v2staginglogin"
                    isFunctionR1CandidateBuild -> ".v2functionp042r1"
                    else -> ".v2functionp04"
                }
            } else if (isV1018LocalBuild) { applicationIdSuffix = ".v1018dev" }
            else if (isV1017LocalBuild) { applicationIdSuffix = ".v1017dev" }
            else if (isV1015LocalBuild) { applicationIdSuffix = ".v1015dev" }
            buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", isV1006LocalBuild.toString())
            buildConfigField("boolean", "ELITESYNC_V1015_LOCAL_BUILD", isV1015LocalBuild.toString())
            buildConfigField("String", "API_BASE_URL", if (isV1015LocalBuild) "\"http://127.0.0.1:8021/\"" else if (isV1014LocalBuild) "\"http://127.0.0.1:8019/\"" else if (isV1013LocalBuild) "\"http://127.0.0.1:8017/\"" else if (isV1012LocalBuild) "\"http://127.0.0.1:8015/\"" else if (isRelationshipDevBuild) "\"http://127.0.0.1:8012/\"" else if (isV1011LocalBuild) "\"http://127.0.0.1:8011/\"" else if (isV1010LocalBuild) "\"http://127.0.0.1:8010/\"" else if (isV1006LocalBuild) "\"http://127.0.0.1:8000/\"" else "\"https://slowdate.top/\"")
            buildConfigField("String", "WS_BASE_URL", if (isV1015LocalBuild) "\"ws://127.0.0.1:8022/\"" else if (isV1014LocalBuild) "\"ws://127.0.0.1:8020/\"" else if (isV1013LocalBuild) "\"ws://127.0.0.1:8018/\"" else if (isV1012LocalBuild) "\"ws://127.0.0.1:8016/\"" else if (isRelationshipDevBuild) "\"ws://127.0.0.1:8013/\"" else if (isV1006LocalBuild) "\"\"" else "\"wss://slowdate.top/\"")
            if (isFunctionCandidateBuild) {
                if (isStagingLoginBuild || isRemoteStagingBuild) isDebuggable = false
                buildConfigField("boolean", "ELITESYNC_V2_FUNCTION_BUILD", "true")
                buildConfigField("boolean", "ELITESYNC_V2_STAGING_LOGIN_BUILD", isStagingLoginBuild.toString())
                buildConfigField("boolean", "ELITESYNC_V2_REMOTE_STAGING_BUILD", isRemoteStagingBuild.toString())
                buildConfigField("String", "ELITESYNC_V2_FUNCTION_CERTIFICATE", "\"$functionCertificate\"")
                buildConfigField("String", "API_BASE_URL", "\"$functionOrigin\"")
                buildConfigField("String", "WS_BASE_URL", "\"\"")
            }
            buildConfigField("String", "BAIDU_MAP_AK", "\"$baiduAkFromProp\"")
            buildConfigField("String", "BAIDU_MAP_SECURITY_CODE", "\"$baiduSecurityCodeFromProp\"")
            buildConfigField("boolean", "ENABLE_BAIDU_NATIVE_SDK", "false")
        }
        create("profile") {
            initWith(getByName("debug"))
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
    beforeVariants(selector().all()) {
        if (isFunctionCandidateBuild && it.buildType != "debug") it.enable = false
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
    if (flutterSourceDebug) {
        implementation(project(":flutter"))
    } else {
        // Use release AAR for debug installs to reduce APK size and startup/runtime jank.
        debugImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")
        add("profileImplementation", "com.elitesync.flutter_elitesync_module:flutter_profile:1.0")
        releaseImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")
    }
}

configurations.all {
    resolutionStrategy {
        if (isFunctionCandidateBuild) {
            // Activity 1.12 already contains the formerly KTX-only classes.
            force("androidx.activity:activity-ktx:1.12.4")
        }
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
        force("androidx.browser:browser:1.8.0")
    }
}

import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.File
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
val isRelationshipDevBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_RELATIONSHIP_DEV_BUILD=true")
val isV1006LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }
    .any { it == "ELITESYNC_V1015_LOCAL_BUILD=true" || it == "ELITESYNC_V1014_LOCAL_BUILD=true" || it == "ELITESYNC_V1013_LOCAL_BUILD=true" || it == "ELITESYNC_V1012_LOCAL_BUILD=true" || it == "ELITESYNC_RELATIONSHIP_DEV_BUILD=true" || it == "ELITESYNC_V1006_LOCAL_BUILD=true" || it == "ELITESYNC_V1007_LOCAL_BUILD=true" || it == "ELITESYNC_V1008_LOCAL_BUILD=true" || it == "ELITESYNC_V1009_LOCAL_BUILD=true" || it == "ELITESYNC_V1010_LOCAL_BUILD=true" || it == "ELITESYNC_V1011_LOCAL_BUILD=true" }
val isV1015LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_V1015_LOCAL_BUILD=true")
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
require(!relationshipDualDeviceBuild || isRelationshipDevBuild || isV1012LocalBuild || isV1013LocalBuild || isV1014LocalBuild || isV1015LocalBuild) {
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
val flutterReleaseAarRepo =
    File(flutterModuleDir, "build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0")
val isCiBuild = System.getenv("CI")?.equals("true", ignoreCase = true) == true

val syncFlutterAar by tasks.registering(Exec::class) {
    group = "build"
    description = "Build latest Flutter module AAR before Android preBuild"
    workingDir = flutterModuleDir
    onlyIf {
        if (isCiBuild && flutterReleaseAarRepo.exists()) {
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
    dependsOn(syncFlutterAar)
}

android {
    namespace = "com.elitesync"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.elitesync"
        buildConfigField("boolean", "ELITESYNC_SYNTHETIC_DEMO", "false")
        buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", "false")
        minSdk = 26
        targetSdk = 35
        // Versioning rule: major.minor.patch[alpha suffix]
        // versionCode uses an expanded numeric form to keep suffix releases ordered.
        versionCode = if (isV1015LocalBuild) 1010501 else if (isV1014LocalBuild) 1010401 else if (isV1013LocalBuild) 1010301 else if (isV1012LocalBuild) 1010201 else if (isRelationshipDevBuild) 1010101 else 80400
        versionName = if (isV1015LocalBuild) "10.1.5-dev" else if (isV1014LocalBuild) "10.1.4-dev" else if (isV1013LocalBuild) "10.1.3-dev" else if (isV1012LocalBuild) "10.1.2-dev" else if (isRelationshipDevBuild) "10.1.1-dev" else "0.08.04"
        ndk {
            // Google Play 16KB page-size compliance: avoid x86_64 native libs from third-party SDKs.
            // Keep ARM ABIs for real-device testing and release publishing.
            abiFilters += if (dualDeviceBuild) {
                listOf("x86_64", "arm64-v8a")
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
            if (isV1015LocalBuild) { applicationIdSuffix = ".v1015dev" }
            if (isV1014LocalBuild) { applicationIdSuffix = ".v1014dev" }
            if (isV1012LocalBuild) { applicationIdSuffix = ".v1012dev" }
            buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", isV1006LocalBuild.toString())
            buildConfigField("String", "API_BASE_URL", if (isV1015LocalBuild) "\"http://127.0.0.1:8021/\"" else if (isV1014LocalBuild) "\"http://127.0.0.1:8019/\"" else if (isV1013LocalBuild) "\"http://127.0.0.1:8017/\"" else if (isV1012LocalBuild) "\"http://127.0.0.1:8015/\"" else if (isRelationshipDevBuild) "\"http://127.0.0.1:8012/\"" else if (isV1011LocalBuild) "\"http://127.0.0.1:8011/\"" else if (isV1010LocalBuild) "\"http://127.0.0.1:8010/\"" else if (isV1006LocalBuild) "\"http://127.0.0.1:8000/\"" else "\"http://101.133.161.203/\"")
            buildConfigField("String", "WS_BASE_URL", if (isV1015LocalBuild) "\"ws://127.0.0.1:8022/\"" else if (isV1014LocalBuild) "\"ws://127.0.0.1:8020/\"" else if (isV1013LocalBuild) "\"ws://127.0.0.1:8018/\"" else if (isV1012LocalBuild) "\"ws://127.0.0.1:8016/\"" else if (isRelationshipDevBuild) "\"ws://127.0.0.1:8013/\"" else if (isV1006LocalBuild) "\"\"" else "\"ws://101.133.161.203:8081/\"")
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

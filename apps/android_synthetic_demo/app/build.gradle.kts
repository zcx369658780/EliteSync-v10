// SOURCE-ONLY: settings unconditionally refuses all Gradle calls.
// No artifact dependency can be admitted until a new receipt/isolation gate.
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.elitesync.syntheticdemo"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.elitesync.syntheticdemo"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.1-source-only"
        buildConfigField("boolean", "ELITESYNC_SYNTHETIC_DEMO", "true")
        buildConfigField("String", "API_BASE_URL", "\"http://127.0.0.1:8080/\"")
        buildConfigField("String", "WS_BASE_URL", "\"ws://127.0.0.1:8080/\"")
    }
    buildFeatures { buildConfig = true }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

androidComponents {
    beforeVariants(selector().all()) { variant ->
        if (variant.buildType != "debug") {
            variant.enable = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

// FUTURE receipt interface: inputManifestSha256, toolIdentities, target,
// mode, dartDefines, hostSynthetic, aarSha256, originalGav, isolatedGav,
// pomSha256, dependencyClosure, isolationEvidence, mergedManifestSha256.
// No GAV, AAR hash, or dependency is admitted in this scaffold.

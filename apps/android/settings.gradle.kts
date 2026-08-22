pluginManagement {
    resolutionStrategy {
        eachPlugin {
            when (requested.id.id) {
                "com.android.application", "com.android.library" ->
                    useModule("com.android.tools.build:gradle:${requested.version}")
                "org.jetbrains.kotlin.android" ->
                    useModule("org.jetbrains.kotlin:kotlin-gradle-plugin:${requested.version}")
            }
        }
    }
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        val localWindowsMaven = java.io.File("D:/EliteSync/gradle-local-m2")
        val osName = System.getProperty("os.name").lowercase()
        if (osName.contains("windows") && localWindowsMaven.exists()) {
            maven(url = localWindowsMaven.toURI()) {
                metadataSources {
                    mavenPom()
                    artifact()
                }
            }
        }
        maven(url = "https://maven.aliyun.com/repository/gradle-plugin")
        maven(url = "https://maven.aliyun.com/repository/google")
        maven(url = "https://maven.aliyun.com/repository/public")
    }
}

dependencyResolutionManagement {
    // Flutter module Gradle plugin adds transient repositories during module integration.
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven(url = uri("../flutter_elitesync_module/build/host/outputs/repo"))

        val flutterStorageBaseUrl =
            System.getenv("FLUTTER_STORAGE_BASE_URL")
                ?.trim()
                ?.takeIf { it.isNotEmpty() }
                ?: "https://storage.flutter-io.cn"
        maven(url = uri("$flutterStorageBaseUrl/download.flutter.io")) {
            content {
                includeGroup("io.flutter")
            }
        }

        // Required for com.github.* dependencies such as audioswitch.
        maven(url = "https://jitpack.io")

        val localWindowsMaven = java.io.File("D:/EliteSync/gradle-local-m2")
        val osName = System.getProperty("os.name").lowercase()
        if (osName.contains("windows") && localWindowsMaven.exists()) {
            maven(url = localWindowsMaven.toURI()) {
                metadataSources {
                    mavenPom()
                    artifact()
                }
            }
        }
        maven(url = "https://maven.aliyun.com/repository/google") {
            content {
                excludeGroup("io.flutter")
            }
        }
        maven(url = "https://maven.aliyun.com/repository/public") {
            content {
                excludeGroup("io.flutter")
            }
        }
        maven(url = "https://maven.aliyun.com/repository/releases") {
            content {
                excludeGroup("io.flutter")
            }
        }
    }
}
rootProject.name = "EliteSyncAndroid"
include(":app")

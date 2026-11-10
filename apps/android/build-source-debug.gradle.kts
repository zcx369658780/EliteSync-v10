plugins {
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    // Export Flutter's types to native plugin scripts without applying it here.
    id("dev.flutter.flutter-gradle-plugin") apply false
}

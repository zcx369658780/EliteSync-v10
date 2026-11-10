pluginManagement {
    throw GradleException("SOURCE_SCAFFOLD_NOT_READY: v1 refuses all Gradle calls before plugin resolution")
}

rootProject.name = "EliteSyncSyntheticDemo"
include(":app")

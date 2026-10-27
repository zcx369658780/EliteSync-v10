import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.File
import java.util.Properties
import java.util.Base64
import java.security.MessageDigest
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.LinkOption
import java.nio.file.attribute.BasicFileAttributes

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

// ICE_DIAG_GRADLE_GUARD_BEGIN: read-only tooling validation, also fixture-tested.
fun validateIceDiagnosticGradle(
    binProperty: String?, homeProperty: String?, taskRootProperty: String?, trustedRootProperty: String?,
    approvedContainer: File, projectRoot: File, moduleRoot: File, flutterRoot: File?,
    activeHome: File, outerDistribution: File?, homeEnvironment: String?,
    flutterEnvironment: String?, flutterHomeEnvironment: String?, outerVersion: String,
    outerOffline: Boolean, osName: String,
): Pair<File, File> {
    fun rejectUnless(ok: Boolean, reason: String) {
        require(ok) { "ICE_DIAG_GRADLE_GUARD_REJECTED: $reason" }
    }
    rejectUnless(osName.startsWith("Windows", ignoreCase = true), "Windows tooling only")
    rejectUnless(outerVersion == "8.14", "Gradle version must be 8.14")
    rejectUnless(outerOffline, "diagnostic Gradle must be offline")
    listOf("iceDiagGradleBin" to binProperty, "iceDiagGradleUserHome" to homeProperty,
        "iceDiagTaskRoot" to taskRootProperty, "iceDiagTrustedGradleRoot" to trustedRootProperty).forEach { (name, value) ->
        rejectUnless(!value.isNullOrBlank(), "missing $name")
        val path = File(value!!).toPath()
        rejectUnless(path.isAbsolute && path == path.normalize(), "absolute canonical property required: $name")
    }
    fun checkedPath(file: File, label: String): File {
        rejectUnless(file.isAbsolute && file.exists(), "missing absolute path: $label")
        val path = file.toPath().normalize()
        var cursor: Path? = path
        while (cursor != null) {
            rejectUnless(!Files.isSymbolicLink(cursor), "symbolic link forbidden: $label")
            cursor = cursor.parent
        }
        rejectUnless(path.toRealPath() == path, "redirected or noncanonical path: $label")
        return path.toFile()
    }
    val expectedRoot = File(approvedContainer, "build-run").absoluteFile
    val taskRoot = File(taskRootProperty!!)
    rejectUnless(taskRoot == expectedRoot, "unapproved task root")
    checkedPath(approvedContainer.absoluteFile, "approved container")
    checkedPath(taskRoot, "task root")
    val trusted = File(trustedRootProperty!!)
    rejectUnless(trusted == File(taskRoot, "trusted-tools/gradle-8.14"), "unapproved trusted distribution")
    checkedPath(trusted, "trusted distribution")
    val expectedBin = File(trusted, "bin/gradle.bat")
    val expectedHome = File(taskRoot, "gradle-user-home")
    rejectUnless(File(binProperty!!) == expectedBin, "unapproved Gradle location or Wrapper alias")
    checkedPath(expectedBin, "Gradle bin")
    rejectUnless(File(homeProperty!!) == expectedHome, "unapproved isolated home")
    checkedPath(expectedHome, "Gradle user home")
    fun normalized(file: File) = file.toPath().normalize().toFile()
    rejectUnless(activeHome.isAbsolute && normalized(activeHome) == expectedHome &&
        !homeEnvironment.isNullOrBlank() && File(homeEnvironment!!) == expectedHome,
        "Gradle home and environment disagree")
    checkedPath(activeHome, "active home")
    checkedPath(File(homeEnvironment!!), "home environment")
    rejectUnless(outerDistribution != null && outerDistribution!!.isAbsolute && normalized(outerDistribution) == trusted,
        "outer Gradle distribution mismatch")
    checkedPath(outerDistribution!!, "outer distribution")
    rejectUnless(projectRoot.isAbsolute && normalized(projectRoot) == File(taskRoot, "project/apps/android") &&
        moduleRoot.isAbsolute && normalized(moduleRoot) == File(taskRoot, "project/apps/flutter_elitesync_module/.android"),
        "project and module must belong to the approved task root")
    checkedPath(projectRoot, "Android project")
    checkedPath(moduleRoot, "Flutter module")
    val expectedFlutter = File(taskRoot, "sdk-stage/flutter")
    rejectUnless(flutterRoot != null && flutterRoot!!.isAbsolute && normalized(flutterRoot) == expectedFlutter &&
        !flutterEnvironment.isNullOrBlank() && File(flutterEnvironment!!) == expectedFlutter &&
        !flutterHomeEnvironment.isNullOrBlank() && File(flutterHomeEnvironment!!) == expectedFlutter,
        "Flutter SDK and environment disagree")
    checkedPath(flutterRoot!!, "Flutter SDK")
    checkedPath(File(flutterEnvironment!!), "FLUTTER_ROOT")
    checkedPath(File(flutterHomeEnvironment!!), "FLUTTER_HOME")
    val pinned = mapOf(
        "bin/gradle.bat" to "af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab",
        "lib/gradle-gradle-cli-main-8.14.jar" to "3e21380f278d069ec1fc706b1a3b075250a00d6366dccc1fcf343838a494f20b",
        "lib/gradle-core-8.14.jar" to "36ee23fbf4082131bbf8758603a7a2019be60f47bc033b283447e107c578427d",
    )
    pinned.forEach { (relative, expected) ->
        val file = checkedPath(File(trusted, relative), "pinned Gradle component")
        rejectUnless(file.isFile, "pinned Gradle component missing")
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().buffered().use { input ->
            val buffer = ByteArray(1024 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                digest.update(buffer, 0, count)
            }
        }
        rejectUnless(digest.digest().joinToString("") { "%02x".format(it) } == expected,
            "pinned Gradle component hash mismatch")
    }
    return expectedBin to expectedHome
}
// ICE_DIAG_GRADLE_GUARD_END

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
val isV1015R1LocalBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_V1015_R1_LOCAL_BUILD=true")
val isV1015R1RetentionProbe = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_V1015_R1_RETENTION_PROBE=true")
val isIceDiagnosticBuild = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.contains("ELITESYNC_ICE_DIAG_TEST_ONLY=true")
val diagnosticFlags = setOf("ELITESYNC_ICE_DIAG_TEST_ONLY=true", "ELITESYNC_V1015_LOCAL_BUILD=true", "ELITESYNC_V1015_R1_LOCAL_BUILD=true")
require(!isIceDiagnosticBuild || flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.filter { it.isNotEmpty() }.all { it in diagnosticFlags }) {
    "ICE_DIAG_GUARD_REJECTED: conflicting or unknown diagnostic build flags"
}
require(!isIceDiagnosticBuild || (isV1015R1LocalBuild && isV1015LocalBuild && !isV1015R1RetentionProbe &&
    gradle.startParameter.taskNames.isNotEmpty() && gradle.startParameter.taskNames.all {
        it.contains("debug", ignoreCase = true) && !it.contains("release", ignoreCase = true) && !it.contains("profile", ignoreCase = true)
    })) { "ICE_DIAG_GUARD_REJECTED: explicit isolated local R1 debug tasks only" }
val iceDiagnosticTooling = if (isIceDiagnosticBuild) validateIceDiagnosticGradle(
    providers.gradleProperty("iceDiagGradleBin").orNull,
    providers.gradleProperty("iceDiagGradleUserHome").orNull,
    providers.gradleProperty("iceDiagTaskRoot").orNull,
    providers.gradleProperty("iceDiagTrustedGradleRoot").orNull,
    File(System.getProperty("user.home"), ".codex/v1015-pinned-arch-debug-build-env-20261023"),
    rootProject.projectDir, File(flutterModuleDir, ".android"), flutterSdkPath?.let { File(it) },
    gradle.gradleUserHomeDir, gradle.gradleHomeDir, System.getenv("GRADLE_USER_HOME"),
    System.getenv("FLUTTER_ROOT"), System.getenv("FLUTTER_HOME"),
    org.gradle.util.GradleVersion.current().version, gradle.startParameter.isOffline, System.getProperty("os.name"),
) else null
require(!isV1015R1LocalBuild || isV1015LocalBuild) { "R1 requires the existing v10.1.5 local build gate" }
require(!isV1015R1RetentionProbe || isV1015R1LocalBuild) { "Retention probe requires the isolated R1 build" }
require(!isV1015R1RetentionProbe || gradle.startParameter.taskNames.all { it.contains("debug", ignoreCase = true) }) {
    "The retention test entry may only be packaged by explicit debug tasks"
}
// Ordinary local debug builds use the same verified distribution at both levels.
// --offline is a resolver option; it cannot constrain Wrapper bootstrap.
val localOfflineGradleBin = providers.gradleProperty("localOfflineGradleBin").orNull?.let { path ->
    require(isV1015R1LocalBuild && !isIceDiagnosticBuild && !isV1015R1RetentionProbe) {
        "OFFLINE_DEBUG_REJECTED: ordinary R1 debug only"
    }
    require(gradle.startParameter.isOffline && org.gradle.util.GradleVersion.current().version == "8.14") {
        "OFFLINE_DEBUG_REJECTED: offline Gradle 8.14 required"
    }
    val bin = File(path)
    val home = gradle.gradleHomeDir ?: error("OFFLINE_DEBUG_REJECTED: no distribution")
    require(bin.isAbsolute && bin.isFile && bin.canonicalFile == File(home, "bin/gradle.bat").canonicalFile) {
        "OFFLINE_DEBUG_REJECTED: explicit local binary must match active distribution"
    }
    val pinned = mapOf(
        "bin/gradle.bat" to "af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab",
        "lib/gradle-gradle-cli-main-8.14.jar" to "3e21380f278d069ec1fc706b1a3b075250a00d6366dccc1fcf343838a494f20b",
        "lib/gradle-core-8.14.jar" to "36ee23fbf4082131bbf8758603a7a2019be60f47bc033b283447e107c578427d",
    )
    pinned.forEach { (relative, expected) ->
        val file = File(home, relative)
        require(file.isFile && MessageDigest.getInstance("SHA-256").digest(file.readBytes())
            .joinToString("") { "%02x".format(it) } == expected) { "OFFLINE_DEBUG_REJECTED: runtime hash $relative" }
    }
    bin
}
require(!isV1015R1LocalBuild || isIceDiagnosticBuild || localOfflineGradleBin != null) {
    "OFFLINE_DEBUG_REJECTED: use scripts/offline_debug.py; no Wrapper fallback"
}
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
val r1Digest = MessageDigest.getInstance("SHA-256").apply {
    update(flutterDartDefines.toByteArray(Charsets.UTF_8))
    fileTree(flutterModuleDir).matching {
        include("lib/**/*.dart", "pubspec.yaml", "pubspec.lock", "third_party/livekit_client/**")
    }.files.sortedBy { it.relativeTo(flutterModuleDir).invariantSeparatorsPath }.forEach {
        update(it.relativeTo(flutterModuleDir).invariantSeparatorsPath.toByteArray(Charsets.UTF_8))
        update(it.readBytes())
    }
}.digest().joinToString("") { "%02x".format(it) }.take(12)
val r1AarVersion = if (isIceDiagnosticBuild) "1.0-icediag-$r1Digest" else if (isV1015R1RetentionProbe) "1.0-r1probe-$r1Digest" else "1.0-v1015r1-$r1Digest"
val r1AarOutput = File(flutterModuleDir, if (isIceDiagnosticBuild) "build/host/ice-diagnostic/outputs" else if (isV1015R1RetentionProbe)
    "build/host/r1-retention-probe/outputs" else "build/host/v1015-r1/outputs")

// OWNED_R1_AAR_INIT_BEGIN: fixed project copy; no generation or fallback here.
fun validateOwnedRuntimeAarInit(projectRoot: File, flutterRoot: File): File {
    fun checkedFile(root: File, relative: String): File {
        val base = root.toPath().toAbsolutePath()
        val candidate = root.resolve(relative).toPath().toAbsolutePath()
        require(base.none { it.toString() == ".." } && candidate.none { it.toString() == ".." } &&
            candidate.normalize().startsWith(base.normalize()) && Files.isRegularFile(candidate)) {
            "OWNED_AAR_INIT_REJECTED: missing or escaped input"
        }
        var current: Path? = candidate
        while (current != null) {
            val item = current
            require(!Files.isSymbolicLink(item) &&
                !Files.readAttributes(item, BasicFileAttributes::class.java, LinkOption.NOFOLLOW_LINKS).isOther) {
                "OWNED_AAR_INIT_REJECTED: redirected input"
            }
            current = item.parent
        }
        require(candidate.toRealPath() == candidate.normalize()) { "OWNED_AAR_INIT_REJECTED: redirected path" }
        return candidate.toFile()
    }
    fun pinned(root: File, relative: String, expected: String): File {
        val file = checkedFile(root, relative)
        require(MessageDigest.getInstance("SHA-256").digest(file.readBytes())
            .joinToString("") { "%02x".format(it) } == expected) { "OWNED_AAR_INIT_REJECTED: input hash $relative" }
        return file
    }
    pinned(flutterRoot, "packages/flutter_tools/gradle/aar_init_script.gradle",
        "b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2")
    pinned(flutterRoot, "LICENSE", "a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9")
    val directory = "scripts/owned_flutter_aar_init/"
    pinned(projectRoot, directory + "FLUTTER_LICENSE", "a3a9fd82f800a47377f7d3f60c60a5c91cae0495be8f329031e1448ce0f5dab9")
    pinned(projectRoot, directory + "SOURCE.json", "0f14efe7ed1a2d84be53f2a76a70a343a8bece8dc42f34b368c637c9b17a5f51")
    pinned(projectRoot, directory + "UPSTREAM.patch", "d07b565e23003351d1f9d92df9f50183d8d095b86de026784de1e1267c53b947")
    return pinned(projectRoot, directory + "aar_runtime.init.gradle",
        "364295d4d861d81ca3113d25acf6e45dd422ebce64b412ef9baf20e02d32c48d")
}
// OWNED_R1_AAR_INIT_END

val syncFlutterAar by tasks.registering(Exec::class) {
    group = "build"
    description = "Build latest Flutter module AAR before Android preBuild"
    workingDir = flutterModuleDir
    // Do not trust a CI cache solely because an AAR directory exists. Gradle's
    // declared inputs/outputs decide reuse, including the exact entry defines.
    if (isV1015R1LocalBuild) {
        // Flutter's build-aar CLI fixes lib/main.dart. Use its existing Gradle
        // AAR task with an explicit test target; production main stays untouched.
        require(!flutterSdkPath.isNullOrBlank()) { "Probe requires the installed Flutter SDK" }
        workingDir = File(flutterModuleDir, ".android")
        val aarGradle = if (isIceDiagnosticBuild) iceDiagnosticTooling!!.first.absolutePath else
            localOfflineGradleBin!!.absolutePath
        val encodedDefines = flutterDartDefines.split(Regex("[;,]")).map { it.trim() }.filter { it.isNotEmpty() }
            .joinToString(",") { Base64.getEncoder().encodeToString(it.toByteArray(Charsets.UTF_8)) }
        val ordinaryR1Runtime = isV1015R1LocalBuild && !isIceDiagnosticBuild && !isV1015R1RetentionProbe
        val aarInit = if (ordinaryR1Runtime) validateOwnedRuntimeAarInit(rootProject.projectDir, File(flutterSdkPath))
            else File(flutterSdkPath, "packages/flutter_tools/gradle/aar_init_script.gradle")
        if (ordinaryR1Runtime) {
            inputs.files(aarInit, rootProject.file("scripts/owned_flutter_aar_init/FLUTTER_LICENSE"),
                rootProject.file("scripts/owned_flutter_aar_init/SOURCE.json"),
                rootProject.file("scripts/owned_flutter_aar_init/UPSTREAM.patch"))
            inputs.property("ownedRuntimeAarInitScope", "v10.1.5-ordinary-r1-runtime")
        }
        if (!isIceDiagnosticBuild) logger.lifecycle("OFFLINE_DEBUG_INNER_DIRECT_GRADLE version=8.14 wrapper=false")
        commandLine(listOf(aarGradle,
            "-I=${aarInit.absolutePath}",
            *if (!isIceDiagnosticBuild) arrayOf("-I=${rootProject.file("scripts/offline_debug.init.gradle").absolutePath}") else emptyArray(),
            "-Pflutter-root=$flutterSdkPath", "-Poutput-dir=${r1AarOutput.parentFile.absolutePath}",
            "-Pis-plugin=false", "-PbuildNumber=$r1AarVersion",
            "-Ptarget=${if (isIceDiagnosticBuild) "lib/dev/v1015_ice_diag.dart" else if (isV1015R1RetentionProbe) "lib/dev/v1015_r1_retention_probe.dart" else "lib/main.dart"}",
            "-Pdart-defines=$encodedDefines", "-Ptarget-platform=android-x64,android-arm64",
            if (isIceDiagnosticBuild) "assembleAarDebug" else "assembleAarRelease", "--offline", "--console=plain") +
            (if (ordinaryR1Runtime) listOf("-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime") else emptyList()) +
            if (isIceDiagnosticBuild) listOf("--no-daemon", "--gradle-user-home", iceDiagnosticTooling!!.second.absolutePath) else
                listOf("--no-daemon", "--max-workers=2", "--gradle-user-home", gradle.gradleUserHomeDir.absolutePath,
                    "-Dorg.gradle.java.installations.auto-download=false", "-Porg.gradle.java.installations.auto-download=false",
                    "-Porg.gradle.java.installations.auto-detect=false"))
    } else commandLine(
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
    inputs.file(File(flutterModuleDir, "pubspec.lock"))
    inputs.dir(File(flutterModuleDir, "third_party/livekit_client"))
    inputs.property("flutterDartDefines", flutterDartDefines)
    inputs.property("v1009DualDeviceBuild", v1009DualDeviceBuild)
    inputs.property("relationshipDualDeviceBuild", relationshipDualDeviceBuild)
    if (isIceDiagnosticBuild) {
        environment("GRADLE_USER_HOME", iceDiagnosticTooling!!.second.absolutePath)
        inputs.property("iceDiagGradleBin", iceDiagnosticTooling!!.first.absolutePath)
        inputs.property("iceDiagGradleUserHome", iceDiagnosticTooling!!.second.absolutePath)
        inputs.property("iceDiagTaskRoot", providers.gradleProperty("iceDiagTaskRoot").get())
        inputs.property("iceDiagTrustedGradleRoot", providers.gradleProperty("iceDiagTrustedGradleRoot").get())
    }
    outputs.dir(if (isV1015R1LocalBuild) File(r1AarOutput,
        "repo/com/elitesync/flutter_elitesync_module/${if (isIceDiagnosticBuild) "flutter_debug" else "flutter_release"}/$r1AarVersion") else flutterReleaseAarRepo)
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
        buildConfigField("boolean", "ELITESYNC_ICE_DIAG_TEST_ONLY", "false")
        minSdk = 26
        targetSdk = 35
        // Versioning rule: major.minor.patch[alpha suffix]
        // versionCode uses an expanded numeric form to keep suffix releases ordered.
        versionCode = if (isV1015R1LocalBuild) 1010511 else if (isV1015LocalBuild) 1010501 else if (isV1014LocalBuild) 1010401 else if (isV1013LocalBuild) 1010301 else if (isV1012LocalBuild) 1010201 else if (isRelationshipDevBuild) 1010101 else 80400
        versionName = if (isIceDiagnosticBuild) "10.1.5-ice-diag-test" else if (isV1015R1RetentionProbe) "10.1.5-r1-retention-test" else if (isV1015R1LocalBuild) "10.1.5-r1-dev" else if (isV1015LocalBuild) "10.1.5-dev" else if (isV1014LocalBuild) "10.1.4-dev" else if (isV1013LocalBuild) "10.1.3-dev" else if (isV1012LocalBuild) "10.1.2-dev" else if (isRelationshipDevBuild) "10.1.1-dev" else "0.08.04"
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
            if (isV1015R1LocalBuild) { applicationIdSuffix = ".v1015r1dev" }
            if (isV1015R1RetentionProbe) { applicationIdSuffix = ".v1015r1probe" }
            if (isV1014LocalBuild) { applicationIdSuffix = ".v1014dev" }
            if (isV1012LocalBuild) { applicationIdSuffix = ".v1012dev" }
            if (isIceDiagnosticBuild) { applicationIdSuffix = ".v1015icediag" }
            buildConfigField("boolean", "ELITESYNC_V1006_LOCAL_BUILD", isV1006LocalBuild.toString())
            buildConfigField("boolean", "ELITESYNC_ICE_DIAG_TEST_ONLY", isIceDiagnosticBuild.toString())
            buildConfigField("String", "API_BASE_URL", if (isV1015R1LocalBuild) "\"http://127.0.0.1:8031/\"" else if (isV1015LocalBuild) "\"http://127.0.0.1:8021/\"" else if (isV1014LocalBuild) "\"http://127.0.0.1:8019/\"" else if (isV1013LocalBuild) "\"http://127.0.0.1:8017/\"" else if (isV1012LocalBuild) "\"http://127.0.0.1:8015/\"" else if (isRelationshipDevBuild) "\"http://127.0.0.1:8012/\"" else if (isV1011LocalBuild) "\"http://127.0.0.1:8011/\"" else if (isV1010LocalBuild) "\"http://127.0.0.1:8010/\"" else if (isV1006LocalBuild) "\"http://127.0.0.1:8000/\"" else "\"http://101.133.161.203/\"")
            buildConfigField("String", "WS_BASE_URL", if (isV1015R1LocalBuild) "\"ws://127.0.0.1:8032/\"" else if (isV1015LocalBuild) "\"ws://127.0.0.1:8022/\"" else if (isV1014LocalBuild) "\"ws://127.0.0.1:8020/\"" else if (isV1013LocalBuild) "\"ws://127.0.0.1:8018/\"" else if (isV1012LocalBuild) "\"ws://127.0.0.1:8016/\"" else if (isRelationshipDevBuild) "\"ws://127.0.0.1:8013/\"" else if (isV1006LocalBuild) "\"\"" else "\"ws://101.133.161.203:8081/\"")
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
    debugImplementation("com.elitesync.flutter_elitesync_module:${if (isIceDiagnosticBuild) "flutter_debug" else "flutter_release"}:${if (isV1015R1LocalBuild) r1AarVersion else "1.0"}")
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

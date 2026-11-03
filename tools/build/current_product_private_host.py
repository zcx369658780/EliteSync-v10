"""Render source-pinned private host files; no writes or Gradle execution.

Gradle 8.14 bundled docs: filtering_repository_content.html (exclusiveContent),
StartParameter.java (isOffline/getTaskNames). The readonly guest mapping and
runtime consumption of these generated Kotlin files still require qualification.
"""
import hashlib
import json
import re

from current_product_aar_handoff import verify_repository


APP_SHA256 = '1c317b520a145523ccfee3265cbf5ecae2ea6c731025433f755cf7cd8a2fbb53'
SETTINGS_SHA256 = '1335de46738cdbf13351ea136487524f21eab849d6a02dc7341bce00d8a64fb9'
GUEST_REPOSITORY = 'C:/Inputs/VerifiedAarRepository'


def _source(text, expected):
    if type(text) is not str:
        raise ValueError('UTF-8 source text required')
    text = text.replace('\r\n', '\n')
    if hashlib.sha256(text.encode()).hexdigest() != expected:
        raise ValueError('host source differs from the pinned product')
    return text


def _replace(text, old, new):
    if text.count(old) != 1:
        raise ValueError('private host patch anchor is not unique')
    return text.replace(old, new, 1)


def render_private_host(app_gradle, settings_gradle, repository, version, *, file_limit, byte_limit):
    app = _source(app_gradle, APP_SHA256)
    settings = _source(settings_gradle, SETTINGS_SHA256)
    receipt = verify_repository(repository, version, file_limit=file_limit, byte_limit=byte_limit)
    entries = []
    for row in receipt['content_manifest']:
        if not re.fullmatch(r'[A-Za-z0-9_./+\-]+', row['relative_path']):
            raise ValueError('repository path cannot be embedded in Kotlin source')
        entries.append('    ' + json.dumps(row['relative_path']) + ' to ('
                       + str(row['bytes']) + 'L to ' + json.dumps(row['sha256']) + ')')
    checks = '''
val verifiedFlutterRepo = rootProject.file("C:/Inputs/VerifiedAarRepository").toPath()
val verifiedFlutterFiles = mapOf(
__FILES__
)
fun verifyPrivateFlutterRepository() {
    require(java.nio.file.Files.isDirectory(verifiedFlutterRepo, java.nio.file.LinkOption.NOFOLLOW_LINKS))
    require(verifiedFlutterRepo.toRealPath() == verifiedFlutterRepo.toAbsolutePath().normalize())
    val actual = mutableSetOf<String>()
    var visited = 0
    java.nio.file.Files.walk(verifiedFlutterRepo, 32).use { paths ->
        paths.forEach { path ->
            visited += 1
            require(visited <= verifiedFlutterFiles.size * 8) { "Repository entry bound exceeded" }
            require(!java.nio.file.Files.isSymbolicLink(path))
            require(path.toRealPath() == path.toAbsolutePath().normalize())
            if (!java.nio.file.Files.isDirectory(path, java.nio.file.LinkOption.NOFOLLOW_LINKS)) {
                require(java.nio.file.Files.isRegularFile(path, java.nio.file.LinkOption.NOFOLLOW_LINKS))
                actual.add(verifiedFlutterRepo.relativize(path).toString().replace('\\\\', '/'))
            }
        }
    }
    require(actual == verifiedFlutterFiles.keys) { "Verified AAR repository membership changed" }
    verifiedFlutterFiles.forEach { (relative, identity) ->
        val (expectedBytes, expected) = identity
        require(java.nio.file.Files.size(verifiedFlutterRepo.resolve(relative)) == expectedBytes)
        val digest = java.security.MessageDigest.getInstance("SHA-256")
        java.nio.file.Files.newInputStream(verifiedFlutterRepo.resolve(relative)).use { input ->
            val buffer = ByteArray(1024 * 1024)
            var total = 0L
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                total += count
                require(total <= expectedBytes) { "Repository file grew" }
                digest.update(buffer, 0, count)
            }
            require(total == expectedBytes) { "Repository file shortened" }
        }
        require(digest.digest().joinToString("") { "%02x".format(it) } == expected) {
            "Verified AAR repository content changed: $relative"
        }
    }
}
require(isV1015LocalBuild) { "This private host only covers the v10.1.5 local Debug build" }
verifyPrivateFlutterRepository()
val syncFlutterAar by tasks.registering {
    group = "build"
    description = "Recheck the separately produced, hash-bound Flutter AAR repository"
    doLast { verifyPrivateFlutterRepository() }
}
tasks.named("preBuild") { dependsOn(syncFlutterAar) }

'''.replace('__FILES__', ',\n'.join(entries))
    # Remove SDK lookup/BAT dispatch only from this rendered private copy.
    start = app.index('val flutterModuleDir =')
    end = app.index('val requestedFlutterDartDefines =', start)
    app = app[:start] + app[end:]
    start = app.index('val flutterReleaseAarRepo =')
    end = app.index('android {', start)
    app = app[:start] + checks + app[end:]
    app = _replace(app, 'debugImplementation("com.elitesync.flutter_elitesync_module:flutter_release:1.0")',
                   'debugImplementation(' + json.dumps(receipt['coordinate']) + ')')
    settings = _replace(settings, 'pluginManagement {', '''pluginManagement {
    require(gradle.startParameter.isOffline) { "Private host requires --offline" }
    require(gradle.startParameter.taskNames == listOf(":app:assembleDebug")) {
        "Only the separately authorized private host Debug task is covered"
    }''')
    modules = sorted({tuple(coordinate.split(':')[:2]) for coordinate in receipt['publications']})
    filters = '\n'.join('                includeModule(' + json.dumps(group) + ', '
                        + json.dumps(artifact) + ')' for group, artifact in modules)
    settings = _replace(settings, 'maven(url = uri("../flutter_elitesync_module/build/host/outputs/repo"))',
                        '''exclusiveContent {
            forRepository {
                maven {
                    url = uri("C:/Inputs/VerifiedAarRepository")
                    metadataSources {
                        mavenPom()
                        ignoreGradleMetadataRedirection()
                    }
                }
            }
            filter {
''' + filters + '''
            }
        }''')
    return {'app_gradle': app, 'settings_gradle': settings,
            'source_sha256': {'app': APP_SHA256, 'settings': SETTINGS_SHA256},
            'repository_content_manifest_sha256': receipt['content_manifest_sha256'],
            'coordinate': receipt['coordinate'], 'guest_repository': GUEST_REPOSITORY,
            'runtime_consumption': 'NOT_RUN', 'readonly_guest_mapping_proven': False,
            'producer_provenance_proven': False, 'execution_allowed': False, 'G2': False}

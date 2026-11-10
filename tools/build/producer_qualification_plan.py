"""Static input/resource candidates. No SDK, process, VM or build entry point."""
from pathlib import PurePosixPath, PureWindowsPath
import re


FLUTTER_FILES = (
    'bin/flutter.bat', 'bin/internal/shared.bat', 'bin/mingit/cmd/git.exe',
    'bin/cache/dart-sdk/bin/dart.exe', 'bin/cache/dart-sdk/bin/dartvm.exe',
    'bin/cache/dart-sdk/bin/dartaotruntime.exe', 'bin/cache/flutter_tools.snapshot',
    'packages/flutter_tools/.dart_tool/package_config.json',
    'bin/cache/flutter_tools.stamp', 'bin/cache/engine.stamp',
    'bin/cache/engine-dart-sdk.stamp',
    *(f'bin/cache/artifacts/engine/android-{abi}-release/windows-x64/gen_snapshot.exe'
      for abi in ('arm', 'arm64', 'x64')),
)
TOOL_FILES = {
    'android_build_tools_36': ('aapt2.exe', 'source.properties'),
    'android_cmake_3_22_1': ('bin/cmake.exe', 'bin/ninja.exe', 'source.properties'),
    'android_ndk_28_2': (
        'toolchains/llvm/prebuilt/windows-x86_64/bin/clang.exe',
        'toolchains/llvm/prebuilt/windows-x86_64/bin/clang++.exe',
        'toolchains/llvm/prebuilt/windows-x86_64/bin/ld.lld.exe', 'source.properties'),
    'jdk_17_0_18': ('bin/java.exe', 'bin/javac.exe', 'release'),
    'gradle_8_14': (
        'bin/gradle.bat', 'lib/gradle-launcher-8.14.jar',
        'src/core/org/gradle/initialization/DefaultGradlePropertiesLoader.java',
        'src/core/org/gradle/initialization/DefaultGradleProperties.java',
        'src/launcher/org/gradle/launcher/daemon/configuration/DaemonBuildOptions.java'),
}


def selected_records(inventory, role, mapping, relatives):
    """Bind explicit roles to exact inventoried host/guest paths, never glob."""
    host = PureWindowsPath(mapping['host'])
    guest = PureWindowsPath(mapping['guest'])
    if not host.is_absolute() or not guest.is_absolute():
        raise ValueError('absolute mapping roots required')
    if host != PureWindowsPath(inventory['roots'][role]):
        raise ValueError('mapping and inventoried root differ')
    by_relative = {}
    for row in inventory['files']:
        if row['role'] == role:
            by_relative.setdefault(row['relative_path'], []).append(row)
    result = []
    for relative in relatives:
        rel = PurePosixPath(relative)
        if (not relative or rel.is_absolute() or '..' in rel.parts or '\\' in relative
                or ':' in relative or str(rel) != relative):
            raise ValueError('canonical relative input required')
        matches = by_relative.get(relative, [])
        if len(matches) != 1:
            raise ValueError('one exact inventoried input required: ' + relative)
        row = matches[0]
        if PureWindowsPath(row['path']) != host.joinpath(*rel.parts):
            raise ValueError('inventoried path escapes declared root')
        if (type(row['bytes']) is not int or row['bytes'] < 0
                or not re.fullmatch('[0-9a-f]{64}', row['sha256'])):
            raise ValueError('exact byte size and sha256 required')
        result.append({**row, 'guest': guest.joinpath(*rel.parts).as_posix(),
                       'evidence': 'INVENTORIED_CONTENT_ONLY', 'qualified': False})
    return result


def resource_candidate(available_mib):
    if type(available_mib) is not int or available_mib < 0:
        raise ValueError('nonnegative integer memory snapshot required')
    return {
        'status': 'STATIC_RESOURCE_CANDIDATE_NOT_QUALIFIED',
        'guest_memory_mib_proposed': 6144, 'host_reserve_mib_proposed': 4096,
        'host_available_mib_at_snapshot': available_mib,
        'snapshot_has_proposed_headroom': available_mib >= 10240,
        'capacity_qualified': False, 'execution_allowed': False,
        'gradle_user_home_guest': 'C:/BuildWork/GradleHome',
        'required_gradle_arguments': ['--offline', '--no-daemon', '--max-workers=1'],
        'runtime_effective_properties': 'NOT_RUN',
        'producer_budget': 'UNKNOWN_NOT_CREATED', 'claim_created': False, 'G2': False,
    }


def gradle_properties():
    # Gradle 8.14 user-home override priority was checked in bundled Java source.
    # Actual daemon/tool consumption and Kotlin-version support remain NOT_RUN.
    return (
        'org.gradle.jvmargs=-Xmx2G -XX:MaxMetaspaceSize=768m '
        '-XX:ReservedCodeCacheSize=256m -XX:+HeapDumpOnOutOfMemoryError '
        '-XX:HeapDumpPath=C:/BuildWork/GradleHome\n'
        'org.gradle.workers.max=1\n'
        'org.gradle.parallel=false\n'
        'org.gradle.vfs.watch=false\n'
        'org.gradle.daemon=false\n'
        'kotlin.compiler.execution.strategy=in-process\n'
    )

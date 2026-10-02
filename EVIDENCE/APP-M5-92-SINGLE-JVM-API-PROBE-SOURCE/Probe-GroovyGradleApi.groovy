import groovy.json.JsonOutput

// SOURCE-ONLY. No candidate, file or environment access.
if (args.length != 0) throw new IllegalStateException('ES_PROBE_ARGS')
String gv = GroovySystem.version
String jv = System.getProperty('java.version')
String rv = System.getProperty('java.runtime.version')
if (gv != '3.0.24') throw new IllegalStateException('ES_GROOVY_VERSION')
if (jv != '17.0.18') throw new IllegalStateException('ES_JAVA_VERSION')
if (rv != '17.0.18+8') throw new IllegalStateException('ES_JAVA_RUNTIME_VERSION')
List names = [
    'org.gradle.api.Project',
    'org.gradle.api.plugins.ExtensionContainer',
    'org.gradle.api.plugins.ExtraPropertiesExtension'
]
List types = []
for (String name : names) {
    Class type = Class.forName(name, false, this.class.classLoader)
    if (!type.isInterface()) throw new IllegalStateException('ES_NOT_INTERFACE')
    String location = type.getProtectionDomain()?.getCodeSource()?.getLocation()?.toExternalForm()
    if (location == null) throw new IllegalStateException('ES_CODE_SOURCE')
    types.add([className: type.getName(), isInterface: true, codeSource: location])
}
println JsonOutput.toJson([
    mode: 'EXACT_GROOVY_GRADLE_API_PROBE', synthetic: true, runtimeReady: false,
    groovyVersion: gv, javaVersion: jv, javaRuntimeVersion: rv,
    candidateInvocation: 0, types: types
])

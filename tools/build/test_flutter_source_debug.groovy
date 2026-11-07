// Configuration fixture only: no Gradle build, SDK invocation or device access.
import org.codehaus.groovy.control.CompilerConfiguration
import org.codehaus.groovy.control.customizers.ImportCustomizer

def source = new File(args[0])
def fixture = new File(args[1])
def moduleDir = new File(fixture, 'flutter_elitesync_module')
def includeFile = new File(moduleDir, '.android/include_flutter.groovy')
def settingsDir = new File(fixture, 'android')
assert !fixture.exists(): 'Use a fresh fixture directory'
settingsDir.mkdirs()

def evaluateSettings = { String values ->
    def result = [callbacks: [], included: null]
    def providers = new Expando(gradleProperty: { String name ->
        assert name == 'flutterDartDefines'
        new Expando(orNull: values)
    })
    def gradle = new Expando(beforeProject: { Closure callback -> result.callbacks.add(callback) })
    def binding = new Binding(settingsDir: settingsDir, providers: providers, gradle: gradle,
        apply: { Map options -> result.included = options.from })
    def configuration = new CompilerConfiguration()
    configuration.addCompilationCustomizers(new ImportCustomizer().addImports('org.gradle.api.GradleException'))
    new GroovyShell(this.class.classLoader, binding, configuration).evaluate(source)
    result
}
def rejected = { String defines, String message ->
    try {
        evaluateSettings(defines)
        assert false: 'Expected rejection'
    } catch (org.gradle.api.GradleException error) {
        assert error.message.contains(message)
    }
}
rejected('ELITESYNC_V1015_LOCAL_BUILD=true', 'prepared Flutter module')
includeFile.parentFile.mkdirs()
includeFile.text = '// fixture; never executed'
for (values in [null, '', 'ELITESYNC_V1014_LOCAL_BUILD=true',
        'ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1014_LOCAL_BUILD=false',
        'ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_LOCAL_BUILD=false']) {
    rejected(values, 'v10.1.5 local gate')
}
def result = evaluateSettings(' ELITESYNC_V1015_LOCAL_BUILD=true ;EXTRA=中文,ELITESYNC_V1015_LOCAL_BUILD=true ')
assert result.included.canonicalFile == includeFile.canonicalFile
assert result.callbacks.size() == 1
def flutterValues = [:]
def appValues = [:]
result.callbacks[0](new Expando(path: ':app', extensions: new Expando(extraProperties: appValues)))
result.callbacks[0](new Expando(path: ':flutter', extensions: new Expando(extraProperties:
    new Expando(set: { String key, Object value -> flutterValues[key] = value }))))
assert appValues.isEmpty()
assert flutterValues['target-platform'] == 'android-arm64'
def decoded = flutterValues['dart-defines'].split(',').collect {
    new String(Base64.decoder.decode(it), 'UTF-8')
}
assert decoded == ['ELITESYNC_V1015_LOCAL_BUILD=true', 'EXTRA=中文', 'ELITESYNC_V1014_LOCAL_BUILD=true']
def explicit = evaluateSettings('ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1014_LOCAL_BUILD=true')
def explicitValues = [:]
explicit.callbacks[0](new Expando(path: ':flutter', extensions: new Expando(extraProperties:
    new Expando(set: { String key, Object value -> explicitValues[key] = value }))))
assert explicitValues['dart-defines'].split(',').size() == 2
println 'PASS: 8 source-settings fixture cases; no SDK/build/device invoked'

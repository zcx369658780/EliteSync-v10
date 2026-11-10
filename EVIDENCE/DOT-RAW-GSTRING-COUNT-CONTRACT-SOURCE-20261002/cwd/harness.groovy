import groovy.json.JsonOutput
import groovy.lang.GroovyClassLoader
import java.lang.reflect.InvocationHandler
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
import java.lang.reflect.Proxy
import java.nio.ByteBuffer
import java.nio.charset.CodingErrorAction
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths
import java.security.MessageDigest
import org.gradle.api.Project
import org.gradle.api.plugins.ExtensionContainer
import org.gradle.api.plugins.ExtraPropertiesExtension

// SOURCEONLY. A separate new authority is required; old M112 is closed.
// Exactly one synthetic RAW_GSTRING_PATH invocation attempt; no PASS verdict.
int sourceReadAttempt = 0
int parseClassLoadAttempt = 0
int candidateInvocationAttempt = 0
String stage = 'SOURCE'
GroovyClassLoader loader = null
Map inputObservation = null
Map state = null
Map input = null
Map inputBefore = null
Object returned = null
boolean returnedNormally = false
Throwable candidateFailure = null
Throwable reflectionFailure = null
Throwable infrastructureFailure = null
Throwable closeFailure = null
boolean observationComplete = false

Map expected = [
    'elitesync.aar-entry': 'module-debug-v1',
    'is-plugin': 'false',
    'output-dir': 'SYNTHETIC_PUBLICATION_PATH',
    'buildNumber': 'SYNTHETIC_INPUT_ID',
    'elitesync.sdk-identity': 'SYNTHETIC_SDK_ID',
    'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'
]
String expectedOuter = 'ES_LOCAL_EXTRA_FAILURE phase=INPUT completedSets=0 attemptedSets=0'
Closure check = { boolean condition, String tag ->
    if (!condition) throw new IllegalStateException(tag)
}
Closure className = { Object value ->
    if (value == null) return null
    String name = value.getClass().getName()
    check.call(name.length() <= 256, 'CLASS_NAME_LIMIT')
    name
}
Closure typeObservation = { Object value ->
    [className: className.call(value), isGString: value instanceof GString,
     isExactString: value != null && value.getClass() == String]
}
Closure describeFailure = { Throwable failure ->
    Throwable cause = failure == null ? null : failure.getCause()
    [present: failure != null, className: className.call(failure),
     messageMatchesExpectedOuter: failure != null && failure.getMessage() == expectedOuter,
     messageMatchesESInput: failure != null && failure.getMessage() == 'ES_INPUT',
     causePresent: cause != null, causeClassName: className.call(cause),
     causeMessageMatchesESInput: cause != null && cause.getMessage() == 'ES_INPUT']
}
Closure makeProxy = { Class api, Closure dispatch ->
    InvocationHandler handler = { Object proxy, Method method, Object[] arguments ->
        Object[] a = arguments == null ? new Object[0] : arguments
        if (method.getDeclaringClass() == Object) {
            if (method.getName() == 'equals' && a.length == 1) return proxy.is(a[0])
            if (method.getName() == 'hashCode' && a.length == 0) return System.identityHashCode(proxy)
            if (method.getName() == 'toString' && a.length == 0) return 'SYNTHETIC_PROXY'
        }
        return dispatch.call(method.getName(), a)
    } as InvocationHandler
    Proxy.newProxyInstance(api.getClassLoader(), [api] as Class[], handler)
}
Closure fixture = { Map initial, String path, String injection ->
    Map state = [
        own: new LinkedHashMap(initial), sets: [], reads: [], propertyReads: 0, events: []
    ]
    Object extra = makeProxy.call(ExtraPropertiesExtension, { String name, Object[] a ->
        if (name == 'getProperties' && a.length == 0) {
            state.reads.add('getProperties')
            state.events.add('READ:getProperties')
            state.propertyReads = state.propertyReads + 1
            if (injection == 'POST_READ' && state.propertyReads == 2)
                throw new IllegalStateException('SYNTHETIC_POST_READ_FAIL')
            return new LinkedHashMap(state.own)
        }
        if (name == 'set' && a.length == 2) {
            state.sets.add(a[0])
            state.events.add('SET:' + a[0])
            state.own.put(a[0], a[1])
            if (injection == 'THIRD_SET' && state.sets.size() == 3)
                throw new IllegalStateException('SYNTHETIC_SET_FAIL')
            return null
        }
        throw new IllegalStateException('SYNTHETIC_FORBIDDEN_EXTRA_CALL')
    })
    Object extensions = makeProxy.call(ExtensionContainer, { String name, Object[] a ->
        if (name == 'getExtraProperties' && a.length == 0) {
            state.reads.add('getExtraProperties')
            state.events.add('READ:getExtraProperties')
            return extra
        }
        throw new IllegalStateException('SYNTHETIC_FORBIDDEN_CONTAINER_CALL')
    })
    Object project = makeProxy.call(Project, { String name, Object[] a ->
        if (name == 'getPath' && a.length == 0) {
            state.reads.add('getPath')
            state.events.add('READ:getPath')
            return path
        }
        if (name == 'getExtensions' && a.length == 0) {
            state.reads.add('getExtensions')
            state.events.add('READ:getExtensions')
            return extensions
        }
        // Root, parent, inherited lookups and every unlisted method fail.
        throw new IllegalStateException('SYNTHETIC_FORBIDDEN_PROJECT_CALL')
    })
    state.put('project', project)
    state
}

try {
    sourceReadAttempt++
    byte[] raw = Files.readAllBytes(Paths.get(
        'D:/EliteSync-v10/EVIDENCE/APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE/LocalExtraRecipeInstaller.groovy'))
    check.call(raw.length == 6141, 'SOURCE_SIZE')
    byte[] digest = MessageDigest.getInstance('SHA-256').digest(raw)
    String hash = digest.collect { byte b -> String.format('%02X', b & 255) }.join()
    check.call(hash == '7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37', 'SOURCE_HASH')
    String text = StandardCharsets.UTF_8.newDecoder()
        .onMalformedInput(CodingErrorAction.REPORT)
        .onUnmappableCharacter(CodingErrorAction.REPORT)
        .decode(ByteBuffer.wrap(raw)).toString()
    stage = 'PARSE'
    loader = new GroovyClassLoader(this.class.getClassLoader())
    parseClassLoadAttempt++
    Class candidate = loader.parseClass(text, 'LocalExtraRecipeInstaller.groovy')
    Method install = candidate.getDeclaredMethod('install', Object, Object, Object)

    stage = 'FIXTURE'
    input = new LinkedHashMap(expected)
    inputBefore = new LinkedHashMap(input)
    Object bound = ':flutter'
    String suffix = 'flutter'
    bound = ":$suffix"
    check.call(bound instanceof GString, 'SPEC_RAW_GSTRING')
    state = fixture.call(new LinkedHashMap(), ':flutter', '')
    Object target = state.get('project')
    Object recipes = input
    // Observation-only extraction of the original inline Object[] expression.
    // Do not presume this extraction has runtime equivalence to old M112.
    Object[] invokeArgs = [target, bound, recipes] as Object[]
    inputObservation = [
        bound: typeObservation.call(bound),
        arrayElement: typeObservation.call(invokeArgs[1]),
        sameIdentity: bound.is(invokeArgs[1]),
        argumentCount: invokeArgs.length
    ]
    stage = 'INVOKE'
    candidateInvocationAttempt++
    try {
        returned = install.invoke(null, invokeArgs)
        returnedNormally = true
    } catch (InvocationTargetException wrapped) {
        candidateFailure = wrapped.getTargetException()
        check.call(candidateFailure != null, 'NULL_TARGET_EXCEPTION')
    } catch (Throwable reflectionProblem) {
        reflectionFailure = reflectionProblem
    }
    // No outcome assertion: collect either branch exactly once and stop.
    stage = 'OBSERVE'
    check.call(state.reads.size() <= 16 && state.sets.size() <= 16 && state.events.size() <= 16, 'OBSERVATION_LIMIT')
    observationComplete = true
} catch (Throwable firstFailure) {
    infrastructureFailure = firstFailure
} finally {
    if (loader != null) {
        try { loader.close() } catch (Throwable failure) { closeFailure = failure }
        loader = null
    }
}
observationComplete = observationComplete && infrastructureFailure == null && closeFailure == null
Map receipt = [
    mode: 'DIAGNOSTIC_ONLY', synthetic: true, runtimeReady: false,
    caseId: 'RAW_GSTRING_PATH', observationComplete: observationComplete,
    stage: stage, sourceReadAttempt: sourceReadAttempt,
    parseClassLoadAttempt: parseClassLoadAttempt,
    candidateInvocationAttempt: candidateInvocationAttempt,
    inputObservation: inputObservation, returnedNormally: returnedNormally,
    invokeOutcome: returnedNormally ? 'RETURNED_NORMALLY' :
        (candidateFailure != null ? 'TARGET_EXCEPTION_UNWRAPPED' :
        (reflectionFailure != null ? 'DIRECT_INVOKE_EXCEPTION' : 'NOT_OBSERVED')),
    returnObservation: [present: returned != null, className: className.call(returned), isMap: returned instanceof Map],
    candidateFailure: describeFailure.call(candidateFailure),
    reflectionFailure: describeFailure.call(reflectionFailure),
    infrastructureFailure: describeFailure.call(infrastructureFailure),
    closeFailure: describeFailure.call(closeFailure),
    proxyObservation: state == null ? null : [
        reads: state.reads, sets: state.sets, events: state.events,
        ownEmpty: state.own.isEmpty(), ownKeys: new ArrayList(state.own.keySet())
    ],
    callerMapUnchanged: input != null && inputBefore != null && input == inputBefore,
    realBinding: 'NOT_CHECKED', hook: 'NOT_CHECKED',
    libraryExtensionTiming: 'NOT_CHECKED', sdkCompatibility: 'NOT_CHECKED'
]
String json = JsonOutput.toJson(receipt)
check.call(json.getBytes(StandardCharsets.UTF_8).length <= 4096, 'JSON_LIMIT')
println json
if (!observationComplete) throw new IllegalStateException('DIAGNOSTIC_INFRASTRUCTURE_FAILURE')

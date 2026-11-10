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

// SOURCE-ONLY specification. No runtime/API locator is supplied or discovered.
// A separately authorized launcher must check exact source ancestors first.
int sourceReads = 0
int parseLoads = 0
int candidateInvocations = 0
int executedCases = 0
String currentCase = 'SOURCE'
List results = []
GroovyClassLoader loader = null

// Independent synthetic literals; never read candidate private fields.
List<String> keys = [
    'elitesync.aar-entry', 'is-plugin', 'output-dir', 'buildNumber',
    'elitesync.sdk-identity', 'elitesync.aar-projects'
]
Map expected = [
    'elitesync.aar-entry': 'module-debug-v1',
    'is-plugin': 'false',
    'output-dir': 'SYNTHETIC_PUBLICATION_PATH',
    'buildNumber': 'SYNTHETIC_INPUT_ID',
    'elitesync.sdk-identity': 'SYNTHETIC_SDK_ID',
    'elitesync.aar-projects': ':,:flutter,:sample_alpha,:sample_beta'
]
Closure check = { boolean condition, String tag ->
    if (!condition) throw new IllegalStateException(tag)
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
        own: new LinkedHashMap(initial), sets: [], reads: [], propertyReads: 0
    ]
    Object extra = makeProxy.call(ExtraPropertiesExtension, { String name, Object[] a ->
        if (name == 'getProperties' && a.length == 0) {
            state.reads.add('getProperties')
            state.propertyReads = state.propertyReads + 1
            if (injection == 'POST_READ' && state.propertyReads == 2)
                throw new IllegalStateException('SYNTHETIC_POST_READ_FAIL')
            return new LinkedHashMap(state.own)
        }
        if (name == 'set' && a.length == 2) {
            state.sets.add(a[0])
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
            return extra
        }
        throw new IllegalStateException('SYNTHETIC_FORBIDDEN_CONTAINER_CALL')
    })
    Object project = makeProxy.call(Project, { String name, Object[] a ->
        if (name == 'getPath' && a.length == 0) {
            state.reads.add('getPath')
            return path
        }
        if (name == 'getExtensions' && a.length == 0) {
            state.reads.add('getExtensions')
            return extensions
        }
        // Root, parent, inherited lookups and every unlisted method fail.
        throw new IllegalStateException('SYNTHETIC_FORBIDDEN_PROJECT_CALL')
    })
    state.put('project', project)
    state
}
List preReads = ['getPath', 'getExtensions', 'getExtraProperties', 'getProperties']
List fullReads = ['getPath', 'getExtensions', 'getExtraProperties', 'getProperties', 'getProperties']
Closure wrapperMessage = { String phase, int completed, int attempted ->
    'ES_LOCAL_EXTRA_FAILURE phase=' + phase +
        ' completedSets=' + completed + ' attemptedSets=' + attempted
}

try {
    sourceReads++
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
    loader = new GroovyClassLoader(this.class.getClassLoader())
    parseLoads++
    Class candidate = loader.parseClass(text, 'LocalExtraRecipeInstaller.groovy')
    Method install = candidate.getDeclaredMethod('install', Object, Object, Object)

    // Fixed independent case table. Each executed case makes one invocation.
    List<String> names = [
        'EMPTY_OWN', 'MIXED_OWN', 'SAME_OWN', 'LATE_VALUE_CONFLICT',
        'LATE_TYPE_CONFLICT', 'RAW_GSTRING_PATH', 'RAW_NULL_TARGET',
        'RAW_NONMAP', 'MISSING_KEY', 'GSTRING_VALUE', 'WRONG_MODE',
        'TARGET_MISMATCH', 'THIRD_SET_FAIL', 'POST_READ_FAIL'
    ]
    for (int index = 0; index < 14; index++) {
        currentCase = names[index]
        Map initial = new LinkedHashMap()
        Map input = new LinkedHashMap(expected)
        Object bound = ':flutter'
        String actualPath = ':flutter'
        String injection = ''
        int created = 6
        int unchanged = 0
        List expectedSets = new ArrayList(keys)
        List expectedReads = new ArrayList(fullReads)
        Map finalOwn = new LinkedHashMap(expected)
        String failurePhase = null
        String causeTag = null
        Class causeType = null
        int completed = 0
        int attempted = 0

        switch (index) {
            case 0:
                break
            case 1:
                initial.put('elitesync.aar-entry', 'module-debug-v1')
                initial.put('is-plugin', 'false')
                initial.put('unrelated', 'SYNTHETIC_UNRELATED')
                finalOwn.put('unrelated', 'SYNTHETIC_UNRELATED')
                created = 4
                unchanged = 2
                expectedSets = ['output-dir', 'buildNumber', 'elitesync.sdk-identity', 'elitesync.aar-projects']
                break
            case 2:
                initial = new LinkedHashMap(expected)
                created = 0
                unchanged = 6
                expectedSets = []
                break
            case 3:
                initial = new LinkedHashMap(expected)
                initial.put('elitesync.aar-projects', 'SYNTHETIC_CONFLICT')
                failurePhase = 'OWN_PRECHECK'
                causeTag = 'ES_OWN_CONFLICT'
                causeType = IllegalStateException
                break
            case 4:
                initial = new LinkedHashMap(expected)
                initial.put('elitesync.aar-projects', Boolean.FALSE)
                failurePhase = 'OWN_PRECHECK'
                causeTag = 'ES_OWN_CONFLICT'
                causeType = IllegalStateException
                break
            case 5:
                String suffix = 'flutter'
                bound = ":$suffix"
                check.call(bound instanceof GString, 'SPEC_RAW_GSTRING')
                failurePhase = 'INPUT'
                causeTag = 'ES_INPUT'
                causeType = IllegalArgumentException
                break
            case 6:
                failurePhase = 'INPUT'
                causeTag = 'ES_INPUT'
                causeType = IllegalArgumentException
                break
            case 7:
                failurePhase = 'INPUT'
                causeTag = 'ES_INPUT'
                causeType = IllegalArgumentException
                break
            case 8:
                input.remove('elitesync.aar-projects')
                failurePhase = 'INPUT'
                causeTag = 'ES_RECIPE_KEYS'
                causeType = IllegalArgumentException
                break
            case 9:
                String id = 'SYNTHETIC_INPUT_ID'
                input.put('buildNumber', "$id")
                check.call(input.get('buildNumber') instanceof GString, 'SPEC_GSTRING_VALUE')
                failurePhase = 'INPUT'
                causeTag = 'ES_RECIPE_TYPE_OR_KEY'
                causeType = IllegalArgumentException
                break
            case 10:
                input.put('elitesync.aar-entry', 'SYNTHETIC_WRONG_MODE')
                failurePhase = 'INPUT'
                causeTag = 'ES_RECIPE_MODE'
                causeType = IllegalArgumentException
                break
            case 11:
                actualPath = ':sample_alpha'
                failurePhase = 'TARGET_PATH'
                causeTag = 'ES_TARGET_SCOPE'
                causeType = IllegalArgumentException
                break
            case 12:
                injection = 'THIRD_SET'
                failurePhase = 'OWN_SET:output-dir'
                causeTag = 'SYNTHETIC_SET_FAIL'
                causeType = IllegalStateException
                completed = 2
                attempted = 3
                expectedSets = ['elitesync.aar-entry', 'is-plugin', 'output-dir']
                expectedReads = new ArrayList(preReads)
                finalOwn = [
                    'elitesync.aar-entry': 'module-debug-v1',
                    'is-plugin': 'false',
                    'output-dir': 'SYNTHETIC_PUBLICATION_PATH'
                ]
                break
            case 13:
                injection = 'POST_READ'
                failurePhase = 'OWN_POST_READ'
                causeTag = 'SYNTHETIC_POST_READ_FAIL'
                causeType = IllegalStateException
                completed = 6
                attempted = 6
                break
        }
        if (index >= 3 && index <= 11) {
            expectedSets = []
            finalOwn = new LinkedHashMap(initial)
            expectedReads = index <= 4 ? new ArrayList(preReads) :
                (index == 11 ? ['getPath'] : [])
        }
        Map state = fixture.call(initial, actualPath, injection)
        Object target = index == 6 ? null : state.get('project')
        Object recipes = index == 7 ? 'SYNTHETIC_NONMAP' : input
        Map inputBefore = new LinkedHashMap(input)
        Object returned = null
        Throwable failure = null
        executedCases++
        candidateInvocations++
        try {
            returned = install.invoke(null, [target, bound, recipes] as Object[])
        } catch (InvocationTargetException wrapped) {
            failure = wrapped.getTargetException()
        }
        if (failurePhase == null) {
            check.call(failure == null, 'UNEXPECTED_CANDIDATE_FAILURE')
            check.call(returned instanceof Map, 'RESULT_MAP')
            Map result = (Map) returned
            check.call(result.keySet() == ([
                'targetPath', 'createdCount', 'unchangedCount', 'status', 'runtimeReady'
            ] as Set), 'RESULT_KEYS')
            check.call(result.get('targetPath').getClass() == String &&
                result.get('targetPath') == ':flutter', 'RESULT_PATH')
            check.call(result.get('createdCount').getClass() == Integer &&
                result.get('createdCount') == created, 'RESULT_CREATED')
            check.call(result.get('unchangedCount').getClass() == Integer &&
                result.get('unchangedCount') == unchanged, 'RESULT_UNCHANGED')
            check.call(result.get('status').getClass() == String &&
                result.get('status') == 'SOURCE_ONLY', 'RESULT_STATUS')
            check.call(result.get('runtimeReady').getClass() == Boolean &&
                result.get('runtimeReady') == false, 'RESULT_RUNTIME')
        } else {
            check.call(failure != null && failure.getClass() == IllegalStateException, 'OUTER_CLASS')
            check.call(failure.getMessage() == wrapperMessage.call(failurePhase, completed, attempted), 'OUTER_MESSAGE')
            check.call(failure.getCause() != null &&
                failure.getCause().getClass() == causeType, 'CAUSE_CLASS')
            check.call(failure.getCause().getMessage() == causeTag, 'CAUSE_TAG')
            check.call(returned == null, 'FAILURE_RETURN')
        }
        check.call(state.sets == expectedSets, 'SET_SEQUENCE')
        check.call(state.reads == expectedReads, 'READ_SEQUENCE')
        check.call(state.own == finalOwn, 'OWN_STATE')
        check.call(input == inputBefore, 'CALLER_MAP_CHANGED')
        results.add([caseId: currentCase, result: 'PASS', invocationCount: 1])
    }
    check.call(executedCases == 14 && candidateInvocations == 14, 'TOTAL_COUNTS')
    // Closing is not a candidate call. Any close failure stops success output.
    loader.close()
    loader = null
    println JsonOutput.toJson([
        mode: 'TEST_SOURCE_SPEC', synthetic: true, runtimeReady: false,
        sourceRead: sourceReads, parseClassLoad: parseLoads,
        executedCase: executedCases, candidateInvocation: candidateInvocations,
        cases: results,
        realBinding: 'NOT_CHECKED', hook: 'NOT_CHECKED',
        libraryExtensionTiming: 'NOT_CHECKED', sdkCompatibility: 'NOT_CHECKED'
    ])
} catch (Throwable firstFailure) {
    // Stop immediately; never continue cases, retry or emit a PASS receipt.
    // No values or candidate payload are included in the compact failure record.
    println JsonOutput.toJson([
        mode: 'TEST_SOURCE_SPEC', synthetic: true, runtimeReady: false,
        result: 'FAIL', caseId: currentCase,
        sourceRead: sourceReads, parseClassLoad: parseLoads,
        executedCase: executedCases, candidateInvocation: candidateInvocations,
        completedCases: results
    ])
    throw firstFailure
}

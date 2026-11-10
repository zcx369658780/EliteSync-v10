import org.gradle.api.Project
import org.gradle.api.plugins.ExtraPropertiesExtension

/**
 * PROPOSED, SOURCE-ONLY. Explicit caller invocation only.
 * Caller owns target authorization, resolved identity/path values and timing.
 * No hook, root lookup, inherited property lookup, File or Android operation.
 */
final class LocalExtraRecipeInstaller {
    private static final List<String> KEYS = Collections.unmodifiableList([
        'elitesync.aar-entry', 'is-plugin', 'output-dir', 'buildNumber',
        'elitesync.sdk-identity', 'elitesync.aar-projects'
    ])
    private static final List<String> PATHS = Collections.unmodifiableList([
        ':', ':flutter', ':sample_alpha', ':sample_beta'
    ])

    static Map install(Object rawTarget, Object rawBoundProjectPath, Object rawResolvedRecipes) {
        String phase = 'INPUT'
        int completedSets = 0
        int attemptedSets = 0
        int unchangedCount = 0
        try {
            if (!(rawTarget instanceof Project) ||
                rawBoundProjectPath == null ||
                rawBoundProjectPath.getClass() != java.lang.String ||
                !(rawResolvedRecipes instanceof Map)) {
                throw new IllegalArgumentException('ES_INPUT')
            }
            Project target = (Project) rawTarget
            String boundProjectPath = (String) rawBoundProjectPath
            Map resolvedRecipes = (Map) rawResolvedRecipes
            if (!PATHS.contains(boundProjectPath)) {
                throw new IllegalArgumentException('ES_INPUT')
            }

            // Private copy: never write to caller map; no caller value coercion.
            Map<String, String> values = new LinkedHashMap<String, String>()
            for (Object item : resolvedRecipes.entrySet()) {
                Map.Entry entry = (Map.Entry) item
                Object key = entry.getKey()
                Object value = entry.getValue()
                if (key == null || key.getClass() != String ||
                    !KEYS.contains(key) || values.containsKey(key) ||
                    value == null || value.getClass() != String ||
                    ((String) value).isEmpty()) {
                    throw new IllegalArgumentException('ES_RECIPE_TYPE_OR_KEY')
                }
                values.put((String) key, (String) value)
            }
            if (values.size() != KEYS.size() || !values.keySet().containsAll(KEYS)) {
                throw new IllegalArgumentException('ES_RECIPE_KEYS')
            }
            if (!'module-debug-v1'.equals(values.get('elitesync.aar-entry')) ||
                !'false'.equals(values.get('is-plugin')) ||
                !':,:flutter,:sample_alpha,:sample_beta'.equals(
                    values.get('elitesync.aar-projects'))) {
                throw new IllegalArgumentException('ES_RECIPE_MODE')
            }
            Map<String, String> expected = Collections.unmodifiableMap(values)

            phase = 'TARGET_PATH'
            Object actualPath = target.getPath()
            if (actualPath == null || actualPath.getClass() != String ||
                !boundProjectPath.equals(actualPath)) {
                throw new IllegalArgumentException('ES_TARGET_SCOPE')
            }

            phase = 'OWN_READ'
            ExtraPropertiesExtension own = target.getExtensions().getExtraProperties()
            if (own == null) {
                throw new IllegalStateException('ES_OWN_CONTAINER')
            }
            Map registered = own.getProperties()
            if (registered == null) {
                throw new IllegalStateException('ES_OWN_SNAPSHOT')
            }
            // getProperties returns a detached map; do not mutate it.
            List<String> missing = new ArrayList<String>()
            phase = 'OWN_PRECHECK'
            for (String key : KEYS) {
                if (registered.containsKey(key)) {
                    Object existing = registered.get(key)
                    if (existing == null || existing.getClass() != String ||
                        !expected.get(key).equals(existing)) {
                        throw new IllegalStateException('ES_OWN_CONFLICT')
                    }
                    unchangedCount++
                } else {
                    missing.add(key)
                }
            }

            // All six existing values were checked before the first set.
            // No retry or rollback. A failing set may have side effects.
            for (String key : missing) {
                phase = 'OWN_SET:' + key
                attemptedSets++
                own.set(key, expected.get(key))
                completedSets++
            }

            phase = 'OWN_POST_READ'
            Map installed = own.getProperties()
            if (installed == null) {
                throw new IllegalStateException('ES_OWN_POST_SNAPSHOT')
            }
            phase = 'OWN_POSTCHECK'
            for (String key : KEYS) {
                if (!installed.containsKey(key)) {
                    throw new IllegalStateException('ES_OWN_POST_MISSING')
                }
                Object actual = installed.get(key)
                if (actual == null || actual.getClass() != String ||
                    !expected.get(key).equals(actual)) {
                    throw new IllegalStateException('ES_OWN_POST_CONFLICT')
                }
            }

            phase = 'RESULT'
            return Collections.unmodifiableMap([
                targetPath: boundProjectPath,
                createdCount: completedSets,
                unchangedCount: unchangedCount,
                status: 'SOURCE_ONLY',
                runtimeReady: false
            ])
        } catch (Throwable firstFailure) {
            // Completed count means set returned normally, not atomic writes.
            // Preserve original cause; never include recipe values in our message.
            throw new IllegalStateException(
                'ES_LOCAL_EXTRA_FAILURE phase=' + phase +
                ' completedSets=' + completedSets +
                ' attemptedSets=' + attemptedSets,
                firstFailure)
        }
    }
}

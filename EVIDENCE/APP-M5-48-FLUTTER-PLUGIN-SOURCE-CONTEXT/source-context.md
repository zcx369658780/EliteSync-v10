# M5-48｜FlutterPlugin 真实源码上下文

DOCS-ONLY CANDIDATE；待Work LEVEL2及独立Sol/high。2026-10-01，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。
准确来源：D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt。
CURRENT_IDENTITY_MATCHED：42405 bytes，SHA256 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313，普通non-reparse含祖先/strictUTF8通过。此为本轮实际核定，不是把历史locator追认为当前身份。

## 事实、提案及未解门

原源package=com.flutter.gradle（5），class FlutterPlugin : Plugin<Project>（34）；project为private nullable字段（35），apply(project: Project)完整范围46–306，唯一this.project赋值在47。imports已明确LibraryExtension（10）、Project（19）、File（29）；FlutterPluginUtils为本源同包引用，未读取实现；Regex在所读imports没有显式import，解析/兼容未验证。

|提案|准确文本落点及消费者|限制|
|---|---|---|
|apply-helper|成员范围建议在pluginHandler字段44后、override fun apply声明46前；用完整字段+空行+声明组合作唯一文字锚。|只能提出成员落点；helper所用API实现/当前工具编译未证。|
|apply-preflight-proposal|完整before为8空格this.project = project+LF；after加8空格esControlledModule(project)+LF。对应apply46–48。|第47行后、SDK/env/cache/native_loader/Flutter extension/addFlutterTasks之前；此处LibraryExtension和root/own属性已安装尚UNKNOWN，不把文本唯一等同语义时序正确。|
|repo-after|apply中87–101的Maven注入段；提案if (!esControlledModule(project))包住正文。|rootProject来自49，engineRealm在77–85构造；仍先发生engine/cache读取。绕过仓库正文不等于完整副作用隔离。|
|tasks-after|addFlutterTasks(Project)349–532；受控分支消费者esControlledModule(projectToAddTasksTo)的插入材料锚在app分支末尾453–454与host module分支455之间。|保留早期state失败return350–352；插件配置及任务/variant接口兼容需独立门。|

两Attachment完整字面来源：EVIDENCE/APP-M5-29-AAR-ADAPTATION-CONTRACT-CONSISTENCY-REPAIR/plan.md L218–272；M5-47修正文档作背景。三消费者完整为repo-after/esControlledModule(project)、tasks-after/esControlledModule(projectToAddTasksTo)、preflight-after/esControlledModule(project)。所读真实class/apply/addFlutterTasks没有该提案方法或调用；未显示范围不作额外全文搜索结论。

apply134调用this.addFlutterTasks(project)；addFlutterTasks366–454为app路径，455后为host模块路径，464–468要求host app project存在，470后在host.afterEvaluate配置library与application variants。不能把module入口等同受控debug路径已执行。
apply的环境/缓存读取54–85、native loader引用103–116、local.properties读取121–128、dependency checker210–236、profile/release配置249–282、forceNdkDownload284及dependencies303–305都可见；本轮只读文字，未访问这些目标。308–348及534以后不回显；工具链/helper实现/完整module-plugin输入闭包/属性安装时序/依赖任务图/产物仍UNKNOWN。

## 唯一最小SOURCE-ONLY后继建议（DRAFT / NOT_ISSUED）

单一交付：Work另定一个本仓Kotlin修订材料文档，覆盖helper成员、完整apply及addFlutterTasks相关before/after，准确列三消费者；只生成可审源码文字，不写/复制SDK或运行。先解决第47行前属性及Android extension安装时序的合同前门；未解决不得把早期preflight写成ready。基于本轮准确source identity与固定锚、有限一次来源/一次交付检查预算，首次冲突/缺上下文即停，不读邻文件或扩窗口。候选先独立Sol/high与WorkLEVEL2；实际SDK/API编译、隔离输入和构建须另任务。此为建议，当前无GO/派发/可执行补丁。

## A预算与完整原摘录

A新1/1关闭；chunk b4ddff，exit0，wall 0.2234915秒；一次ReadAllBytes=42405，固定1–307/349–533共492行，注释/空行未省。打印前组织计数27572 bytes；下方保存同次工具output原值（含单独计数行），实际UTF8 27604 bytes，亦<=32KiB。未重读SDK、未执行代码。

```text
SOURCE D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt BYTES=42405 SHA256=1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313 ordinary_non_reparse/strict_UTF8=PASS CURRENT_IDENTITY_MATCHED; A_READALLBYTES_COUNT=1
SECTION 1-307
1: // Copyright 2014 The Flutter Authors. All rights reserved.
2: // Use of this source code is governed by a BSD-style license that can be
3: // found in the LICENSE file.
4: 
5: package com.flutter.gradle
6: 
7: import com.android.build.api.dsl.ApplicationExtension
8: import com.android.build.gradle.AbstractAppExtension
9: import com.android.build.gradle.BaseExtension
10: import com.android.build.gradle.LibraryExtension
11: import com.android.build.gradle.api.ApkVariant
12: import com.android.build.gradle.tasks.PackageAndroidArtifact
13: import com.android.build.gradle.tasks.ProcessAndroidResources
14: import com.flutter.gradle.FlutterPluginUtils.readPropertiesIfExist
15: import com.flutter.gradle.plugins.PluginHandler
16: import com.flutter.gradle.tasks.FlutterTask
17: import org.gradle.api.GradleException
18: import org.gradle.api.Plugin
19: import org.gradle.api.Project
20: import org.gradle.api.Task
21: import org.gradle.api.UnknownTaskException
22: import org.gradle.api.file.Directory
23: import org.gradle.api.tasks.Copy
24: import org.gradle.api.tasks.TaskProvider
25: import org.gradle.api.tasks.bundling.Jar
26: import org.gradle.internal.os.OperatingSystem
27: import org.gradle.kotlin.dsl.support.serviceOf
28: import org.gradle.process.ExecOperations
29: import java.io.File
30: import java.nio.charset.StandardCharsets
31: import java.nio.file.Paths
32: import java.util.Properties
33: 
34: class FlutterPlugin : Plugin<Project> {
35:     private var project: Project? = null
36:     private var flutterRoot: File? = null
37:     private var flutterExecutable: File? = null
38:     private var localEngine: String? = null
39:     private var localEngineHost: String? = null
40:     private var localEngineSrcPath: String? = null
41:     private var localProperties: Properties? = null
42:     private var engineVersion: String? = null
43:     private var engineRealm: String? = null
44:     private var pluginHandler: PluginHandler? = null
45: 
46:     override fun apply(project: Project) {
47:         this.project = project
48: 
49:         val rootProject = project.rootProject
50:         if (FlutterPluginUtils.isFlutterAppProject(project)) {
51:             addTaskForLockfileGeneration(rootProject)
52:         }
53: 
54:         val flutterRootSystemVal: String? = System.getenv("FLUTTER_ROOT")
55:         val flutterRootPath: String =
56:             resolveFlutterSdkProperty(flutterRootSystemVal)
57:                 ?: throw GradleException(
58:                     "Flutter SDK not found. Define location with flutter.sdk in the " +
59:                         "local.properties file or with a FLUTTER_ROOT environment variable."
60:                 )
61: 
62:         flutterRoot = project.file(flutterRootPath)
63:         if (!flutterRoot!!.isDirectory) {
64:             throw GradleException("flutter.sdk must point to the Flutter SDK directory")
65:         }
66: 
67:         engineVersion =
68:             if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
69:                 "+" // Match any version since there's only one.
70:             } else {
71:                 val engineStampPath =
72:                     Paths.get(flutterRoot!!.absolutePath, "bin", "cache", "engine.stamp")
73:                 val engineStampContent = engineStampPath.toFile().readText().trim()
74:                 "1.0.0-$engineStampContent"
75:             }
76: 
77:         engineRealm =
78:             Paths
79:                 .get(flutterRoot!!.absolutePath, "bin", "cache", "engine.realm")
80:                 .toFile()
81:                 .readText()
82:                 .trim()
83:         if (engineRealm!!.isNotEmpty()) {
84:             engineRealm += "/"
85:         }
86: 
87:         // Configure the Maven repository.
88:         val hostedRepository: String =
89:             System.getenv(FlutterPluginConstants.FLUTTER_STORAGE_BASE_URL)
90:                 ?: FlutterPluginConstants.DEFAULT_MAVEN_HOST
91:         val repository: String? =
92:             if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
93:                 project.property(PROP_LOCAL_ENGINE_REPO) as String?
94:             } else {
95:                 "$hostedRepository/${engineRealm}download.flutter.io"
96:             }
97:         rootProject.allprojects {
98:             repositories.maven {
99:                 url = uri(repository!!)
100:             }
101:         }
102: 
103:         project.apply {
104:             from(
105:                 Paths.get(
106:                     flutterRoot!!.absolutePath,
107:                     "packages",
108:                     "flutter_tools",
109:                     "gradle",
110:                     "src",
111:                     "main",
112:                     "scripts",
113:                     "native_plugin_loader.gradle.kts"
114:                 )
115:             )
116:         }
117: 
118:         val flutterExtension: FlutterExtension =
119:             project.extensions.create("flutter", FlutterExtension::class.java)
120: 
121:         // TODO(gmackall): is this actually a different properties file than the previous one?
122:         val rootProjectLocalProperties = Properties()
123:         val rootProjectLocalPropertiesFile = rootProject.file("local.properties")
124:         if (rootProjectLocalPropertiesFile.exists()) {
125:             rootProjectLocalPropertiesFile.reader(StandardCharsets.UTF_8).use { reader ->
126:                 rootProjectLocalProperties.load(reader)
127:             }
128:         }
129:         flutterExtension.flutterVersionCode =
130:             rootProjectLocalProperties.getProperty("flutter.versionCode", "1")
131:         flutterExtension.flutterVersionName =
132:             rootProjectLocalProperties.getProperty("flutter.versionName", "1.0")
133: 
134:         this.addFlutterTasks(project)
135: 
136:         // By default, assembling APKs generates fat APKs if multiple platforms are passed.
137:         // Configuring split per ABI allows to generate separate APKs for each abi.
138:         // This is a noop when building a bundle.
139:         if (FlutterPluginUtils.shouldProjectSplitPerAbi(project)) {
140:             FlutterPluginUtils.getAndroidExtension(project).splits.abi {
141:                 isEnable = true
142:                 reset()
143:                 isUniversalApk = false
144:             }
145:         } else {
146:             // When splits-per-abi is NOT enabled, configure abiFilters to control which
147:             // native libraries are included in the APK.
148:             //
149:             // This is crucial: If a project includes third-party dependencies with x86 native libraries,
150:             // without these abiFilters, Google Play would incorrectly identify the app as supporting x86.
151:             // When users with x86 devices install the app, it would crash at runtime because Flutter's
152:             // native libraries aren't available for x86. By filtering out x86 at build time, Google Play
153:             // correctly excludes x86 devices from the compatible device list.
154:             //
155:             // NOTE: This code does NOT affect "add-to-app" scenarios because:
156:             // 1. For 'flutter build aar': abiFilters have no effect since libflutter.so and libapp.so
157:             //    are not packaged into AAR artifacts - they are only added as dependencies
158:             //    in pom files.
159:             // 2. For project dependencies (implementation(project(":flutter"))): The Flutter
160:             //    Gradle Plugin is not applied to the main app subproject, so this apply()
161:             //    method is never called.
162:             //
163:             // abiFilters cannot be added to templates because it would break builds when
164:             // --splits-per-abi is used due to conflicting configuration. This approach
165:             // adds them programmatically only when splits are not configured.
166:             //
167:             // If the user has specified abiFilters in their build.gradle file, those
168:             // settings will take precedence over these defaults.
169:             if (!FlutterPluginUtils.shouldProjectDisableAbiFiltering(project)) {
170:                 FlutterPluginUtils.getAndroidExtension(project).buildTypes.forEach { buildType ->
171:                     buildType.ndk.abiFilters.clear()
172:                     FlutterPluginConstants.DEFAULT_PLATFORMS.forEach { platform ->
173:                         val abiValue: String =
174:                             FlutterPluginConstants.PLATFORM_ARCH_MAP[platform]
175:                                 ?: throw GradleException("Invalid platform: $platform")
176:                         buildType.ndk.abiFilters.add(abiValue)
177:                     }
178:                 }
179:             }
180:         }
181:         val propDeferredComponentNames = "deferred-component-names"
182:         val deferredComponentNamesValue: String? =
183:             project.findProperty(propDeferredComponentNames) as? String
184:         if (deferredComponentNamesValue != null) {
185:             val componentNames: Set<String> =
186:                 deferredComponentNamesValue
187:                     .split(',')
188:                     .map { ":$it" }
189:                     .toSet()
190:             // TODO(gmackall): Unify the types we use for the android extension. This is yet
191:             //   another type we need unfortunately.
192:             val androidExtensionAsApplicationExtension =
193:                 project.extensions.getByType(ApplicationExtension::class.java)
194:             // TODO(gmackall): Should we clear here? I think this is equivalent to what we used to
195:             //    do, but unsure. Can't use a closure.
196:             androidExtensionAsApplicationExtension.dynamicFeatures.clear()
197:             androidExtensionAsApplicationExtension.dynamicFeatures.addAll(componentNames)
198:         }
199: 
200:         FlutterPluginUtils.getTargetPlatforms(project).forEach { targetArch ->
201:             val abiValue: String? = FlutterPluginConstants.PLATFORM_ARCH_MAP[targetArch]
202:             val androidExtension: BaseExtension = FlutterPluginUtils.getAndroidExtension(project)
203:             androidExtension.splits.abi.include(abiValue!!)
204:         }
205: 
206:         val flutterExecutableName = getExecutableNameForPlatform("flutter")
207:         flutterExecutable =
208:             Paths.get(flutterRoot!!.absolutePath, "bin", flutterExecutableName).toFile()
209: 
210:         // Validate that the provided Gradle, Java, AGP, and KGP versions are all within our
211:         // supported range.
212:         val shouldSkipDependencyChecks: Boolean =
213:             project.hasProperty("skipDependencyChecks") &&
214:                 (
215:                     project.properties["skipDependencyChecks"].toString().toBoolean()
216:                 )
217:         if (!shouldSkipDependencyChecks) {
218:             try {
219:                 DependencyVersionChecker.checkDependencyVersions(project)
220:             } catch (e: Exception) {
221:                 if (!project.hasProperty("usesUnsupportedDependencyVersions") ||
222:                     !(project.properties["usesUnsupportedDependencyVersions"] as Boolean)
223:                 ) {
224:                     // Possible bug in dependency checking code - warn and do not block build.
225:                     project.logger.error(
226:                         "Warning: Flutter was unable to detect project Gradle, Java, " +
227:                             "AGP, and KGP versions. Skipping dependency version checking. Error was: " +
228:                             e
229:                     )
230:                 } else {
231:                     // If usesUnsupportedDependencyVersions is set, the exception was thrown by us
232:                     // in the dependency version checker plugin so re-throw it here.
233:                     throw e
234:                 }
235:             }
236:         }
237: 
238:         BaseApplicationNameHandler.setBaseName(project)
239:         val flutterProguardRules: String =
240:             Paths
241:                 .get(
242:                     flutterRoot!!.absolutePath,
243:                     "packages",
244:                     "flutter_tools",
245:                     "gradle",
246:                     "flutter_proguard_rules.pro"
247:                 ).toString()
248:         // TODO(gmackall): reconsider getting the android extension every time
249:         FlutterPluginUtils.getAndroidExtension(project).buildTypes {
250:             // Add profile build type.
251:             create("profile") {
252:                 initWith(getByName("debug"))
253:                 // TODO(gmackall): do we need to clear?
254:                 this.matchingFallbacks.clear()
255:                 this.matchingFallbacks.addAll(listOf("debug", "release"))
256:             }
257: 
258:             // TODO(garyq): Shrinking is only false for multi apk split aot builds, where shrinking is not allowed yet.
259:             // This limitation has been removed experimentally in gradle plugin version 4.2, so we can remove
260:             // this check when we upgrade to 4.2+ gradle. Currently, deferred components apps may see
261:             // increased app size due to this.
262:             if (FlutterPluginUtils.shouldShrinkResources(project)) {
263:                 getByName("release") {
264:                     isMinifyEnabled = true
265:                     // Enables resource shrinking, which is performed by the Android Gradle plugin.
266:                     // The resource shrinker can't be used for libraries.
267:                     isShrinkResources = FlutterPluginUtils.isBuiltAsApp(project)
268:                     proguardFiles(
269:                         FlutterPluginUtils
270:                             .getAndroidExtension(project)
271:                             .getDefaultProguardFile("proguard-android-optimize.txt"),
272:                         flutterProguardRules
273:                     )
274: 
275:                     // Optionally adds custom Proguard rules as needed from `android/app/proguard-rules.pro`.
276:                     // Starting AGP 9.0 Proguard files must exist to be added to the configuration.
277:                     if (File("${project.projectDir}/proguard-rules.pro").exists()) {
278:                         proguardFile("proguard-rules.pro")
279:                     }
280:                 }
281:             }
282:         }
283: 
284:         FlutterPluginUtils.forceNdkDownload(project, flutterRootPath)
285: 
286:         if (FlutterPluginUtils.shouldProjectUseLocalEngine(project)) {
287:             // This is required to pass the local engine to flutter build aot.
288:             val engineOutPath: String = project.properties["local-engine-out"] as String
289:             val engineOut: File = project.file(engineOutPath)
290:             if (!engineOut.isDirectory) {
291:                 throw GradleException("local-engine-out must point to a local engine build")
292:             }
293:             localEngine = engineOut.name
294:             localEngineSrcPath = engineOut.parentFile.parent
295: 
296:             val engineHostOutPath: String = project.properties["local-engine-host-out"] as String
297:             val engineHostOut: File = project.file(engineHostOutPath)
298:             if (!engineHostOut.isDirectory) {
299:                 throw GradleException("local-engine-host-out must point to a local engine host build")
300:             }
301:             localEngineHost = engineHostOut.name
302:         }
303:         FlutterPluginUtils.getAndroidExtension(project).buildTypes.all {
304:             addFlutterDependencies(this)
305:         }
306:     }
307: 
SECTION 349-533
349:     private fun addFlutterTasks(projectToAddTasksTo: Project) {
350:         if (projectToAddTasksTo.state.failure != null) {
351:             return
352:         }
353: 
354:         FlutterPluginUtils.addTaskForJavaVersion(projectToAddTasksTo)
355:         FlutterPluginUtils.addTaskForKGPVersion(projectToAddTasksTo)
356:         if (FlutterPluginUtils.isFlutterAppProject(projectToAddTasksTo)) {
357:             FlutterPluginUtils.addTaskForPrintBuildVariants(projectToAddTasksTo)
358:             FlutterPluginUtils.addTasksForOutputsAppLinkSettings(projectToAddTasksTo)
359:         }
360: 
361:         val targetPlatforms: List<String> =
362:             FlutterPluginUtils.getTargetPlatforms(projectToAddTasksTo)
363: 
364:         val flutterPlugin = this
365: 
366:         if (FlutterPluginUtils.isFlutterAppProject(projectToAddTasksTo)) {
367:             // TODO(gmackall): I think this can be BaseExtension, with findByType.
368:             val android: AbstractAppExtension =
369:                 projectToAddTasksTo.extensions.findByName("android") as AbstractAppExtension
370:             android.applicationVariants.configureEach {
371:                 val variant = this
372:                 val assembleTask = variant.assembleProvider.get()
373:                 if (!FlutterPluginUtils.shouldConfigureFlutterTask(
374:                         projectToAddTasksTo,
375:                         assembleTask
376:                     )
377:                 ) {
378:                     return@configureEach
379:                 }
380:                 val copyFlutterAssetsTask: Task =
381:                     addFlutterDeps(variant, flutterPlugin, targetPlatforms)
382: 
383:                 // TODO(gmackall): Migrate to AGPs variant api.
384:                 //    https://github.com/flutter/flutter/issues/166550
385:                 @Suppress("DEPRECATION")
386:                 val variantOutput: com.android.build.gradle.api.BaseVariantOutput = variant.outputs.first()
387:                 val processResources: ProcessAndroidResources =
388:                     try {
389:                         variantOutput.processResourcesProvider.get()
390:                     } catch (e: UnknownTaskException) {
391:                         // TODO(gmackall): Migrate to AGPs variant api.
392:                         //    https://github.com/flutter/flutter/issues/166550
393:                         @Suppress("DEPRECATION")
394:                         variantOutput.processResources
395:                     }
396:                 processResources.dependsOn(copyFlutterAssetsTask)
397: 
398:                 // Copy the output APKs into a known location, so `flutter run` or `flutter build apk`
399:                 // can discover them. By default, this is `<app-dir>/build/app/outputs/flutter-apk/<filename>.apk`.
400:                 //
401:                 // The filename consists of `app<-abi>?<-flavor-name>?-<build-mode>.apk`.
402:                 // Where:
403:                 //   * `abi` can be `armeabi-v7a|arm64-v8a|x86_64` only if the flag `split-per-abi` is set.
404:                 //   * `flavor-name` is the flavor used to build the app in lower case if the assemble task is called.
405:                 //   * `build-mode` can be `release|debug|profile`.
406:                 variant.outputs.forEach { output ->
407:                     assembleTask.doLast {
408:                         // TODO(gmackall): Migrate to AGPs variant api.
409:                         //    https://github.com/flutter/flutter/issues/166550
410:                         @Suppress("DEPRECATION")
411:                         output as com.android.build.gradle.api.ApkVariantOutput
412:                         val packageApplicationProvider: PackageAndroidArtifact =
413:                             variant.packageApplicationProvider.get()
414:                         val outputDirectory: Directory =
415:                             packageApplicationProvider.outputDirectory.get()
416:                         val outputDirectoryStr: String = outputDirectory.toString()
417:                         var filename = "app"
418: 
419:                         // TODO(gmackall): Migrate to AGPs variant api.
420:                         //    https://github.com/flutter/flutter/issues/166550
421:                         @Suppress("DEPRECATION")
422:                         val abi = output.getFilter(com.android.build.VariantOutput.FilterType.ABI)
423:                         if (abi != null && abi.isNotEmpty()) {
424:                             filename += "-$abi"
425:                         }
426:                         if (variant.flavorName != null && variant.flavorName.isNotEmpty()) {
427:                             filename += "-${FlutterPluginUtils.lowercase(variant.flavorName)}"
428:                         }
429:                         filename += "-${FlutterPluginUtils.buildModeFor(variant.buildType)}"
430:                         projectToAddTasksTo.copy {
431:                             from(File("$outputDirectoryStr/${output.outputFileName}"))
432:                             into(projectToAddTasksTo.layout.buildDirectory.dir("outputs/flutter-apk"))
433:                             rename { "$filename.apk" }
434:                         }
435:                     }
436:                 }
437:             }
438:             // Copy the native assets created by build.dart and placed here by flutter assemble.
439:             // This path is not flavor specific and must only be added once.
440:             // If support for flavors is added to native assets, then they must only be added
441:             // once per flavor; see https://github.com/dart-lang/native/issues/1359.
442:             val nativeAssetsDir =
443:                 "${projectToAddTasksTo.layout.buildDirectory.get()}/../native_assets/android/jniLibs/lib/"
444:             android.sourceSets
445:                 .getByName("main")
446:                 .jniLibs
447:                 .srcDir(nativeAssetsDir)
448:             getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)
449:             FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(
450:                 projectToAddTasksTo,
451:                 getPluginHandler(projectToAddTasksTo).getPluginList()
452:             )
453:             return
454:         }
455:         // Flutter host module project (Add-to-app).
456:         val hostAppProjectName: String? =
457:             if (projectToAddTasksTo.rootProject.hasProperty("flutter.hostAppProjectName")) {
458:                 projectToAddTasksTo.rootProject.property(
459:                     "flutter.hostAppProjectName"
460:                 ) as? String
461:             } else {
462:                 "app"
463:             }
464:         val appProject: Project? =
465:             projectToAddTasksTo.rootProject.findProject(":$hostAppProjectName")
466:         check(appProject != null) {
467:             "Project :$hostAppProjectName doesn't exist. To customize the host app project name, set `flutter.hostAppProjectName=<project-name>` in gradle.properties."
468:         }
469:         // Wait for the host app project configuration.
470:         appProject.afterEvaluate {
471:             val androidLibraryExtension =
472:                 projectToAddTasksTo.extensions.findByType(LibraryExtension::class.java)
473:             check(androidLibraryExtension != null)
474:             androidLibraryExtension.libraryVariants.all libraryVariantAll@{
475:                 val libraryVariant = this
476:                 var copyFlutterAssetsTask: Task? = null
477:                 val androidAppExtension =
478:                     appProject.extensions.findByName("android") as? AbstractAppExtension
479:                 check(androidAppExtension != null)
480:                 androidAppExtension.applicationVariants.all applicationVariantAll@{
481:                     val appProjectVariant = this
482:                     val appAssembleTask: Task = appProjectVariant.assembleProvider.get()
483:                     if (!FlutterPluginUtils.shouldConfigureFlutterTask(project, appAssembleTask)) {
484:                         return@applicationVariantAll
485:                     }
486: 
487:                     // Find a compatible application variant in the host app.
488:                     //
489:                     // For example, consider a host app that defines the following variants:
490:                     // | ----------------- | ----------------------------- |
491:                     // |   Build Variant   |   Flutter Equivalent Variant  |
492:                     // | ----------------- | ----------------------------- |
493:                     // |   freeRelease     |   release                     |
494:                     // |   freeDebug       |   debug                       |
495:                     // |   freeDevelop     |   debug                       |
496:                     // |   profile         |   profile                     |
497:                     // | ----------------- | ----------------------------- |
498:                     //
499:                     // This mapping is based on the following rules:
500:                     // 1. If the host app build variant name is `profile` then the equivalent
501:                     //    Flutter variant is `profile`.
502:                     // 2. If the host app build variant is debuggable
503:                     //    (e.g. `buildType.debuggable = true`), then the equivalent Flutter
504:                     //    variant is `debug`.
505:                     // 3. Otherwise, the equivalent Flutter variant is `release`.
506:                     val variantBuildMode: String =
507:                         FlutterPluginUtils.buildModeFor(libraryVariant.buildType)
508:                     if (FlutterPluginUtils.buildModeFor(appProjectVariant.buildType) != variantBuildMode) {
509:                         return@applicationVariantAll
510:                     }
511:                     copyFlutterAssetsTask = copyFlutterAssetsTask ?: addFlutterDeps(
512:                         libraryVariant,
513:                         flutterPlugin,
514:                         targetPlatforms
515:                     )
516:                     // TODO(gmackall): Migrate to AGPs variant api.
517:                     //    https://github.com/flutter/flutter/issues/166550
518:                     val mergeAssets =
519:                         projectToAddTasksTo
520:                             .tasks
521:                             .findByPath(":$hostAppProjectName:merge${FlutterPluginUtils.capitalize(appProjectVariant.name)}Assets")
522:                     check(mergeAssets != null)
523:                     mergeAssets.dependsOn(copyFlutterAssetsTask)
524:                 }
525:             }
526:         }
527:         getPluginHandler(projectToAddTasksTo).configurePlugins(engineVersion!!)
528:         FlutterPluginUtils.detectLowCompileSdkVersionOrNdkVersion(
529:             projectToAddTasksTo,
530:             getPluginHandler(projectToAddTasksTo).getPluginList()
531:         )
532:     }
533: 
A=1/1 COMPLETE; read_bytes=42405; fixed_original_lines=492; SDK_WRITE/NEIGHBOR_READ/EXECUTION=0; output_UTF8_bytes_before_counter=27532
OUTPUT_TOTAL_UTF8_BYTES=27572

```

保存时B新0/1尚未执行；B仅本候选文字/引用/size/hash/成员核定一次，原回执在最终回复，不回改文件。全部旧预算关闭；M5-46/47 REJECT保持，M5-44/45接受及历史证据限制不追认。无SDK写/邻源读取、Python/AST/import/compile/算法/tests/checker/launcher/monitor/Gradle/Flutter/JVM/ADB/依赖解析/生成复制下载/构建安装启动，无Git mutation或受保护数据操作；dirty/untracked保留。M5/隔离构建NOT_READY、settings/v1全拒绝、loader/runtime false、真实性/恢复/生产/UAC门保持。交付后停独立审查，不自接受、不重跑、不后继。

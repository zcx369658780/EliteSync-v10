# APP-M5-23｜受控module四正文renderer合同候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。可在下述人工合成设计域实现SOURCE-ONLY纯内存renderer；四正文不是可启动工程，完整Flutter/plugin/registrant/依赖及系统隔离仍未闭合。M5/隔离构建NOT_READY，既有settings/v1全拒绝与loader/runtime false保持。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。172条既有状态保留，唯一新增本plan，无源码/authority/旧证据或Git写。

## 两轮本地预算

第一轮一次读入准确四份M5-10/18/19/21 plan，均READ_OK，退出0。按行选摘录，累计输出16KiB门在M5-19摘录中触发，剩余选段未回显，标SELECTED_EXCERPTS_NOT_ALL_EMITTED_CAP；不是工具截断或读取失败。M5-21本轮正文摘录未回显，本文不据未显示段增加新来源事实，只沿用此前已建立loader风险。

第二轮一次读入准确两源码/hash，退出0。aar_material_functions.py完整接口与实现回显；测试仅plugin_fixture及部分固定预期选段，16KiB门后续未回显。没有执行算法/测试，也不把选段核对当新的测试证明。每轮均一次，专业预算2/2耗尽，无重读/搜索/扩读；根authority独立入口读取不算专业轮次。

| 当前本地源码 | SHA256 |
| --- | --- |
| aar_material_functions.py | DAB75C66F4064E57635BB859900507CC8C3BCC46792A073322BBDF96560E7672 |
| test_aar_material_functions.py | AB9BBCCEF590AC48BFA240FACEB031FE107EAC1AAC5ED2DA631507248588C583 |

定位复用M5-18已保存模板：ephemeral settings:4–31/hash 3AE62F733A788ECEED03CCBAD2ED6F57CAEB0FDE2242EFC85CCD845B50F674FE；library build:3–50/hash C22E7D39B005F39B43DCA5E4C5602817EB978D4FAF143D64BB2CA0A6748B1AB3；library manifest:3–15/hash 3DBB9D6AC5A9E66622C9FE93817C0DD050DD007879B2B84C2B44C11C71BFB696。M5-19 include:16–28/hash B38E39873B391391B3CB51AC537E866FD084B16B6A0BD805EC89B5B7940815A8。未读SDK；历史hash只是引用。

## 接口、完整输入及域

新增准确两个文件apps/android_synthetic_demo/tools/render_module_bundle.py与test_render_module_bundle.py。接口render_module_bundle(*, config: dict, metadata: dict, approved_plugin_paths: tuple[tuple[str,str],...]) -> tuple[tuple[str,bytes],...]，仅标准库/内存；可调用已接受synthetic_plugin_materials与module_topology_materials，不能修改它们。测试加载精确renderer和已有材料模块，加载方式由后继task固定，不读取其它项目或SDK。

config是exact dict，必须且仅含以下所有键，无默认、extra、可执行对象或路径override：

| 键 | 类型与固定/允许域 | 来源类别 |
| --- | --- | --- |
| module_id | exact str，准确flutter | 已证项目名称；自有固定输入 |
| group_id | exact str，com.elitesync.syntheticdemo | 自有独立身份设计 |
| namespace | exact str，同group_id准确值 | 模板group/namespace同源；自有值 |
| module_root | exact str，module | 本任务四目标固定根 |
| sdk_root | exact str，materials/flutter_sdk | 自有bundle相对材料根 |
| maven_root | exact str，materials/maven | 自有离线材料根 |
| agp_version | exact str，8.11.1 | M5-10历史声明，只设计固定值，不证明兼容 |
| kotlin_version | exact str，2.2.20 | 同上 |
| compile_sdk/min_sdk/target_sdk | exact int，36/26/35 | M5-10 host设计值，移用于module是新设计 |
| ndk_version | exact str，数字段dot三段，首段非零，无符号/空白 | 必需显式人工值，未核真实NDK材料/兼容 |
| input_id | exact str，64个小写hex | 人工receipt标识；不计算/证明真实输入闭包 |

人工fixture NDK取27.0.12077973仅为确定字节测试值，不当本机/SDK/兼容事实。不得自动选择NDK、从Flutter属性读取默认或缺失fallback。类型错误TypeError，缺键/未知键/域外值/冲突ValueError，固定错误文本不回显原metadata/path值。

metadata/approved复用M5-22严格人工schema与全声明图规则，module_relative_root传准确module；本renderer收窄approved名与路径只允许sample_alpha→materials/sample_alpha、sample_beta→materials/sample_beta、sample_gamma→materials/sample_gamma，原样tuple顺序可变但正文只按metadata顺序输出native项。unknown真实插件拒绝。approved可包含未用gamma；metadata可空；不读取JSON或真实插件。

所有路径词法校验后还须拒绝按段等于/祖先重叠：module、sdk_root、maven_root、全部approved根、outputs、publication、host。固定设计值彼此独立；materials父目录只是共同容器，不按字符串前缀误判不同叶。配置不能注入引号、反斜线、冒号、换行、插值、绝对/drive/UNC、./../空段/尾分隔符；没有shell/Groovy自由文本输入。

## 相对基准与目标映射

bundle-root是纯逻辑根，不是磁盘路径。准确输出顺序只四项：

1 module/.android/settings.gradle
2 module/.android/build.gradle
3 module/.android/Flutter/build.gradle
4 module/.android/Flutter/src/main/AndroidManifest.xml

settingsDir与rootProjectDir都是bundle/module/.android；Flutter projectDir是bundle/module/.android/Flutter。settings中:flutter目录用相对settingsDir的Flutter，不写module/.android/Flutter。插件projectDir相对settingsDir用../../materials/<plugin>/android；SDK included build用../../materials/flutter_sdk/packages/flutter_tools/gradle；Maven repo用../../materials/maven。这些../是renderer从固定基准生成的可信常量，不接受调用者输入含../。

root build输出bundle/outputs/module-root；Flutter输出bundle/outputs/flutter；插件输出bundle/outputs/plugins/<name>，均由rootProject.projectDir下../../outputs/...表达。SDK included build自己的输出/缓存未受这些赋值证明，仍未解。

最终发布repo拟议bundle/publication/outputs/repo，未来调用受控init时output-dir必须指bundle/publication，不能误传repo本身；四正文只声明相对output-dir材料，不创建publication任务/POM。host独立bundle/host，不生成app/wrapper/host源码。flutter.source='../../'基于Flutter projectDir回到bundle/module；不是基于bundle-root，仍需Flutter插件实际解析验证。

## 人工两插件完整确定正文

人工正例metadata顺序alpha（native=true、dev=true、依赖beta）、beta（native=true、dev=false、无依赖）；approved可包含未用gamma。config采用上表固定值，input_id准确为64个a：aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa。以下四代码块是该fixture完整预期正文，每块末行后恰好一个LF；UTF-8无BOM、无CR、无尾空格。不包含代码围栏本身。其它有效input_id/NDK只替换对应已验证字段；其它native列表按已校验metadata原序替换明确逐项目行，不排序或去重。没有native时不输出plugin行/条件分支，其它行序不变。

settings.gradle：

```groovy
// SOURCE-ONLY synthetic module; NOT_READY.
pluginManagement {
    includeBuild(new File(settingsDir, '../../materials/flutter_sdk/packages/flutter_tools/gradle'))
    repositories {
        maven { url = uri(new File(settingsDir, '../../materials/maven')) }
    }
}
plugins {
    id 'com.android.library' version '8.11.1' apply false
    id 'org.jetbrains.kotlin.android' version '2.2.20' apply false
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven { url = uri(new File(settingsDir, '../../materials/maven')) }
    }
}
rootProject.name = 'android_generated'
include ':flutter'
project(':flutter').projectDir = new File(settingsDir, 'Flutter')
include ':sample_alpha'
project(':sample_alpha').projectDir = new File(settingsDir, '../../materials/sample_alpha/android')
include ':sample_beta'
project(':sample_beta').projectDir = new File(settingsDir, '../../materials/sample_beta/android')
```

root build.gradle：

```groovy
// SOURCE-ONLY synthetic module; NOT_READY.
layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/module-root'))
ext.set('output-dir', new File(rootProject.projectDir, '../../publication').path)
ext.set('is-plugin', 'false')
ext.set('buildNumber', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
subprojects {
    if (name == 'flutter') {
        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/flutter'))
    }
    if (name == 'sample_alpha') {
        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_alpha'))
    }
    if (name == 'sample_beta') {
        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_beta'))
    }
}
```

Flutter/build.gradle：

```groovy
// SOURCE-ONLY synthetic module; NOT_READY.
plugins {
    id 'com.android.library'
    id 'dev.flutter.flutter-gradle-plugin'
}
group = 'com.elitesync.syntheticdemo'
version = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
android {
    namespace = 'com.elitesync.syntheticdemo'
    compileSdk = 36
    ndkVersion = '27.0.12077973'
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    defaultConfig {
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = '1.0'
    }
    publishing {
        singleVariant('debug')
    }
}
androidComponents {
    beforeVariants(selector().all()) { variantBuilder ->
        variantBuilder.enable = variantBuilder.name == 'debug'
    }
}
flutter {
    source = '../..'
}
dependencies {
    implementation project(':sample_alpha')
    implementation project(':sample_beta')
}
```

Flutter manifest：

```xml
<!-- SOURCE-ONLY synthetic module; NOT_READY. -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
    <uses-permission android:name="android.permission.CAMERA" tools:node="remove" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" tools:node="remove" />
    <application android:allowBackup="false" tools:node="merge">
        <meta-data android:name="flutterProjectType" android:value="module" />
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
```

确定生成规则补充：root subprojects中:flutter分支总是第一，之后native项每项一个if（metadata顺序）；settings每项include/projectDir成对；Flutter dependencies只对返回native项逐行implementation，不生成条目间依赖脚本。M5-22依赖边用于人工全图校验，不证明插件自己的build.gradle有正确依赖。不会生成第三插件文件，dev=true不排除，false-native不include。本函数返回tuple[str,bytes]的四有序对，调用后输入修改不影响已返回不可变bytes。

## 来源事实与自有设计边界

已核模板支持library/Flutter插件ID、Java17、group/namespace、module标记、flutter.source ../..；include脚本支持:flutter名称与Flutter目录。原settings读取properties并应用loader、原manifest声明INTERNET，本renderer主动采用自有材料路径/显式plugin includes/权限remove，不能称官方模板等价复制。

本轮自行设计的repositoriesMode、local Maven-only声明、layout输出、显式NDK、debug variant API与独立group/version需SOURCE-ONLY审查，未编译/解析Gradle，不能声称AGP接口生效或插件只构建debug。尤其实际插件自身variant/任务图不被module beforeVariants证明；singleVariant publishing与受控init任务/publication关系尚未运行核定。

省略SDK settings loader/include_flutter只是不用该自动入口。仍includeBuild SDK Gradle、应用dev.flutter.flutter-gradle-plugin并将未知插件项目评估；其内部properties/metadata/engine/cache/工具/下载/注册/构建脚本副作用没有因四正文省略而消失。FAIL_ON_PROJECT_REPOS可能与Flutter/plugin动态加repo冲突，离线材料不齐也可能配置失败；不能放宽规则或自动添加远程repo解决。

四正文没有lib、assets、pubspec/lock/package_config/registrant、插件源/manifest、SDK/JDK/NDK/AGP/Kotlin/embedding/Maven材料或签名；不生成完整工程。移除权限只是拟议合并指令，不证明合并最终结果、实际无网络/设备数据隔离或host权限。manifest不生成Activity/provider，不能推断插件没有组件。

## 最小阻塞与后继门

可先实现上述合成域的纯字节renderer，并用完整字节fixture审查；构建仍被完整输入/依赖/SDK动态副作用、配置/OS网络/路径与任务图门阻止。准确已定位可作为下一来源任务的SDK入口为D:/flutter/packages/flutter_tools/gradle/module_plugin_loader.gradle及其native_plugin_loader.gradle.kts（已核），另有included build目录D:/flutter/packages/flutter_tools/gradle；dev.flutter.flutter-gradle-plugin的具体实现路径未在本授权中准确定位，不能按包名猜文件。须另立限定定位/读取任务固定实现与材料范围，当前不枚举目录或扩大源码读取。

复杂完整生成器、真实插件allowlist、OS/network supervisor及写入bundle均另审，不由纯renderer接受自动授权。现有settings/v1文件不被四正文替换、运行门不解除。

## 未来必要验证合同

正例严格比较上面人工两插件四完整UTF-8 bytes与准确路径顺序；测试fixture不得调用renderer回算预期。空native与false gamma/true dev、输入顺序、input_id与NDK替换有固定独立期望；校验path基准逐项：settingsDir的Flutter/../../materials、root的../../outputs、Flutter的../..，不能简单搜索出现bundle-root路径就判正确。检查无CR/BOM、恰一末LF、无源码执行/SDK/env/JSON访问、输出tuple与输入修改脱离。

负例strict dict/键/类型（bool不当int）、缺材料/SDK/NDK/ID、错误fixed identity/root/module/app/extra、非法version/input_id、引号/换行/插值/路径逃逸/冲突、metadata原M5-22失败族、approved真实/未知路径、native依赖false/循环/重复/128门、未知plugin/project输出冲突。四目标常量不可override，不允许app或wrapper。测试不能启动Gradle/Groovy/解析实际工程。

建议下一新task仅新增两个renderer文件、只读准确已接受材料模块，主结果summary；一次标准库目标测试进程（可同次加载既有31方法回归，具体授权由Work固定）、一次准确两文件静态/import/hash/空白检查，60秒及双流32KiB建议预算。首次验证失败即停、无修复重跑，独立Work LEVEL2审查。此处不发布任务、不实施或运行算法。

## 终止事实

专业本地读取2/2关闭，旧预算均保持。无SDK/cache/config/env/home/真实properties/JSON/插件内容/旧仓库/真实数据/备份密钥/DB/SSH/API读取，无renderer/算法/测试/工具/Flutter/Gradle/JVM/ADB/构建安装/复制下载/目标生成/UAC/Git写。唯一plan停Work独立LEVEL2审查，不自接受/后继；M5/隔离构建NOT_READY，loader/runtime false与真实账号/Conversation/G08/G11/恢复保护门保持。

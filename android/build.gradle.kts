group = "com.clashsing.flutter_sing_box"
version = "1.0-SNAPSHOT"

allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

plugins {
    id("com.android.library")
    kotlin("plugin.serialization") version "2.4.10"
}

android {
    namespace = "com.clashsing.flutter_sing_box"

    compileSdk = 37

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 26
        consumerProguardFiles("consumer-rules.pro")
    }

    buildFeatures {
        buildConfig = true
        aidl = true
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// mmkv Dart 包与原生 com.tencent:mmkv AAR 必须同版（cbridge 签名跨大版本不兼容），
// 以 pubspec.lock 实际解析的 mmkv 版本为单一事实源自动配对；
// 无 lock 场景（本模块脱离宿主 app 独立构建）兜底主干版本。
// 注意正则须锚定整名 mmkv + 换行：lock 中存在 mmkv_android / mmkv_ios 等前缀撞名条目。
fun mmkvVersion(): String {
    val lock = rootProject.file("../pubspec.lock")
    if (!lock.exists()) return "2.4.2"
    // pub 在 Windows 上写入 CRLF 行尾，而正则的 `.` 不匹配 \r，
    // 先归一化为 LF 再匹配，否则换行锚定失配、永远落到兜底版本。
    return Regex("""name:\s*mmkv\s*\n(?:.*\n)*?\s*version:\s*"?(\d+\.\d+\.\d+)""")
        .find(lock.readText().replace("\r\n", "\n"))?.groupValues?.get(1) ?: "2.4.2"
}

// 排查/验证用：./gradlew -q printMmkvVersion（宿主 app 构建时为 :flutter_sing_box:printMmkvVersion）
tasks.register("printMmkvVersion") {
    doLast { println("mmkv(AAR) = ${mmkvVersion()}") }
}

dependencies {
    implementation("com.github.singbox-android:libbox:1.14.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("com.tencent:mmkv:${mmkvVersion()}")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.11.0")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.23.0")
}

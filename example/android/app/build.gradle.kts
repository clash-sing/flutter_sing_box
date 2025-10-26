import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProps = Properties()
val localPropsFile = rootProject.file("local.properties")
if (localPropsFile.exists()) {
    localProps.load(FileInputStream(localPropsFile))
}

android {
    namespace = "com.clashsiing.flutter_sing_box_example"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.clashsiing.flutter_sing_box_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    val jksFile = file("release.keystore")
    signingConfigs {
        create("release") {
            keyAlias = localProps["keyAlias"] as String?
            keyPassword = localProps["keyPassword"] as String?
            storeFile = jksFile
            storePassword = localProps["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
//            isMinifyEnabled = true
//            isShrinkResources = true
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
        }
    }

    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
        implementation("com.tencent:mmkv:2.2.4")
        modules {
            module("com.tencent:mmkv-static") {
                replacedBy("com.tencent:mmkv", "Using mmkv for flutter")
            }
            module("com.tencent:mmkv-shared") {
                replacedBy("com.tencent:mmkv", "Using mmkv for flutter")
            }
        }
    }
}

flutter {
    source = "../.."
}

import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}


val keystoreProps = Properties()
val propsFile = File(rootDir, "key.properties")
if (propsFile.exists()) {
    keystoreProps.load(FileInputStream(propsFile))
} else {
}

val kpStorePassword = keystoreProps.getProperty("storePassword") ?: error("storePassword missing in key.properties")
val kpKeyPassword = keystoreProps.getProperty("keyPassword") ?: error("keyPassword missing in key.properties")
val kpKeyAlias = keystoreProps.getProperty("keyAlias") ?: error("keyAlias missing in key.properties")
val kpStoreFilePath = keystoreProps.getProperty("storeFile") ?: error("storeFile missing in key.properties")

android {
    namespace = "com.koofy.sudoku"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        create("release") {
            keyAlias = kpKeyAlias
            keyPassword = kpKeyPassword
            storeFile = File(rootDir, kpStoreFilePath)
            storePassword = kpStorePassword
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.koofy.sudoku"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            ndk {
                debugSymbolLevel = "none"
            }
        }
    }

    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
        doNotStrip("**/*.so")
    }
}

flutter {
    source = "../.."
}

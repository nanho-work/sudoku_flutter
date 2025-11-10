import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProps = Properties()
val propsFile = File(rootDir, "key.properties")
if (propsFile.exists()) {
    keystoreProps.load(FileInputStream(propsFile))
}

val kpStorePassword = keystoreProps.getProperty("storePassword") ?: ""
val kpKeyPassword = keystoreProps.getProperty("keyPassword") ?: ""
val kpKeyAlias = keystoreProps.getProperty("keyAlias") ?: ""
val kpStoreFilePath = keystoreProps.getProperty("storeFile") ?: ""

android {
    namespace = "com.koofy.sudoku"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        buildConfig = true // ✅ prevent duplicate BuildConfig issue
    }

    signingConfigs {
        create("release") {
            keyAlias = kpKeyAlias
            keyPassword = kpKeyPassword
            storeFile = if (kpStoreFilePath.isNotEmpty()) File(kpStoreFilePath) else null
            storePassword = kpStorePassword
        }
    }

    defaultConfig {
        applicationId = "com.koofy.sudoku"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        getByName("release") {
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

    packaging {
        jniLibs.useLegacyPackaging = true
        resources.excludes += "META-INF/*"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ Firebase 기본 BOM
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))

    // ✅ Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // ✅ AdMob
    implementation("com.google.android.gms:play-services-ads:23.2.0")
}
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ 최신 안정 버전 (2025년 기준)
        classpath("com.google.gms:google-services:4.4.2")
        classpath("com.android.tools.build:gradle:8.6.0") // 🔹 Android Gradle Plugin 명시
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24") // 🔹 Kotlin 플러그인 명시
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 🔹 Flutter 커스텀 빌드 디렉토리 구조 유지
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

subprojects {
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
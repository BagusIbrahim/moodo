// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.moodo" // Pastikan ini sesuai dengan namespace aplikasimu
    // <<-- PERBAIKAN: compileSdk UBAH KE 35 -->>
    compileSdk = 35 

    // ndkVersion tetap 27.0.12077973
    ndkVersion = "27.0.12077973" 

    // compileOptions dan kotlinOptions tetap seperti ini
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.example.moodo" // Pastikan ini sama dengan application ID kamu
        minSdk = flutter.minSdkVersion
        // <<-- PERBAIKAN: targetSdk UBAH KE 35 -->>
        targetSdk = 35 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Dependensi Desugaring tetap ada
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
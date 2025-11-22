plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.event_hub"
    compileSdk = 34  // Updated to a specific version (Flutter default)
    ndkVersion = "25.1.8937393"  // Updated to specific NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.event_hub"
        // IMPORTANT: Changed minSdk to 21 for Firebase compatibility
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"

        // Enable multidex for Firebase (required for apps with many dependencies)
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase dependencies - these are auto-managed by FlutterFire
    // but adding them explicitly for clarity
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}

// IMPORTANT: Apply Google Services plugin at the END of the file
apply(plugin = "com.google.gms.google-services")
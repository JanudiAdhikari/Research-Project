plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_app_two"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.flutter_app_two"
        minSdk = 26  // Updated from flutter.minSdkVersion to support tflite_flutter
        targetSdk = flutter.targetSdkVersion
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
    // Firebase BoM - manages all Firebase versions automatically
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Firebase SDKs you use
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-analytics")

    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0")

    // Google Play Services
    implementation("com.google.android.gms:play-services-base:18.2.0")

    implementation("androidx.browser:browser:1.5.0")
}
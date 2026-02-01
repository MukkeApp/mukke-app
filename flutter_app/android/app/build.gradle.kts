plugins {
    id("com.android.application")
    id("kotlin-android")
    // Der Flutter-Plugin MUSS nach Android & Kotlin kommen:
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.mukke_app.flutter_app"

    // Von Flutter vorgegeben (funktioniert mit dem Flutter-Plugin):
    compileSdk = flutter.compileSdkVersion
    // Explizit auf NDK 27 setzen (Plugins verlangen 27.0.12077973)
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.mukke_app.flutter_app"
        // Wenn deine Plugins es brauchen, 24 ist ok; sonst kannst du auch 23 setzen.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Für neuere Java-APIs in niedrigerem minSdk:
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase sauber über BOM (Versionen zentral):
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-analytics")
    // Weitere Firebase Libs brauchst du hier NICHT manuell,
    // wenn du FlutterFire-Plugins (firebase_core, firebase_auth, …) nutzt.
}

// 🔧 Unterdrückung von Quellwert/Zielwert- und Deprecation/Unchecked-Warnungen
tasks.withType<JavaCompile> {
    options.compilerArgs.addAll(listOf("-Xlint:-options", "-Xlint:-deprecation", "-Xlint:-unchecked"))
}

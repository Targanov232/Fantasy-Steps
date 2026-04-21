pluginManagement {
    val localProperties = java.util.Properties()
    val localPropertiesFile = File(settingsDir, "local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { localProperties.load(it) }
    }
    val flutterSdkPath = localProperties.getProperty("flutter.sdk")
        ?: System.getenv("FLUTTER_ROOT")
        ?: throw Exception("Flutter SDK not found. Define flutter.sdk in local.properties")
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // ОБЯЗАТЕЛЬНО добавляем apply false в конце этих строк:
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
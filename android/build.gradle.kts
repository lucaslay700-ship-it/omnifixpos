import com.android.build.api.dsl.ApplicationExtension
import org.gradle.kotlin.dsl.configure
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension

android {
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }
}

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // "kotlin-android" အဟောင်းအစား ဒါကိုသုံးပါ
    id("dev.flutter.flutter-gradle-plugin")
}

// AGP 8.4    အတွက် DSL အသစ် သုံးရန်
extensions.configure<ApplicationExtension> {
    namespace = "com.example.omnifixpos"
    compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.omnifixpos"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

// Deprecated ဖြစ်သွားတဲ့ jvmTarget အစား Kotlin Compiler Options သုံးရန်
extensions.configure<KotlinAndroidProjectExtension> {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}
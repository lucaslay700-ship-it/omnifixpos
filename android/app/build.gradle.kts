plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
android {
    namespace = "com.example.omnifixpos"
    
    // Compile လုပ်မည့် SDK Version (လက်ရှိ Android 14 အတွက် API 34)
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.omnifixpos"
        
        // Android 5.0 နဲ့အထက် ဖုန်း ၉၉% မက တင်သုံးလို့ရအောင် 21 ထားပါ
        minSdk = 21
        
        // Target SDK ကိုလည်း 34 ထားပေးပါ
        targetSdk = 34
        
        versionCode = 1
        versionName = "1.0"
    }
}

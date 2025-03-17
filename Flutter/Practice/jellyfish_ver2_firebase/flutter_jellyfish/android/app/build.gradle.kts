plugins {
    id("com.android.application") // Firebase 연결
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") // 이 부분이 Firebase 플러그인 적용 부분
    // END: FlutterFire Configuration
    id("kotlin-android") // Kotlin 언어 지원
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin") // 플러터 지원
}

android {
    namespace = "com.example.flutter_jellyfish"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_jellyfish" // 앱의 고유 식별자
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion // 지원 안드로이드 버전
        targetSdk = flutter.targetSdkVersion // 지원 안드로이드 버전
        versionCode = flutter.versionCode // 앱 버전 정보
        versionName = flutter.versionName
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

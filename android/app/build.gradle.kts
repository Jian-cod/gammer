plugins {
    id("com.android.application")
    kotlin("android")
    id("com.google.gms.google-services") // Firebase
}

android {
    namespace = "com.gammer.app" // <-- your actual package name
    compileSdk = 33

    defaultConfig {
        applicationId = "com.gammer.app" // <-- your actual package name
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.10")
    implementation("com.google.firebase:firebase-auth-ktx:22.2.2")
    implementation("com.google.firebase:firebase-firestore-ktx:24.6.1")
    implementation("com.google.firebase:firebase-storage-ktx:20.3.0")

    // Video player
    implementation("video_player:2.5.1")

    // Image picker
    implementation("image_picker:0.8.7+5")

    // Supabase Flutter client
    implementation("io.supabase:supabase_flutter:1.0.0") // verify latest version
}

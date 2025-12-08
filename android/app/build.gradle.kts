plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") version "4.4.4" apply false
    }

android {
    namespace = "com.android.application" // ← Senin package name’ine göre düzenle
    compileSdk = 34

    defaultConfig {
        applicationId = "com.android.application" // ← Aynısını kullan
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        multiDexEnabled = true
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
    // Firebase BOM (sürüm yönetimi)
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    // Firebase ürünleri
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")

    // Zorunlu Flutter / Android bağımlılıkları
    implementation("androidx.multidex:multidex:2.0.1")
}
    
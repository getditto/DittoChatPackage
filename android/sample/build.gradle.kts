import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
}

android {
    namespace = "com.ditto.chat.sample"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.ditto.chat.sample"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    @Suppress("UnstableApiUsage")
    composeOptions {
        kotlinCompilerExtensionVersion = "2.0.0"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    defaultConfig {
        // Load the secrets.properties file
        val secretsFile = rootProject.file("secrets.properties")
        val secretsProperties = Properties()
        if (secretsFile.exists()) {
            secretsFile.inputStream().use { secretsProperties.load(it) }
            buildConfigField(
                "String",
                "DITTO_APP_ID",
                "\"${secretsProperties.getProperty("ditto.app.id", "")}\""
            )
            buildConfigField(
                "String",
                "DITTO_TOKEN",
                "\"${secretsProperties.getProperty("ditto.token", "")}\""
            )
        } else {
            buildConfigField("String", "DITTO_APP_ID", "\"\"")
            buildConfigField("String", "DITTO_TOKEN", "\"\"")
        }
    }
}

dependencies {
    implementation(project(":chat"))
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.material3.android)
    implementation(libs.ditto)
}
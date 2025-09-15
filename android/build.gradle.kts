// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Firebase plugin
        classpath("com.google.gms:google-services:4.4.1")
        // Android Gradle Plugin
        classpath("com.android.tools.build:gradle:8.4.0")
        // Kotlin plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.10")
    }
}

// SDK versions
val compileSdkVersion = 33
val minSdkVersion = 21
val targetSdkVersion = 33

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: custom build directories
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

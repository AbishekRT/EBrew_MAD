// Top-level build file for configuration common to all sub-projects/modules

plugins {
    // Android Gradle Plugin
    id("com.android.application") version "8.7.0" apply false
    // Kotlin plugin (matching the classpath version to avoid conflicts)
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect build outputs to a common folder
val sharedBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(sharedBuildDir)

subprojects {
    val subBuildDir: Directory = sharedBuildDir.dir(project.name)
    project.layout.buildDirectory.set(subBuildDir)
    project.evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

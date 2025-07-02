allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    project.plugins.withId("org.jetbrains.kotlin.android") {
        project.extensions.findByType<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension>()?.apply {
            jvmToolchain(17)
        }
    }
    
    // 强制所有子项目使用相同的 Kotlin 编译选项
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            extensions.configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
        
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

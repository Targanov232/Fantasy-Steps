// УДАЛИТЕ ВСЕ ИМПОРТЫ СВЕРХУ, ЕСЛИ ОНИ ТАМ ЕСТЬ

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Исправленная настройка директории сборки для Gradle 8.11+
val newBuildDir = rootProject.projectDir.parentFile.resolve("build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val subProjectBuildDir = rootProject.layout.buildDirectory.get().asFile.resolve(project.name)
    project.layout.buildDirectory.set(subProjectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
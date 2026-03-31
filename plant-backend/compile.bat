@echo off
REM 植物护理管理系统后端编译脚本
REM 适用于 Windows 环境

echo ========================================
echo Greenly Plant Backend - 编译脚本
echo ========================================
echo.

REM 设置 JAVA_HOME
set JAVA_HOME=D:\test\Java\jdk-21
set MAVEN_HOME=D:\apache-maven-3.9.12

REM 验证 Java 环境
echo [1/3] 验证 Java 环境...
"%JAVA_HOME%\bin\java.exe" -version
if errorlevel 1 (
    echo [错误] Java 环境验证失败，请检查 JAVA_HOME 设置
    pause
    exit /b 1
)
echo.

REM 清理旧的编译文件
echo [2/3] 清理旧的编译文件...
if exist "target" (
    rmdir /s /q target
    echo 已删除 target 目录
)
echo.

REM 执行 Maven 编译
echo [3/3] 执行 Maven 编译...
call "%MAVEN_HOME%\bin\mvn.cmd" clean compile -DskipTests

if errorlevel 1 (
    echo.
    echo [失败] 编译失败，请检查错误信息
    pause
    exit /b 1
)

echo.
echo ========================================
echo 编译成功！
echo ========================================
echo.
echo 项目结构:
echo   - 数据库：MySQL (单数据源)
echo   - Mapper 包：com.plant.backend.mapper
echo   - 移除的功能:
echo     * SQLite 数据源支持
echo     * 本地植物管理 (LocalPlant)
echo     * 植物审核功能 (AuditOrder)
echo.
pause

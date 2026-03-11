# ========================================
# scrcpy 鸿蒙版 - PowerShell 启动脚本
# ========================================

param(
    [switch]$Verbose,
    [switch]$Debug
)

# 颜色函数
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Info { Write-ColorOutput Cyan $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }

# 横幅
Write-Info ""
Write-Info "========================================="
Write-Info "   scrcpy for HarmonyOS 6.0.2+          "
Write-Info "========================================="
Write-Info ""

# ========================================
# 步骤 1: 环境检查
# ========================================

Write-Info "[1/6] 环境检查..."

# 检查 hdc
try {
    $null = hdc version 2>&1
    Write-Success "  ✓ hdc 已安装"
} catch {
    Write-Error "  ✗ hdc 未安装！"
    Write-Warning ""
    Write-Warning "请安装 DevEco Studio 并将 hdc 添加到 PATH"
    Write-Warning "hdc 通常位于: DevEco Studio\tools\hdc\bin"
    Read-Host "按回车键退出"
    exit 1
}

# 检查设备连接
$devices = hdc list targets 2>&1
if ($devices -match "Empty") {
    Write-Error "  ✗ 未检测到设备！"
    Write-Warning ""
    Write-Warning "请检查："
    Write-Warning "  1. USB 线已连接"
    Write-Warning "  2. 手机已开启 USB 调试"
    Write-Warning "  3. 已授权电脑调试"
    Read-Host "按回车键退出"
    exit 1
}

Write-Success "  ✓ 设备已连接"

# 检查 scrcpy
if (-not (Get-Command "scrcpy" -ErrorAction SilentlyContinue)) {
    Write-Warning "  ⚠ scrcpy 未在 PATH 中"
    Write-Info "     将尝试从当前目录启动"
}

# ========================================
# 步骤 2: 检查 HAP 文件
# ========================================

Write-Info "[2/6] 检查安装包..."

$hapFile = "scrcpy-server.hap"
if (-not (Test-Path $hapFile)) {
    Write-Error "  ✗ 未找到 $hapFile"
    Write-Warning ""
    Write-Warning "请将编译好的 HAP 文件放在当前目录"
    Write-Warning "文件名应为: scrcpy-server.hap"
    Read-Host "按回车键退出"
    exit 1
}

Write-Success "  ✓ HAP 文件已找到"

# ========================================
# 步骤 3: 安装/更新应用
# ========================================

Write-Info "[3/6] 检查应用安装..."

$packageName = "com.example.scrcpyserver"
$installed = hdc shell bm dump -n $packageName 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "  ✓ 应用已安装"

    # 检查是否需要更新
    $currentVersion = hdc shell bm dump -n $packageName | Select-String "version"
    Write-Info "  当前版本: $currentVersion"
} else {
    Write-Info "  正在安装应用..."
    hdc install $hapFile

    if ($LASTEXITCODE -eq 0) {
        Write-Success "  ✓ 应用安装成功"
    } else {
        Write-Error "  ✗ 应用安装失败"
        Write-Warning ""
        Write-Warning "可能的原因："
        Write-Warning "  1. HAP 文件损坏"
        Write-Warning "  2. 设备存储空间不足"
        Write-Warning "  3. 签名配置错误"
        Read-Host "按回车键退出"
        exit 1
    }
}

# ========================================
# 步骤 4: 检查权限
# ========================================

Write-Info "[4/6] 检查权限..."

Write-Warning "  请在设备上授予以下权限："
Write-Info "    - 屏幕捕获"
Write-Info "    - 输入控制"
Write-Info "    - 网络访问"
Write-Info ""

Start-Sleep -Seconds 2

# ========================================
# 步骤 5: 启动服务器
# ========================================

Write-Info "[5/6] 启动服务器..."

# 停止旧实例
hdc shell aa force-stop $packageName 2>&1 | Out-Null
Start-Sleep -Milliseconds 500

# 启动应用
$startResult = hdc shell aa start -a EntryAbility -b $packageName 2>&1

if ($Verbose -or $Debug) {
    Write-Info "  启动结果: $startResult"
}

if ($LASTEXITCODE -eq 0) {
    Write-Success "  ✓ 服务器已启动"
} else {
    Write-Error "  ✗ 服务器启动失败"
    Write-Warning ""
    Write-Warning "查看日志命令："
    Write-Info "  hdc shell hilog -T ScrcpyServer"
    Write-Info ""

    if ($Debug) {
        Write-Info "最近的日志："
        hdc shell hilog -T ScrcpyServer | Select-Object -Last 20
    }

    Read-Host "按回车键退出"
    exit 1
}

# 等待服务器就绪
Write-Info "  等待服务器就绪..."
Start-Sleep -Seconds 2

# ========================================
# 步骤 6: 启动客户端
# ========================================

Write-Info "[6/6] 启动客户端..."
Write-Success ""
Write-Success "========================================="
Write-Success "  正在连接，请稍候..."
Write-Success "========================================="
Write-Info ""

# 构建 scrcpy 命令
$scrcpyArgs = @()

# 添加常用参数
$scrcpyArgs += "--window-title"
$scrcpyArgs += "Huawei Pura 80 Ultra"

# 可以在这里添加更多参数
# $scrcpyArgs += "--max-size"
# $scrcpyArgs += "1024"

# 启动 scrcpy
try {
    if (Get-Command "scrcpy" -ErrorAction SilentlyContinue) {
        & scrcpy $scrcpyArgs
    } elseif (Test-Path ".\scrcpy.exe") {
        & .\scrcpy.exe $scrcpyArgs
    } else {
        Write-Error "  ✗ 未找到 scrcpy.exe"
        Write-Info ""
        Write-Info "请下载 scrcpy 客户端："
        Write-Info "https://github.com/Genymobile/scrcpy/releases"
        Write-Info ""
        Read-Host "按回车键退出"
        exit 1
    }
} finally {
    # 清理：停止服务器
    Write-Info ""
    Write-Info "停止服务器..."
    hdc shell aa force-stop $packageName 2>&1 | Out-Null
}

Write-Success ""
Write-Success "感谢使用！"
Write-Info ""

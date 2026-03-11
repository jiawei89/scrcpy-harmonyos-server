# 🚀 方案 A - 完整部署指南

## 📋 准备工作清单

### 在 Windows 电脑上准备：

- [ ] DevEco Studio 5.0+ (用于编译 HAP)
- [ ] scrcpy 客户端 (Windows 版)
- [ ] 华为 Pura 80 Ultra (鸿蒙 6.0.2)
- [ ] USB 数据线

---

## 📦 第一步：获取 scrcpy 客户端

### 方式一：下载预编译版（推荐，2 分钟）

1. **访问官方发布页**
   ```
   https://github.com/Genymobile/scrcpy/releases
   ```

2. **下载 Windows 版本**
   ```
   scrcpy-win64-v3.3.4.zip
   ```

3. **解压到目录**
   ```
   C:\scrcpy\
   ├── scrcpy.exe
   ├── scrcpy-console.bat
   ├── ...其他文件
   ```

### 方式二：自己编译（高级）

参考 `scrcpy/WINDOWS_BUILD_GUIDE.md`

---

## 🔨 第二步：编译鸿蒙服务器（一次性，30 分钟）

### 2.1 安装 DevEco Studio

1. **下载**
   ```
   https://developer.huawei.com/consumer/cn/deveco-studio/
   ```

2. **安装并启动**
   - 选择默认安装即可
   - 首次启动会引导安装 SDK

3. **安装 HarmonyOS SDK 6.0.2**
   - Tools → SDK Manager
   - 勾选 API 12 (对应 HarmonyOS 6.0.2)
   - 点击 Apply 安装

### 2.2 配置签名（重要！）

1. **打开项目**
   ```
   File → Open → 选择 harmonyos-server 目录
   ```

2. **配置签名**
   ```
   File → Project Structure → Signing Configs
   → 勾选 "Automatically generate signature"
   → Apply
   ```

3. **验证签名**
   - 确保没有红色错误提示

### 2.3 编译 HAP

1. **Build Hap**
   ```
   Build → Build Hap(s) / APP(s) → Build Hap(s)
   ```

2. **等待编译完成**
   - 右下角显示 "Build successful"
   - 首次编译可能需要 5-10 分钟

3. **找到 HAP 文件**
   ```
   entry/build/default/outputs/default/entry-default-signed.hap
   ```

4. **重命名并复制**
   ```
   复制到: C:\scrcpy\scrcpy-server.hap
   ```

---

## 📱 第三步：安装到手机（一次性，5 分钟）

### 3.1 启用开发者模式

1. **进入设置**
   ```
   设置 → 关于手机
   ```

2. **连续点击"版本号" 7 次**
   - 提示"您已处于开发者模式"

3. **进入开发者选项**
   ```
   设置 → 系统和更新 → 开发者选项
   ```

4. **开启以下选项**
   - ✅ USB 调试
   - ✅ "仅充电"模式下允许 ADB 调试
   - ✅ 禁止权限监控（可选，但推荐）

### 3.2 连接电脑

1. **USB 连接**
   - 用数据线连接手机和电脑

2. **授权调试**
   - 手机弹出提示："允许 USB 调试？"
   - 勾选"始终允许"
   - 点击"允许"

3. **验证连接**
   ```cmd
   hdc list targets
   ```
   应该显示设备序列号

### 3.3 安装 HAP

**方式一：使用脚本（推荐）**

将 `start.bat` 复制到 `C:\scrcpy\`，然后：
```cmd
cd C:\scrcpy
start.bat
```

脚本会自动安装并启动！

**方式二：手动安装**

```cmd
cd C:\scrcpy
hdc install scrcpy-server.hap
```

---

## 🎯 第四步：测试运行

### 使用自动化脚本（推荐）

```cmd
cd C:\scrcpy
start.bat
```

**脚本会自动完成**：
1. ✓ 检查设备连接
2. ✓ 检查并安装应用
3. ✓ 启动服务器
4. ✓ 启动 scrcpy 客户端
5. ✓ 连接投屏

### 手动启动（高级用户）

```cmd
REM 1. 启动服务器
hdc shell aa start -a EntryAbility -b com.example.scrcpyserver

REM 2. 等待 2 秒
timeout /t 2 /nobreak

REM 3. 启动客户端
scrcpy
```

---

## ✅ 预期结果

成功的话，你会看到：

1. **Windows 上出现手机画面** ✅
2. **鼠标可以控制手机** ✅
3. **键盘可以输入文字** ✅
4. **画面流畅，延迟 < 100ms** ✅

---

## 🎮 日常使用

### 快速启动

**之后每次使用只需要**：

```cmd
cd C:\scrcpy
start.bat
```

或者创建桌面快捷方式：
1. 右键 `start.bat` → 发送到 → 桌面快捷方式
2. 双击即可启动

### 高级参数

编辑 `start.bat`，在 `scrcpy.exe` 后添加参数：

```cmd
REM 降低分辨率
scrcpy.exe --max-size 1024

REM 全屏
scrcpy.exe --fullscreen

REM 录制
scrcpy.exe --record=video.mp4

REM 组合使用
scrcpy.exe --max-size 1024 --fullscreen --window-title "My Phone"
```

---

## 🐛 故障排除

### 问题 1：脚本报错"未找到 hdc"

**解决**：
1. DevEco Studio 安装后，hdc 在：
   ```
   C:\Users\你的用户名\Huawei\Sdk\toolchains\hdc\bin
   ```
2. 将此路径添加到系统 PATH
3. 或者复制 hdc.exe 到 `C:\scrcpy\`

### 问题 2：设备离线

**解决**：
```cmd
hdc kill-server
hdc start-server
hdc list targets
```

### 问题 3：无法安装 HAP

**检查**：
1. HAP 文件是否损坏（重新编译）
2. 手机存储空间是否充足
3. 签名是否正确（重新配置签名）

### 问题 4：画面卡顿

**解决**：
```cmd
scrcpy --max-size 1024 --video-bit-rate 4M
```

### 问题 5：无法连接

**检查服务器日志**：
```cmd
hdc shell hilog -T ScrcpyServer
```

---

## 📊 目录结构

部署完成后的目录结构：

```
C:\scrcpy\
├── scrcpy.exe                ← Windows 客户端
├── scrcpy-server.hap          ← 鸿蒙服务器（编译后）
├── start.bat                 ← 一键启动脚本
├── start.ps1                 ← PowerShell 版本（可选）
├── scrcpy-console.bat        ← 原版控制台
└── ...其他文件
```

---

## 🔄 更新服务器

如果需要更新服务器：

1. **重新编译 HAP**
   - DevEco Studio → Build

2. **卸载旧版本**
   ```cmd
   hdc uninstall com.example.scrcpyserver
   ```

3. **安装新版本**
   ```cmd
   hdc install scrcpy-server.hap
   ```

---

## 💡 优化建议

### 1. 创建桌面快捷方式

```
右键 start.bat → 发送到 → 桌面快捷方式
重命名为 "scrcpy 鸿蒙版"
```

### 2. 自定义窗口

编辑 `start.bat`，添加：
```cmd
scrcpy.exe --window-title "我的 Pura 80 Ultra" --always-on-top
```

### 3. 设置快捷键

在快捷方式属性中设置快捷键（如 Ctrl+Alt+S）

---

## 📞 需要帮助？

1. **查看日志**
   ```cmd
   hdc shell hilog -T ScrcpyServer
   ```

2. **重新安装**
   ```cmd
   hdc uninstall com.example.scrcpyserver
   hdc install scrcpy-server.hap
   ```

3. **重启设备**
   - 重启手机
   - 重启 DevEco Studio

---

## ✨ 总结

**一次性安装**（约 40 分钟）：
1. 下载 scrcpy 客户端（2 分钟）
2. 编译鸿蒙服务器（30 分钟）
3. 安装到手机（5 分钟）
4. 测试运行（3 分钟）

**日常使用**（5 秒）：
- 双击 `start.bat`
- 开始投屏！

**和 Android 版本的区别**：
- 首次需要安装应用（一次）
- 之后体验完全相同

---

**准备好了吗？开始吧！** 🚀

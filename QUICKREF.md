# 📋 快速参考卡片

## 🚀 一键启动

```cmd
cd C:\scrcpy
start.bat
```

## 🛠️ 常用命令

### 检查设备连接
```cmd
hdc list targets
```

### 手动安装服务器
```cmd
hdc install scrcpy-server.hap
```

### 手动启动服务器
```cmd
hdc shell aa start -a EntryAbility -b com.example.scrcpyserver
```

### 停止服务器
```cmd
hdc shell aa force-stop com.example.scrcpyserver
```

### 查看日志
```cmd
hdc shell hilog -T ScrcpyServer
```

## 🎮 scrcpy 常用参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `--max-size` | 最大分辨率 | `--max-size 1024` |
| `--fullscreen` | 全屏模式 | `--fullscreen` |
| `--no-border` | 无边框窗口 | `--no-border` |
| `--always-on-top` | 窗口置顶 | `--always-on-top` |
| `--record` | 录制屏幕 | `--record=video.mp4` |
| `--window-title` | 自定义标题 | `--window-title "My Phone"` |
| `--video-bit-rate` | 视频码率 | `--video-bit-rate 4M` |
| `--max-fps` | 最大帧率 | `--max-fps 30` |

## ⚡ 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+Shift+F` | 切换全屏 |
| `Ctrl+Shift+G` | 折叠窗口 |
| `Ctrl+Shift+S` | 修改窗口大小 |
| `Ctrl+Shift+←` | 向旋转屏幕 |
| `Ctrl+Shift+→` | 向右旋转屏幕 |
| `Ctrl+Shift+↑` | 恢复屏幕 |
| `Ctrl+Shift+P` | 电源键 |
| `Ctrl+Shift+O` | 关闭屏幕 |
| `Ctrl+Shift+B` | 返回/Home |
| `Ctrl+Shift+H` | Home 键 |
| `Ctrl+Shift+M` | 显示菜单 |
| `Ctrl+Shift+I` | 显示/隐藏按键 |
| `Ctrl+Shift+L` | 显示/隐藏鼠标光标 |
| `Ctrl+Shift+N` | 展开通知栏 |
| `Ctrl+Shift+W` | 展开快捷设置 |

## 🐛 常见问题速查

| 问题 | 解决方案 |
|------|---------|
| 设备离线 | `hdc kill-server && hdc start-server` |
| hdc 未找到 | 添加到 PATH 或复制到 scrcpy 目录 |
| 无法安装 | 检查签名，重新编译 HAP |
| 画面卡顿 | 降低分辨率 `--max-size 1024` |
| 无法连接 | 检查服务器是否启动 `hdc shell aa start...` |
| 权限错误 | 在手机上手动授予权限 |

## 📁 文件位置

### HAP 文件（编译后）
```
entry/build/default/outputs/default/entry-default-signed.hap
```

### hdc 工具
```
C:\Users\你的用户名\Huawei\Sdk\toolchains\hdc\bin\hdc.exe
```

### 日志文件
```
通过 hdc 实时查看，无固定文件位置
```

## 🔧 开发相关

### 重新编译 HAP
```
DevEco Studio → Build → Build Hap(s)
```

### 重新安装
```cmd
hdc uninstall com.example.scrcpyserver
hdc install scrcpy-server.hap
```

### 清理构建
```
Build → Clean Project
```

## 💡 优化建议

### 降低延迟
```cmd
scrcpy --max-size 800 --video-bit-rate 2M
```

### 提高画质
```cmd
scrcpy --video-bit-rate 16M --max-fps 60
```

### 录制游戏
```cmd
scrcpy --record=gameplay.mp4 --max-size 1024
```

---

**打印此页，贴在显示器旁边！** 📌

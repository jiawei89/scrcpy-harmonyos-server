# 🚀 快速开始指南

## 前提条件

你需要有一台 **Windows 电脑** 和一台 **华为 Pura 80 Ultra（鸿蒙 6.0.2）**

---

## 第一步：在 Windows 上准备 scrcpy 客户端

### 方式一：下载预编译版本（推荐）

1. **下载官方客户端**
   - 访问：https://github.com/Genymobile/scrcpy/releases
   - 下载最新版本的 Windows 版本（如 `scrcpy-win64-v3.3.4.zip`）

2. **解压并测试**
   ```cmd
   解压到 C:\scrcpy
   cd C:\scrcpy
   scrcpy --version
   ```

### 方式二：自己编译（高级）

参考 `/root/.openclaw/workspace-coder/scrcpy/WINDOWS_BUILD_GUIDE.md`

---

## 第二步：在鸿蒙设备上安装服务器

### 你需要做的（在 Windows 上）：

1. **安装 DevEco Studio**
   - 下载：https://developer.huawei.com/consumer/cn/deveco-studio/
   - 安装 HarmonyOS SDK 6.0.2

2. **获取代码**
   ```bash
   # 代码已经在我这里写好了，位置：
   /root/.openclaw/workspace-coder/harmonyos-server/
   ```

3. **打开项目**
   ```
   DevEco Studio → File → Open → 选择 harmonyos-server 目录
   ```

4. **配置签名**
   ```
   File → Project Structure → Signing Configs
   → 自动生成签名证书
   ```

5. **编译 HAP**
   ```
   Build → Build Hap(s) / APP(s) → Build Hap(s)
   ```

6. **生成安装包**
   ```
   输出位置：
   entry/build/default/outputs/default/entry-default-signed.hap
   ```

7. **安装到手机**
   ```bash
   # 使用 hdc 命令（DevEco Studio 自带）
   hdc install entry-default-signed.hap
   ```

---

## 第三步：测试连接

### 1. 启动服务器（在鸿蒙设备上）
```bash
# 方式一：在设备上直接打开应用
# 方式二：通过命令启动
hdc shell aa start -a EntryAbility -b com.example.scrcpyserver
```

### 2. 连接投屏（在 Windows 上）

#### 通过 USB 连接：
```cmd
cd C:\scrcpy
scrcpy
```

#### 通过网络连接：
```cmd
# 1. 端口转发
hdc fport tcp:27183 tcp:27183

# 2. 连接
scrcpy --tcpip
```

---

## 预期结果

✅ **Windows 上应该能看到手机画面**
✅ **鼠标可以在 Windows 上控制手机**
✅ **键盘可以输入文字**

---

## 如果遇到问题

### 问题 1：无法连接

**解决方案：**
```bash
# 1. 检查 hdc 连接
hdc list targets

# 2. 检查服务器是否启动
hdc shell hilog -T ScrcpyServer

# 3. 检查端口
hdc shell netstat -an | grep 27183
```

### 问题 2：画面卡顿

**解决方案：**
```cmd
# 降低分辨率和码率
scrcpy --max-size 1024 --video-bit-rate 4M

# 降低帧率
scrcpy --max-fps 30
```

### 问题 3：编译失败

**解决方案：**
1. 检查 SDK 版本是否为 6.0.2+
2. 检查签名配置
3. 清理并重新编译

---

## 开发调试

### 查看服务器日志

```bash
# 实时查看日志
hdc shell hilog -T ScrcpyServer

# 或者在 DevEco Studio 的 Hilog 窗口查看
```

### 修改代码后重新部署

```bash
# 1. 修改代码
# 2. 重新编译 HAP
# 3. 卸载旧版本
hdc uninstall com.example.scrcpyserver

# 4. 安装新版本
hdc install entry-default-signed.hap

# 5. 重启服务器
hdc shell aa start -a EntryAbility -b com.example.scrcpyserver
```

---

## 📊 我完成的工作

✅ **完整的鸿蒙服务器代码**（14 个文件，1981 行）
- 屏幕捕获服务
- 视频编码服务
- Socket 服务器
- 输入控制服务
- 协议兼容层
- 主程序逻辑

✅ **完整的文档**
- README.md - 使用指南
- 快速开始 - 本文档

✅ **Git 仓库**
- 已初始化并提交

---

## 🎯 你现在需要做的

1. **安装 DevEco Studio**（30 分钟）
2. **编译 HAP 包**（10 分钟）
3. **安装到手机并测试**（10 分钟）

---

## 💡 提示

- 第一次可能需要授权各种权限
- 建议先在 USB 连接下测试
- 确保手机和电脑在同一网络（如果用网络连接）

---

**准备好了吗？开始吧！** 🚀

如有问题，随时告诉我。

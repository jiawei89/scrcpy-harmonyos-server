# scrcpy 鸿蒙服务器

## 📋 项目简介

这是 **scrcpy** 服务器的 **HarmonyOS NEXT** 原生实现。

### 为什么需要这个项目？

原版 scrcpy 服务器是 Java 应用，依赖 Android API。**鸿蒙 NEXT 不支持 Java 应用**，因此必须用 ArkTS 重写整个服务器端。

### ⚠️ 重要说明

**当前版本仍处于开发阶段，存在以下已知限制：**

1. **屏幕捕获**: 使用 `AVScreenCaptureRecorder`，直接录制到文件，**不支持实时视频流传输**
2. **输入控制**: HarmonyOS API 12 (6.0.2) 的 `@kit.InputKit` **未提供** `inputEventClient`，无法注入输入事件
3. **架构差异**: 与原版 Android 版本有显著差异，需要重新设计架构

### 功能特性

| 功能 | 状态 | 说明 |
|------|------|------|
| 屏幕捕获 | ⚠️ 部分支持 | 使用 `AVScreenCaptureRecorder` 录制到文件 |
| 视频编码 | ⚠️ 部分支持 | 内置 H.264 编码，但无法实时获取流 |
| Socket 通信 | ✅ 支持 | 可与客户端建立连接 |
| 输入控制 | ❌ 暂不支持 | API 12 未提供事件注入接口 |
| 协议兼容 | ⚠️ 部分兼容 | 设备信息消息兼容，视频流不兼容 |

---

## 🏗️ 项目结构

```
harmonyos-server/
├── entry/src/main/
│   ├── ets/                          # ArkTS 源码
│   │   ├── entryability/
│   │   │   └── EntryAbility.ets      # 主入口
│   │   ├── services/
│   │   │   ├── ScreenCaptureService.ets     # 屏幕捕获（使用 AVScreenCaptureRecorder）
│   │   │   ├── VideoEncoderService.ets      # 视频编码（占位，实际由 ScreenCapture 处理）
│   │   │   ├── SocketServer.ets             # Socket 服务（使用 TCPSocketServer）
│   │   │   └── InputController.ets          # 输入控制（暂时占位）
│   │   ├── models/
│   │   │   ├── Options.ets                  # 配置
│   │   │   └── Message.ets                  # 消息协议
│   │   └── utils/
│   │       └── Logger.ets                   # 日志
│   ├── resources/
│   │   └── base/element/string.json
│   └── module.json5                        # 模块配置
└── oh-package.json5
```

---

## 🛠️ 开发环境

### 必需工具

1. **DevEco Studio 5.0+**
   - 下载：https://developer.huawei.com/consumer/cn/deveco-studio/
   - 需要 HarmonyOS SDK 6.0.2 (API 12)

2. **Node.js 16+** (如果需要构建工具)

3. **Git**

### 环境配置

1. 安装 DevEco Studio
2. 安装 HarmonyOS SDK 6.0.2
3. 配置签名证书（用于真机调试）
4. 打开本项目

---

## 📦 编译步骤

### 方式一：DevEco Studio GUI

1. **打开项目**
   ```
   File → Open → 选择 harmonyos-server 目录
   ```

2. **配置签名**
   ```
   File → Project Structure → Signing Configs
   ```

3. **编译项目**
   ```
   Build → Build Hap(s) / APP(s) → Build Hap(s)
   ```

4. **生成安装包**
   ```
   entry → build → outputs → default → entry-default-signed.hap
   ```

### 方式二：命令行编译

```bash
# 进入项目目录
cd harmonyos-server

# 清理构建
hvigorw clean

# 编译 HAP
hvigorw assembleHap

# 输出位置
# entry/build/default/outputs/default/entry-default-signed.hap
```

---

## 🚀 安装与运行

### 真机安装

1. **启用开发者模式**
   - 设置 → 关于手机 → 连续点击"版本号" 7 次
   - 设置 → 开发者选项 → USB 调试（开启）

2. **安装 HAP**
   ```bash
   # 使用 hdc 命令
   hdc install entry-default-signed.hap

   # 或者在 DevEco Studio 中
   # Run → Run 'entry'
   ```

3. **启动应用**
   ```bash
   hdc shell aa start -a EntryAbility -b com.example.scrcpyserver
   ```

### 模拟器运行

1. 在 DevEco Studio 中创建鸿蒙模拟器
2. 点击 Run 按钮

---

## 📊 HarmonyOS API 12 限制

### 屏幕捕获限制

原版 scrcpy 使用 Android 的 `ScreenCapture` API 获取实时视频帧，但 HarmonyOS API 12 的 `AVScreenCaptureRecorder` 设计不同：

| 特性 | Android (原版) | HarmonyOS API 12 |
|------|----------------|------------------|
| API | `ScreenCapture` | `AVScreenCaptureRecorder` |
| 输出方式 | 实时视频帧回调 | 直接录制到文件 |
| 视频流 | 支持 | **不支持** |
| 实时传输 | 支持 | **不支持** |

**可能的工作方案**：
1. 录制到临时文件，然后循环读取文件内容发送（有延迟）
2. 使用截图 API + 编码（性能较差）
3. 等待华为官方提供实时屏幕捕获 API

### 输入控制限制

HarmonyOS API 12 的 `@kit.InputKit` **未提供** `inputEventClient` 注入功能：

| 功能 | Android (原版) | HarmonyOS API 12 |
|------|----------------|------------------|
| 触摸注入 | ✅ `InputManager.injectInputEvent` | ❌ 无公开 API |
| 键盘注入 | ✅ `InputManager.injectInputEvent` | ❌ 无公开 API |
| 鼠标注入 | ✅ `InputManager.injectInputEvent` | ❌ 无公开 API |

**可能的工作方案**：
1. 使用 Native C API (`OH_Input_InjectTouchEvent` 等) - 需要 C++ 开发
2. 通过 Accessibility 服务 - 需要特殊权限
3. 等待华为官方提供 ArkTS JavaScript API

---

## 🎯 开发进度

### 已完成 ✅
- [x] 项目结构搭建
- [x] 配置文件适配（SDK 6.0.2）
- [x] Logger 日志工具
- [x] Message 协议定义
- [x] Options 配置管理
- [x] SocketServer 网络服务（使用 TCPSocketServer）
- [x] ScreenCaptureService 屏幕捕获（使用 AVScreenCaptureRecorder，但仅录制到文件）
- [x] VideoEncoderService 占位服务（实际编码由 ScreenCapture 处理）
- [x] InputController 占位服务（API 不支持事件注入）

### 当前限制 ⚠️
- [ ] 实时视频流传输（架构限制，需要重新设计）
- [ ] 输入事件注入（API 限制，需要使用 Native API）

### 进行中 ⏳
- [ ] 架构重新设计（支持实时流传输）
- [ ] Native C++ 输入注入模块

### 计划中 📋
- [ ] 音频捕获
- [ ] 剪贴板同步
- [ ] 性能优化
- [ ] 真机测试
- [ ] UI 界面

---

## 🔍 技术实现细节

### Socket 通信

使用 `socket.constructTCPSocketServerInstance()` 创建服务器：

```typescript
import { socket } from '@kit.NetworkKit';

let tcpServer = socket.constructTCPSocketServerInstance();
tcpServer.on('connect', (client: socket.TCPSocketConnection) => {
  client.on('message', (data: socket.SocketMessageInfo) => {
    // 处理接收到的数据
  });
});
```

### 屏幕捕获

使用 `media.createAVScreenCaptureRecorder()`：

```typescript
import { media } from '@kit.MediaKit';

let screenCapture = await media.createAVScreenCaptureRecorder();
await screenCapture.init(config);
await screenCapture.startRecording();
```

**注意**：此方法直接录制到文件，无法获取实时视频帧。

---

## 🐛 已知问题

### 架构层面

1. **视频流传输**
   - `AVScreenCaptureRecorder` 不支持实时回调
   - 需要重新设计架构才能实现类似原版 scrcpy 的功能

2. **输入注入**
   - `@kit.InputKit` 未提供 `inputEventClient`
   - 可能需要使用 Native C API

### API 差异

1. **Socket API**
   - HarmonyOS 的 `TCPSocketServer` 与 Java 的 `ServerSocket` 不同
   - 需要使用事件监听而非阻塞调用

2. **屏幕捕获 API**
   - `AVScreenCaptureRecorder` 设计为文件录制
   - 与原版 `ScreenCapture` 的实时帧回调模式不同

---

## 🔍 调试

### 查看日志

```bash
# 使用 hdc 查看应用日志
hdc shell hilog -T ScrcpyServer

# 或者在 DevEco Studio 的 Hilog 窗口中查看
```

### 常见问题

**Q: 编译失败？**
- 检查 SDK 版本是否为 6.0.2 (API 12)
- 检查签名配置是否正确

**Q: 无法连接？**
- 确认网络端口是否开放 (27183)
- 检查防火墙设置

**Q: 视频流无输出？**
- 这是已知限制，`AVScreenCaptureRecorder` 录制到文件而非实时流
- 需要等待架构重新设计

**Q: 输入无响应？**
- 这是已知限制，API 12 未提供事件注入接口
- 需要使用 Native C API 或等待官方支持

---

## 📚 参考资料

- [scrcpy 官方仓库](https://github.com/Genymobile/scrcpy)
- [HarmonyOS API 12 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/)
- [DevEco Studio 文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-studio)
- [AVScreenCaptureRecorder API](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/js-apis-media-AVScreenCaptureRecorder)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

特别欢迎：
- Native C++ 输入注入实现
- 实时视频流传输方案
- 架构优化建议

---

## 📄 许可证

Apache License 2.0

---

**开发者**: 小如💻
**创建日期**: 2026-03-10
**支持版本**: HarmonyOS 6.0.2+ (API 12)
**当前状态**: 开发阶段，存在已知限制

---

## 附录：API 兼容性对比

### Android vs HarmonyOS API 12

| 功能 | Android API | HarmonyOS API 12 | 兼容性 |
|------|-------------|------------------|--------|
| 屏幕捕获 | `ScreenCapture` | `AVScreenCaptureRecorder` | ⚠️ 不同设计 |
| 视频编码 | `MediaCodec` | 内置于录制器 | ⚠️ 不同设计 |
| Socket 服务 | `ServerSocket` | `TCPSocketServer` | ⚠️ API 差异 |
| 触摸注入 | `InputManager` | ❌ 无公开 API | ❌ 不支持 |
| 键盘注入 | `InputManager` | ❌ 无公开 API | ❌ 不支持 |
| 鼠标注入 | `InputManager` | ❌ 无公开 API | ❌ 不支持 |

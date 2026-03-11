/**
 * EntryAbility.ets
 * scrcpy 鸿蒙服务器主入口
 *
 * 这是 scrcpy 服务器的鸿蒙版本实现
 * 功能：
 * 1. 捕获屏幕画面
 * 2. 编码为 H.264 视频流
 * 3. 通过 Socket 发送到 Windows 客户端
 * 4. 接收客户端的控制消息（触摸、键盘等）
 * 5. 注入输入事件到系统
 */

import { AbilityConstant, UIAbility, Want, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ScreenCaptureService, type DisplayInfo } from '../services/ScreenCaptureService';
import { VideoEncoderService, type EncodedFrame } from '../services/VideoEncoderService';
import { SocketServer } from '../services/SocketServer';
import { InputController } from '../services/InputController';
import { Options } from '../models/Options';
import { Logger, LogLevel } from '../utils/Logger';
import {
  parseControlMessage,
  ControlMessageType,
  TouchEventMessage,
  KeyEventMessage,
  TextMessage,
  ClipboardMessage,
  ScrollEventMessage,
  DeviceInfo,
  encodeDeviceInfo,
  createDeviceMessage,
  DeviceMessageType
} from '../models/Message';

const TAG = 'ScrcpyServer';

export default class EntryAbility extends UIAbility {
  // 核心服务
  private screenCapture: ScreenCaptureService;
  private videoEncoder: VideoEncoderService = new VideoEncoderService();
  private socketServer: SocketServer = new SocketServer({ port: 27183 });
  private inputController: InputController = new InputController();

  // 配置
  private options: Options = new Options();

  // 状态
  private isRunning: boolean = false;
  private displayInfo?: DisplayInfo;

  constructor() {
    super();
    // 延迟初始化 ScreenCaptureService，需要 context
    this.screenCapture = new ScreenCaptureService();
  }

  /**
   * 应用启动
   */
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    Logger.info(TAG, 'scrcpy-server for HarmonyOS starting...');

    // 设置 ScreenCaptureService 的 context
    this.screenCapture.setContext(this.context);

    // 从 Want 参数中读取配置
    if (want.parameters) {
      this.parseOptions(want.parameters);
    }

    try {
      // 初始化
      await this.initialize();

      // 启动服务
      await this.start();

      Logger.info(TAG, 'scrcpy-server started successfully');

    } catch (error) {
      Logger.error(TAG, 'Failed to start server: ' + String(error));
      this.cleanup();
    }
  }

  /**
   * 应用销毁
   */
  onDestroy(): void {
    Logger.info(TAG, 'Destroying scrcpy-server...');
    this.cleanup();
  }

  /**
   * 前台
   */
  onForeground(): void {
    Logger.info(TAG, 'App in foreground');
  }

  /**
   * 后台
   */
  onBackground(): void {
    Logger.info(TAG, 'App in background');
  }

  /**
   * 配置更新
   */
  onConfigurationUpdate(newConfig: Configuration): void {
    Logger.info(TAG, 'Configuration updated');
  }

  /**
   * 初始化所有服务
   */
  private async initialize(): Promise<void> {
    Logger.info(TAG, 'Initializing services...');

    // 初始化屏幕捕获
    Logger.info(TAG, 'Initializing screen capture...');
    this.displayInfo = await this.screenCapture.init(this.options.getDisplayId());
    Logger.info(TAG, `Display: ${this.displayInfo.width}x${this.displayInfo.height}`);

    // 初始化视频编码器
    Logger.info(TAG, 'Initializing video encoder...');
    await this.videoEncoder.init({
      width: this.displayInfo.width,
      height: this.displayInfo.height,
      videoBitrate: this.options.getVideoBitrate(),
      frameRate: this.options.getMaxFps()
    });

    // 设置编码输出回调
    this.videoEncoder.onOutputAvailable(async (frame) => {
      await this.onVideoFrameEncoded(frame);
    });

    Logger.info(TAG, 'All services initialized');
  }

  /**
   * 启动服务
   */
  private async start(): Promise<void> {
    this.isRunning = true;

    // 启动 Socket 服务器
    Logger.info(TAG, 'Starting socket server...');
    await this.socketServer.start();
    Logger.info(TAG, 'Waiting for client connection...');

    // 等待客户端连接
    await this.socketServer.acceptClient();
    Logger.info(TAG, 'Client connected!');

    // 发送设备信息
    await this.sendDeviceInfo();

    // 开始屏幕捕获和编码
    Logger.info(TAG, 'Starting screen capture...');
    await this.screenCapture.start();
    await this.videoEncoder.start();

    // 处理屏幕帧
    this.screenCapture.onFrameAvailable(async (frame) => {
      if (this.isRunning) {
        await this.videoEncoder.encodeFrame(frame);
      }
    });

    // 处理客户端控制消息
    this.handleControlMessages();
  }

  /**
   * 发送设备信息
   */
  private async sendDeviceInfo(): Promise<void> {
    const deviceInfo: DeviceInfo = {
      width: this.displayInfo!.width,
      height: this.displayInfo!.height,
      rotatedWidth: this.displayInfo!.width,  // 简化处理
      rotatedHeight: this.displayInfo!.height,
      dpi: Math.round(this.displayInfo!.density * 160)
    };

    const buffer = encodeDeviceInfo(deviceInfo);
    await this.socketServer.sendData(buffer);

    Logger.info(TAG, `Device info sent: ${deviceInfo.width}x${deviceInfo.height}`);
  }

  /**
   * 视频帧编码完成回调
   */
  private async onVideoFrameEncoded(frame: EncodedFrame): Promise<void> {
    if (!this.isRunning) {
      return;
    }

    try {
      // 直接发送 H.264 数据
      await this.socketServer.sendData(frame.data);

      // if (frame.isKeyFrame) {
      //   Logger.debug(TAG, 'Key frame sent');
      // }

    } catch (error) {
      Logger.error(TAG, 'Failed to send video frame: ' + String(error));
    }
  }

  /**
   * 处理客户端控制消息
   */
  private async handleControlMessages(): Promise<void> {
    while (this.isRunning) {
      try {
        const data = await this.socketServer.receiveData();
        await this.processControlMessage(data);

      } catch (error) {
        if (this.isRunning) {
          Logger.error(TAG, 'Error handling control message: ' + String(error));
        }
        break;
      }
    }
  }

  /**
   * 处理控制消息
   */
  private async processControlMessage(buffer: ArrayBuffer): Promise<void> {
    try {
      const parsed = parseControlMessage(buffer);
      const type = parsed.type;
      const payload = parsed.payload;

      switch (type) {
        case ControlMessageType.TYPE_INJECT_TOUCH_EVENT:
          await this.handleTouchEvent(payload);
          break;

        case ControlMessageType.TYPE_INJECT_KEYCODE:
          await this.handleKeyEvent(payload);
          break;

        case ControlMessageType.TYPE_INJECT_TEXT:
          await this.handleTextEvent(payload);
          break;

        case ControlMessageType.TYPE_INJECT_SCROLL_EVENT:
          await this.handleScrollEvent(payload);
          break;

        case ControlMessageType.TYPE_SET_CLIPBOARD:
          await this.handleSetClipboard(payload);
          break;

        case ControlMessageType.TYPE_GET_CLIPBOARD:
          // TODO: 实现获取剪贴板
          break;

        default:
          Logger.warn(TAG, `Unknown message type: ${type}`);
      }

    } catch (error) {
      Logger.error(TAG, 'Failed to process control message: ' + (error instanceof Error ? error.message : String(error)));
    }
  }

  /**
   * 处理触摸事件
   */
  private async handleTouchEvent(buffer: ArrayBuffer): Promise<void> {
    const msg = TouchEventMessage.fromBuffer(buffer);

    const action = msg.action === 0 ? 'UP' : msg.action === 1 ? 'DOWN' : 'MOVE';

    await this.inputController.injectTouchEvent({
      id: msg.pointerId,
      action: action,
      x: msg.position.x,
      y: msg.position.y,
      pressure: msg.pressure
    });
  }

  /**
   * 处理键盘事件
   */
  private async handleKeyEvent(buffer: ArrayBuffer): Promise<void> {
    const msg = KeyEventMessage.fromBuffer(buffer);

    const action = msg.action === 0 ? 'UP' : 'DOWN';

    await this.inputController.injectKeyEvent({
      code: msg.keyCode,
      action: action,
      repeat: msg.repeat
    });
  }

  /**
   * 处理文本事件
   */
  private async handleTextEvent(buffer: ArrayBuffer): Promise<void> {
    const msg = TextMessage.fromBuffer(buffer);

    // 逐字符输入
    for (const char of msg.text) {
      // TODO: 将字符转换为按键码
      // 这里需要实现字符到按键码的映射
      Logger.debug(TAG, `Injecting text: ${char}`);
    }
  }

  /**
   * 处理滚动事件
   */
  private async handleScrollEvent(buffer: ArrayBuffer): Promise<void> {
    const msg = ScrollEventMessage.fromBuffer(buffer);

    await this.inputController.injectScrollEvent(
      msg.position.x,
      msg.position.y,
      msg.hScroll,
      msg.vScroll
    );
  }

  /**
   * 处理设置剪贴板
   */
  private async handleSetClipboard(buffer: ArrayBuffer): Promise<void> {
    const msg = ClipboardMessage.fromBuffer(buffer);

    // TODO: 实现设置剪贴板
    Logger.debug(TAG, `Set clipboard: ${msg.text}`);
  }

  /**
   * 解析配置
   */
  private parseOptions(parameters: ESObject): void {
    // 从 Want 参数中解析配置
    // 这里可以添加更多配置项
    if (typeof parameters['logLevel'] === 'string') {
      const levelStr = parameters['logLevel'] as string;
      switch (levelStr) {
        case 'debug':
          Logger.setLevel(LogLevel.DEBUG);
          break;
        case 'info':
          Logger.setLevel(LogLevel.INFO);
          break;
        case 'warn':
          Logger.setLevel(LogLevel.WARN);
          break;
        case 'error':
          Logger.setLevel(LogLevel.ERROR);
          break;
      }
    }
  }

  /**
   * 清理资源
   */
  private cleanup(): void {
    this.isRunning = false;

    Logger.info(TAG, 'Cleaning up resources...');

    this.screenCapture.stop();
    this.screenCapture.release();

    this.videoEncoder.stop();
    this.videoEncoder.release();

    this.socketServer.close();

    Logger.info(TAG, 'Cleanup completed');
  }
}

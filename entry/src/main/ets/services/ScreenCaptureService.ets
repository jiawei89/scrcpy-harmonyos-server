/**
 * ScreenCaptureService.ets
 * 鸿蒙屏幕捕获服务
 * 对应 Android 的 ScreenCapture.java
 */

import { image } from '@kit.ImageKit';
import { display } from '@kit.ArkUI';
import { media } from '@kit.MediaKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';

export interface DisplayInfo {
  id: number;
  width: number;
  height: number;
  density: number;
  rotation: number;
}

export interface ScreenConfig {
  videoBitrate?: number;
  frameWidth?: number;
  frameHeight?: number;
  frameRate?: number;
}

export class ScreenCaptureService {
  private screenCapture?: media.AVScreenCaptureRecorder;
  private config: media.AVScreenCaptureRecordConfig;
  private isCapturing: boolean = false;
  private frameCallback?: (buffer: ArrayBuffer) => void;
  private context?: common.UIAbilityContext;
  private captureFile?: fs.File;

  constructor(context?: common.UIAbilityContext) {
    this.context = context;
    this.config = {
      frameWidth: 1920,
      frameHeight: 1080,
      videoBitrate: 8000000,
      audioSampleRate: 48000,
      audioChannelCount: 2,
      audioBitrate: 128000,
      displayId: 0,
      preset: media.AVScreenCaptureRecordPreset.SCREEN_RECORD_PRESET_H264_AAC_MP4,
      fd: -1  // 临时值，实际使用时会更新
    };
  }

  /**
   * 初始化屏幕捕获
   */
  async init(displayId: number = 0, config?: ScreenConfig): Promise<DisplayInfo> {
    try {
      // 获取屏幕信息
      const displayInfo = display.getDefaultDisplaySync();

      // 构建配置
      this.config.frameWidth = config?.frameWidth || displayInfo.width;
      this.config.frameHeight = config?.frameHeight || displayInfo.height;
      this.config.videoBitrate = config?.videoBitrate || 8000000;
      this.config.displayId = displayId;
      this.config.audioSampleRate = 48000;
      this.config.audioChannelCount = 2;
      this.config.audioBitrate = 128000;
      this.config.preset = media.AVScreenCaptureRecordPreset.SCREEN_RECORD_PRESET_H264_AAC_MP4;

      // 创建屏幕捕获实例
      this.screenCapture = await media.createAVScreenCaptureRecorder();

      // 打开临时文件用于录制
      if (this.context) {
        const path = this.context.filesDir + '/temp_capture.mp4';
        this.captureFile = fs.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        this.config.fd = this.captureFile.fd;
      }

      await this.screenCapture.init(this.config);

      console.log(`ScreenCapture initialized: ${displayInfo.width}x${displayInfo.height}`);

      return {
        id: displayInfo.id,
        width: displayInfo.width,
        height: displayInfo.height,
        density: displayInfo.densityDPI,
        rotation: displayInfo.rotation
      };
    } catch (error) {
      console.error('Failed to initialize screen capture:', error);
      throw new Error(`Failed to initialize screen capture: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 开始捕获
   */
  async start(): Promise<void> {
    if (!this.screenCapture) {
      throw new Error('ScreenCapture not initialized');
    }

    try {
      await this.screenCapture.startRecording();
      this.isCapturing = true;
      console.log('ScreenCapture started');

      // 注册状态变化回调
      this.screenCapture.on('stateChange', (state: media.AVScreenCaptureStateCode) => {
        if (state === media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STARTED) {
          console.log('Screen capture started successfully');
        } else if (state === media.AVScreenCaptureStateCode.SCREENCAPTURE_STATE_STOPPED_BY_USER) {
          this.isCapturing = false;
          console.log('Screen capture stopped by user');
        }
      });

      this.screenCapture.on('error', (error: Error) => {
        console.error('Screen capture error:', error);
        this.isCapturing = false;
      });

    } catch (error) {
      console.error('Failed to start screen capture:', error);
      throw new Error(`Failed to start screen capture: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 停止捕获
   */
  async stop(): Promise<void> {
    if (this.screenCapture && this.isCapturing) {
      try {
        await this.screenCapture.stopRecording();
        this.isCapturing = false;
        console.log('ScreenCapture stopped');
      } catch (error) {
        console.error('Failed to stop screen capture:', error);
      }
    }
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    if (this.screenCapture) {
      try {
        await this.screenCapture.release();
        this.screenCapture = undefined;
        console.log('ScreenCapture released');
      } catch (error) {
        console.error('Failed to release screen capture:', error);
      }
    }

    if (this.captureFile) {
      try {
        fs.closeSync(this.captureFile);
        this.captureFile = undefined;
      } catch (error) {
        console.error('Failed to close capture file:', error);
      }
    }
  }

  /**
   * 注册帧回调（注意：AVScreenCaptureRecorder 不支持实时帧回调，此接口保留但可能不工作）
   */
  onFrameAvailable(callback: (buffer: ArrayBuffer) => void): void {
    this.frameCallback = callback;
    console.warn('AVScreenCaptureRecorder does not support real-time frame callback');
  }

  /**
   * 获取当前状态
   */
  isActive(): boolean {
    return this.isCapturing;
  }

  /**
   * 设置捕获参数
   */
  async setConfig(config: Partial<ScreenConfig>): Promise<void> {
    if (this.isCapturing) {
      throw new Error('Cannot change config while capturing');
    }

    if (config.frameWidth) this.config.frameWidth = config.frameWidth;
    if (config.frameHeight) this.config.frameHeight = config.frameHeight;
    if (config.videoBitrate) this.config.videoBitrate = config.videoBitrate;

    // 重新初始化
    if (this.screenCapture) {
      await this.release();
      await this.init(this.config.displayId, { frameWidth: this.config.frameWidth, frameHeight: this.config.frameHeight, videoBitrate: this.config.videoBitrate });
    }
  }

  /**
   * 设置上下文
   */
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }
}

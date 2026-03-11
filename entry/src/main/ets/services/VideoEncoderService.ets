/**
 * VideoEncoderService.ets
 * 鸿蒙视频编码服务
 *
 * 注意：HarmonyOS API 12 中，AVScreenCaptureRecorder 已经内置了视频编码功能
 * 这个服务主要用于兼容性保留，实际编码由 ScreenCaptureService 处理
 */

export interface EncoderConfig {
  width: number;
  height: number;
  frameRate?: number;
  videoBitrate?: number;
}

export interface EncodedFrame {
  data: ArrayBuffer;
  isKeyFrame: boolean;
  presentationTimeUs: number;
}

export class VideoEncoderService {
  private config: EncoderConfig = {
    width: 1920,
    height: 1080,
    frameRate: 60,
    videoBitrate: 8000000
  };
  private isEncoding: boolean = false;
  private outputCallback?: (frame: EncodedFrame) => void;

  /**
   * 初始化视频编码器
   * 注意：在 HarmonyOS API 12 中，实际编码由 AVScreenCaptureRecorder 处理
   */
  async init(config: EncoderConfig): Promise<void> {
    this.config = {
      width: config.width,
      height: config.height,
      frameRate: config.frameRate || 60,
      videoBitrate: config.videoBitrate || 8000000
    };

    console.log(`VideoEncoder initialized: ${this.config.width}x${this.config.height} @ ${this.config.frameRate}fps`);
    console.warn('In HarmonyOS API 12, actual video encoding is handled by AVScreenCaptureRecorder');
  }

  /**
   * 开始编码
   */
  async start(): Promise<void> {
    this.isEncoding = true;
    console.log('VideoEncoder started (encoding handled by AVScreenCaptureRecorder)');
  }

  /**
   * 编码一帧
   * 注意：此方法保留用于兼容性，但实际编码由 AVScreenCaptureRecorder 处理
   */
  async encodeFrame(frame: ArrayBuffer, timestamp: number = Date.now() * 1000): Promise<void> {
    if (!this.isEncoding) {
      throw new Error('Encoder not ready');
    }

    // 实际编码由 AVScreenCaptureRecorder 处理
    // 这个方法保留用于兼容性
  }

  /**
   * 请求关键帧
   */
  async requestKeyFrame(): Promise<void> {
    if (!this.isEncoding) {
      return;
    }

    console.log('Key frame requested (handled by AVScreenCaptureRecorder)');
  }

  /**
   * 停止编码
   */
  async stop(): Promise<void> {
    if (this.isEncoding) {
      this.isEncoding = false;
      console.log('VideoEncoder stopped');
    }
  }

  /**
   * 释放资源
   */
  async release(): Promise<void> {
    this.isEncoding = false;
    console.log('VideoEncoder released');
  }

  /**
   * 注册输出回调
   */
  onOutputAvailable(callback: (frame: EncodedFrame) => void): void {
    this.outputCallback = callback;
    console.warn('In HarmonyOS API 12, encoded frames are output by AVScreenCaptureRecorder to file');
  }

  /**
   * 获取当前状态
   */
  isActive(): boolean {
    return this.isEncoding;
  }

  /**
   * 设置码率
   */
  async setBitrate(bitrate: number): Promise<void> {
    if (this.isEncoding) {
      this.config.videoBitrate = bitrate;
      console.log(`Bitrate changed to ${bitrate}`);
    }
  }

  /**
   * 设置帧率
   */
  async setFrameRate(frameRate: number): Promise<void> {
    if (!this.isEncoding) {
      this.config.frameRate = frameRate;
    }
  }
}

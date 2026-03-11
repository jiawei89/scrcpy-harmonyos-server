/**
 * Options.ets
 * 配置选项
 */

export interface CropRect {
  left: number;
  top: number;
  right: number;
  bottom: number;
}

export interface VideoCodecOption {
  key: string;
  value: number;
}

export interface ServerOptions {
  displayId?: number;
  maxSize?: number;
  crop?: CropRect;
  videoBitrate?: number;
  maxFps?: number;
  videoCodec?: string;
  videoEncoder?: string;
  videoCodecOptions?: VideoCodecOption[];
  audio?: boolean;
  audioBitrate?: number;
  audioCodec?: string;
  control?: boolean;
  turnScreenOff?: boolean;
  keepAwake?: boolean;
  downsizeOnError?: boolean;
  logLevel?: 'debug' | 'info' | 'warn' | 'error';
}

export class Options {
  private options: ServerOptions;

  constructor(options?: ServerOptions) {
    this.options = {
      displayId: options?.displayId ?? 0,
      maxSize: options?.maxSize ?? 0,
      videoBitrate: options?.videoBitrate ?? 8000000,
      maxFps: options?.maxFps ?? 60,
      videoCodec: options?.videoCodec ?? 'h264',
      videoEncoder: options?.videoEncoder ?? '',
      videoCodecOptions: options?.videoCodecOptions ?? [],
      audio: options?.audio ?? false,
      audioBitrate: options?.audioBitrate ?? 128000,
      audioCodec: options?.audioCodec ?? 'aac',
      control: options?.control ?? true,
      turnScreenOff: options?.turnScreenOff ?? false,
      keepAwake: options?.keepAwake ?? false,
      downsizeOnError: options?.downsizeOnError ?? true,
      logLevel: options?.logLevel ?? 'info',
    };
  }

  getDisplayId(): number {
    return this.options.displayId ?? 0;
  }

  getMaxSize(): number {
    return this.options.maxSize ?? 0;
  }

  getVideoBitrate(): number {
    return this.options.videoBitrate ?? 8000000;
  }

  getMaxFps(): number {
    return this.options.maxFps ?? 60;
  }

  getVideoCodec(): string {
    return this.options.videoCodec ?? 'h264';
  }

  getVideoEncoder(): string {
    return this.options.videoEncoder ?? '';
  }

  getVideoCodecOptions(): VideoCodecOption[] {
    return this.options.videoCodecOptions ?? [];
  }

  getAudio(): boolean {
    return this.options.audio ?? false;
  }

  getAudioBitrate(): number {
    return this.options.audioBitrate ?? 128000;
  }

  getAudioCodec(): string {
    return this.options.audioCodec ?? 'aac';
  }

  getControl(): boolean {
    return this.options.control ?? true;
  }

  getTurnScreenOff(): boolean {
    return this.options.turnScreenOff ?? false;
  }

  getKeepAwake(): boolean {
    return this.options.keepAwake ?? false;
  }

  getDownsizeOnError(): boolean {
    return this.options.downsizeOnError ?? true;
  }

  getLogLevel(): 'debug' | 'info' | 'warn' | 'error' {
    return this.options.logLevel ?? 'info';
  }

  static fromArgs(args: string[]): Options {
    const options: ServerOptions = {};

    for (let i = 0; i < args.length; i++) {
      const arg = args[i];

      switch (arg) {
        case '--display-id':
          options.displayId = parseInt(args[++i]);
          break;
        case '--max-size':
          options.maxSize = parseInt(args[++i]);
          break;
        case '--video-bit-rate':
          options.videoBitrate = parseInt(args[++i]);
          break;
        case '--max-fps':
          options.maxFps = parseInt(args[++i]);
          break;
        case '--audio':
          options.audio = true;
          break;
        case '--no-control':
          options.control = false;
          break;
        case '--turn-screen-off':
          options.turnScreenOff = true;
          break;
        case '--keep-awake':
          options.keepAwake = true;
          break;
        case '--no-downsize-on-error':
          options.downsizeOnError = false;
          break;
      }
    }

    return new Options(options);
  }
}

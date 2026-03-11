/**
 * Logger.ets
 * 日志工具
 */
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

export class Logger {
  private static level: LogLevel = LogLevel.INFO;

  static setLevel(level: LogLevel): void {
    Logger.level = level;
  }

  static debug(tag: string, message: string): void {
    if (Logger.level <= LogLevel.DEBUG) {
      console.debug('[D/' + tag + '] ' + message);
    }
  }

  static info(tag: string, message: string): void {
    if (Logger.level <= LogLevel.INFO) {
      console.info('[I/' + tag + '] ' + message);
    }
  }

  static warn(tag: string, message: string): void {
    if (Logger.level <= LogLevel.WARN) {
      console.warn('[W/' + tag + '] ' + message);
    }
  }

  static error(tag: string, message: string): void {
    if (Logger.level <= LogLevel.ERROR) {
      console.error('[E/' + tag + '] ' + message);
    }
  }
}

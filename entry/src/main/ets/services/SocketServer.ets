/**
 * SocketServer.ets
 * Socket 服务器，用于与 Windows 客户端通信
 * 对应 Android 的 DesktopConnection.java
 */

import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

export interface ServerConfig {
  port?: number;
  host?: string;
}

export interface ServerStatus {
  listening: boolean;
  connected: boolean;
}

export class SocketServer {
  private server?: socket.TCPSocketServer;
  private clientConnection?: socket.TCPSocketConnection;
  private isListening: boolean = false;
  private config: ServerConfig;
  private connectCallback?: () => void;

  constructor(config?: ServerConfig) {
    this.config = {
      port: config?.port || 27183,
      host: config?.host || '0.0.0.0'
    };
  }

  /**
   * 启动服务器
   */
  async start(): Promise<void> {
    try {
      // 创建 TCPSocketServer 实例
      this.server = socket.constructTCPSocketServerInstance();

      // 绑定地址和端口并开始监听
      const listenAddr: socket.NetAddress = {
        address: this.config.host!,
        port: this.config.port!,
        family: 1
      };

      await new Promise<void>((resolve, reject) => {
        this.server!.listen(listenAddr, (err: BusinessError) => {
          if (err) {
            reject(new Error(`Listen failed: ${err.message}`));
          } else {
            resolve();
          }
        });
      });

      this.isListening = true;
      console.log(`SocketServer listening on ${this.config.host}:${this.config.port}`);

    } catch (error) {
      console.error('Failed to start server:', error);
      throw new Error(`Failed to start server: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 等待客户端连接
   */
  async acceptClient(): Promise<void> {
    if (!this.server || !this.isListening) {
      throw new Error('Server not listening');
    }

    try {
      console.log('Waiting for client connection...');

      // 使用 Promise 包装连接事件
      await new Promise<void>((resolve, reject) => {
        const timeoutId = setTimeout(() => {
          reject(new Error('Connection timeout'));
        }, 30000);

        this.server!.on('connect', (connection: socket.TCPSocketConnection) => {
          clearTimeout(timeoutId);
          this.clientConnection = connection;
          console.log('Client connected');
          resolve();
        });
      });

    } catch (error) {
      console.error('Failed to accept client:', error);
      throw new Error(`Failed to accept client: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 发送数据到客户端
   */
  async sendData(data: ArrayBuffer): Promise<void> {
    if (!this.clientConnection) {
      throw new Error('No client connected');
    }

    try {
      const sendOptions: socket.TCPSendOptions = {
        data: new Uint8Array(data)
      };

      await this.clientConnection.send(sendOptions);

    } catch (error) {
      console.error('Failed to send data:', error);
      throw new Error(`Failed to send data: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 接收客户端数据
   */
  async receiveData(): Promise<ArrayBuffer> {
    if (!this.clientConnection) {
      throw new Error('No client connected');
    }

    try {
      // 使用 on('message') 监听接收数据
      return new Promise<ArrayBuffer>((resolve, reject) => {
        const timeoutId = setTimeout(() => {
          this.clientConnection?.off('message');
          reject(new Error('Receive timeout'));
        }, 30000);

        this.clientConnection!.on('message', (data: socket.SocketMessageInfo) => {
          clearTimeout(timeoutId);
          this.clientConnection?.off('message');
          resolve(data.message);
        });
      });

    } catch (error) {
      console.error('Failed to receive data:', error);
      throw new Error(`Failed to receive data: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  /**
   * 关闭客户端连接
   */
  async closeClient(): Promise<void> {
    if (this.clientConnection) {
      try {
        await this.clientConnection.close();
        this.clientConnection = undefined;
        console.log('Client connection closed');
      } catch (error) {
        console.error('Failed to close client:', error);
      }
    }
  }

  /**
   * 关闭服务器
   */
  async close(): Promise<void> {
    await this.closeClient();

    if (this.server) {
      try {
        await this.server.close();
        this.server = undefined;
        this.isListening = false;
        console.log('Server closed');
      } catch (error) {
        console.error('Failed to close server:', error);
      }
    }
  }

  /**
   * 检查是否有客户端连接
   */
  hasClient(): boolean {
    return this.clientConnection !== undefined;
  }

  /**
   * 获取服务器状态
   */
  getStatus(): ServerStatus {
    return {
      listening: this.isListening,
      connected: this.clientConnection !== undefined
    };
  }
}

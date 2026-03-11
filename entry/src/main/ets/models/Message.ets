/**
 * Message.ets
 * scrcpy 协议消息定义
 */

// Position interface
export interface Position {
  x: number;
  y: number;
}

// TextEncoder/TextDecoder helper class
class TextDecoderHelper {
  decode(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let result = '';
    for (let i = 0; i < bytes.length; i++) {
      result += String.fromCharCode(bytes[i]);
    }
    return result;
  }
}

class TextEncoderHelper {
  encode(str: string): Uint8Array {
    const utf8 = unescape(encodeURIComponent(str));
    return new Uint8Array(Array.from(utf8).map((c: string): number => c.charCodeAt(0)));
  }
}

const textDecoder = new TextDecoderHelper();
const textEncoder = new TextEncoderHelper();

export enum ControlMessageType {
  TYPE_INJECT_KEYCODE = 0,
  TYPE_INJECT_TEXT = 1,
  TYPE_INJECT_TOUCH_EVENT = 2,
  TYPE_INJECT_SCROLL_EVENT = 3,
  TYPE_BACK_OR_SCREEN_ON = 4,
  TYPE_EXPAND_NOTIFICATION_PANEL = 5,
  TYPE_EXPAND_SETTINGS_PANEL = 6,
  TYPE_COLLAPSE_PANELS = 7,
  TYPE_GET_CLIPBOARD = 8,
  TYPE_SET_CLIPBOARD = 9,
  TYPE_SET_SCREEN_POWER_MODE = 10,
  TYPE_ROTATE_DEVICE = 11,
}

export enum DeviceMessageType {
  TYPE_CLIPBOARD = 0,
  TYPE_ACK_CLIPBOARD = 1,
  TYPE_ACK = 2,
}

export enum TouchAction {
  UP = 0,
  DOWN = 1,
  MOVE = 2,
  CANCEL = 3,
}

export enum KeyAction {
  UP = 0,
  DOWN = 1,
}

export enum ScreenPowerMode {
  OFF = 0,
  ON = 1,
}

export class TouchEventMessage {
  action: TouchAction = TouchAction.DOWN;
  pointerId: number = 0;
  position: Position = { x: 0, y: 0 };
  pressure: number = 1.0;
  buttons: number = 0;

  static fromBuffer(buffer: ArrayBuffer): TouchEventMessage {
    const view = new DataView(buffer);
    const msg = new TouchEventMessage();

    let offset = 0;
    msg.action = view.getUint8(offset++);
    msg.pointerId = view.getInt32(offset, true);
    offset += 4;
    msg.position.x = view.getFloat64(offset, true);
    offset += 8;
    msg.position.y = view.getFloat64(offset, true);
    offset += 8;
    msg.pressure = view.getFloat32(offset, true);
    offset += 4;
    msg.buttons = view.getUint16(offset, true);

    return msg;
  }
}

export class KeyEventMessage {
  action: KeyAction = KeyAction.DOWN;
  keyCode: number = 0;
  repeat: number = 0;
  metaState: number = 0;

  static fromBuffer(buffer: ArrayBuffer): KeyEventMessage {
    const view = new DataView(buffer);
    const msg = new KeyEventMessage();

    let offset = 0;
    msg.action = view.getUint8(offset++);
    msg.keyCode = view.getInt32(offset, true);
    offset += 4;
    msg.repeat = view.getInt32(offset, true);
    offset += 4;
    msg.metaState = view.getInt32(offset, true);

    return msg;
  }
}

export class TextMessage {
  text: string = '';

  static fromBuffer(buffer: ArrayBuffer): TextMessage {
    const msg = new TextMessage();
    msg.text = textDecoder.decode(buffer);
    return msg;
  }
}

export class ClipboardMessage {
  text: string = '';
  sequence: number = 0;

  static fromBuffer(buffer: ArrayBuffer): ClipboardMessage {
    const msg = new ClipboardMessage();
    const view = new DataView(buffer);

    let offset = 0;
    msg.sequence = Number(view.getBigInt64(offset, true));
    offset += 8;

    msg.text = textDecoder.decode(buffer.slice(offset));

    return msg;
  }

  toBuffer(): ArrayBuffer {
    const textBytes = textEncoder.encode(this.text);
    const buffer = new ArrayBuffer(8 + textBytes.length);
    const view = new DataView(buffer);

    view.setBigInt64(0, BigInt(this.sequence), true);
    new Uint8Array(buffer).set(textBytes, 8);

    return buffer;
  }
}

export class ScrollEventMessage {
  position: Position = { x: 0, y: 0 };
  hScroll: number = 0;
  vScroll: number = 0;

  static fromBuffer(buffer: ArrayBuffer): ScrollEventMessage {
    const view = new DataView(buffer);
    const msg = new ScrollEventMessage();

    let offset = 0;
    msg.position.x = view.getFloat64(offset, true);
    offset += 8;
    msg.position.y = view.getFloat64(offset, true);
    offset += 8;
    msg.hScroll = view.getInt32(offset, true);
    offset += 4;
    msg.vScroll = view.getInt32(offset, true);

    return msg;
  }
}

export interface DeviceInfo {
  width: number;
  height: number;
  rotatedWidth: number;
  rotatedHeight: number;
  dpi: number;
}

export interface ParsedControlMessage {
  type: ControlMessageType;
  payload: ArrayBuffer;
}

export function encodeDeviceInfo(info: DeviceInfo): ArrayBuffer {
  const buffer = new ArrayBuffer(8 * 4);
  const view = new DataView(buffer);

  let offset = 0;
  view.setInt32(offset, info.width, true);
  offset += 4;
  view.setInt32(offset, info.height, true);
  offset += 4;
  view.setInt32(offset, info.rotatedWidth, true);
  offset += 4;
  view.setInt32(offset, info.rotatedHeight, true);
  offset += 4;
  view.setInt32(offset, info.dpi, true);
  offset += 4;

  return buffer;
}

export function parseControlMessage(buffer: ArrayBuffer): ParsedControlMessage {
  const view = new DataView(buffer);
  const type = view.getUint8(0) as ControlMessageType;
  const payload = buffer.slice(1);

  const result: ParsedControlMessage = {
    type: type,
    payload: payload
  };
  return result;
}

export function createDeviceMessage(type: DeviceMessageType, payload: ArrayBuffer): ArrayBuffer {
  const buffer = new ArrayBuffer(1 + payload.byteLength);
  const view = new Uint8Array(buffer);

  view[0] = type;
  view.set(new Uint8Array(payload), 1);

  return buffer;
}

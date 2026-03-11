/**
 * Index.ets
 * 占位页面
 * 实际使用时服务在后台运行，不需要 UI
 */

@Entry
@Component
struct Index {
  @State message: string = 'scrcpy Server for HarmonyOS';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('hello')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ top: 100 })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
  }
}

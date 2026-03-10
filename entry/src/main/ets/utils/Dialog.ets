/**
  * 显示提示对话框
*/
export class Dialog {
  static show(message: string): void {
    AlertDialog.show({
      title: "提示",
      message: message,
      primaryButton: {
        value: "确定",
        action: () => {},
      },
      autoCancel: true,
    });
  }

  /**
   * 显示功能尚未实现的提示
   */
  static showNotImplemented(): void {
    Dialog.show("功能尚未实现，敬请期待！");
    console.info("Dialog: not implemented message");
  }
}

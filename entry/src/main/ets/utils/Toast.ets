export class Toast {
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

  static showNotImplemented(): void {
    Toast.show("功能尚未实现，敬请期待！");
  }
}

import { UserInfo } from "../models/UserInfo";
import { Dialog } from "../utils/Dialog";
import { UserService } from "../services/UserService";

/**
 * 个人中心页面组件，显示用户信息和常用功能入口
 *
 * 包含用户头像、用户名、会员等级等基本信息，以及订单状态和常用功能的入口
 */
@Component
export struct ProfilePage {
  private readonly statusBarOffset: number = 36;
  @State userInfo: UserInfo = UserService.getInstance().getUserInfo();
  scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column() {
        // 个人信息区域
        Row() {
          Image($r(this.userInfo.avatar))
            .width(64)
            .height(64)
            .borderRadius(32)
            .border({ width: 2, color: Color.White })
          Column() {
            Text(this.userInfo.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
            Text(`会员等级：${this.userInfo.memberLevel}`)
              .fontSize(14)
              .fontColor("rgba(255, 255, 255, 0.8)")
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
        }
        .width("100%")
        .padding({ left: 20, right: 20, top: 40 + this.statusBarOffset, bottom: 30 })
        .backgroundColor("#ff4d4f")
        .justifyContent(FlexAlign.Start)

        // 功能入口
        Row() {
          this.buildFunctionMenuItem("app.media.clickboard", "我的订单")
          this.buildFunctionMenuItem("app.media.like", "我的收藏")
          this.buildFunctionMenuItem("app.media.credit", "我的优惠券")
          this.buildFunctionMenuItem("app.media.setting", "设置")
        }
        .width("100%")
        .padding({ top: 16, bottom: 16 })
        .backgroundColor(Color.White)

        // 订单状态
        Column() {
          Row() {
            Text("订单状态")
              .fontSize(16)
              .fontColor("#333333")
              .fontWeight(FontWeight.Medium)
          }
          .width("100%")
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .border({
            width: { bottom: 1 },
            color: "#f0f0f0",
          })
          Row() {
            this.buildOrderStatusMenuItem("app.media.pay", "待付款", 1)
            this.buildOrderStatusMenuItem("app.media.truck", "待发货", 8)
            this.buildOrderStatusMenuItem("app.media.box", "待收货", 9)
            this.buildOrderStatusMenuItem("app.media.comment", "待评价", 6)
          }
          .width("100%")
          .padding({ top: 16, bottom: 16 })
        }
        .width("100%")
        .backgroundColor(Color.White)
        .margin({ top: 12 })

        // 常用功能
        Column() {
          Row() {
            Text("常用功能")
              .fontSize(16)
              .fontColor("#333333")
              .fontWeight(FontWeight.Medium)
          }
          .width("100%")
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .border({
            width: { bottom: 1 },
            color: "#f0f0f0",
          })

          this.buildCommonFeatureMenuItem("app.media.headest", "客户服务")
          this.buildCommonFeatureMenuItem("app.media.safe", "账号安全")
          this.buildCommonFeatureMenuItem("app.media.info", "关于我们", false)
        }
        .width("100%")
        .backgroundColor(Color.White)
        .margin({ top: 12 })

        // 退出登录按钮
        Button("退出登录")
          .width("90%")
          .height(44)
          .backgroundColor(Color.White)
          .fontColor("#ff4d4f")
          .borderRadius(8)
          .margin({ top: 24 })
          .onClick(() => Dialog.showNotImplemented())
      }
      .width("100%")
    }
    .scrollBar(BarState.Auto)
  }

  /**
   * 构建功能菜单项
   *
   * @param image 图标资源ID
   * @param label 菜单项文本
   */
  @Builder
  buildFunctionMenuItem(image: string, label: string) {
    Column() {
      Image($r(image))
        .width(28)
        .height(28)
      Text(label)
        .fontSize(12)
        .fontColor("#333333")
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .onClick(() => Dialog.showNotImplemented());
  }

  /**
   * 构建订单状态菜单项
   *
   * @param image 图标资源ID
   * @param label 菜单项文本
   * @param count 订单数量
   */
  @Builder
  buildOrderStatusMenuItem(image: string, label: string, count: number) {
    Column() {
      Image($r(image))
        .width(28)
        .height(28)
      Text(label)
        .fontSize(12)
        .fontColor("#333333")
        .margin({ top: 4 })
      Text(count.toString())
        .fontSize(12)
        .fontColor("#ff4d4f")
        .margin({ top: 2 })
    }
    .layoutWeight(1)
    .onClick(() => Dialog.showNotImplemented());
  }

  /**
   * 构建常用功能菜单项
   *
   * @param icon 图标资源ID
   * @param label 菜单项文本
   * @param showBorder 是否显示底部边框，默认为true
   */
  @Builder
  buildCommonFeatureMenuItem(icon: string, label: string, showBorder: boolean = true) {
    Row() {
      Row() {
        Image($r(icon))
          .width(28)
          .height(28)
        Text(label)
          .fontSize(14)
          .fontColor("#333333")
          .margin({ left: 12 })
      }
      Text("›")
        .fontSize(20)
        .fontColor("#cccccc")
    }
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .border({
      width: { bottom: showBorder ? 1 : 0 },
      color: "#f0f0f0",
    })
    .onClick(() => Dialog.showNotImplemented());
  }
}
import { UserInfo } from '../models/UserInfo';
import { Toast } from '../utils/Toast';
import { UserService } from '../services/UserService';

@Entry
@Component
export struct ProfilePage {
  @State userInfo: UserInfo = UserService.getInstance().getUserInfo();

  showToast(): void {
    Toast.showNotImplemented();
  }

  build() {
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
            .fontColor('rgba(255, 255, 255, 0.8)')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 40, bottom: 30 })
      .backgroundColor('#ff4d4f')
      .justifyContent(FlexAlign.Start)

      // 功能入口
      Row() {
        Column() {
          Image($r('app.media.clickboard'))
            .width(28)
            .height(28)
          Text('我的订单')
            .fontSize(12)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.showToast())

        Column() {
          Image($r('app.media.like'))
            .width(28)
            .height(28)
          Text('我的收藏')
            .fontSize(12)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.showToast())

        Column() {
          Image($r('app.media.credit'))
            .width(28)
            .height(28)
          Text('我的优惠券')
            .fontSize(12)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.showToast())

        Column() {
          Image($r('app.media.setting'))
            .width(28)
            .height(28)
          Text('设置')
            .fontSize(12)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .onClick(() => this.showToast())
      }
      .width('100%')
      .padding({ top: 16, bottom: 16 })
      .backgroundColor(Color.White)

      // 订单状态
      Column() {
        Row() {
          Text('订单状态')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .border({
          width: { bottom: 1 },
          color: '#f0f0f0'
        })

        Row() {
          Column() {
            Image($r('app.media.pay'))
              .width(28)
              .height(28)
            Text('待付款')
              .fontSize(12)
              .fontColor('#333333')
              .margin({ top: 4 })
            Text('0')
              .fontSize(12)
              .fontColor('#ff4d4f')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .onClick(() => this.showToast())

          Column() {
            Image($r('app.media.truck'))
              .width(28)
              .height(28)
            Text('待发货')
              .fontSize(12)
              .fontColor('#333333')
              .margin({ top: 4 })
            Text('0')
              .fontSize(12)
              .fontColor('#ff4d4f')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .onClick(() => this.showToast())

          Column() {
            Image($r('app.media.box'))
              .width(28)
              .height(28)
            Text('待收货')
              .fontSize(12)
              .fontColor('#333333')
              .margin({ top: 4 })
            Text('0')
              .fontSize(12)
              .fontColor('#ff4d4f')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .onClick(() => this.showToast())

          Column() {
            Image($r('app.media.comment'))
              .width(28)
              .height(28)   
            Text('待评价')
              .fontSize(12)
              .fontColor('#333333')
              .margin({ top: 4 })
            Text('0')
              .fontSize(12)
              .fontColor('#ff4d4f')
              .margin({ top: 2 })
          }
          .layoutWeight(1)
          .onClick(() => this.showToast())
        }
        .width('100%')
        .padding({ top: 16, bottom: 16 })
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ top: 12 })

      // 常用功能
      Column() {
        Row() {
          Text('常用功能')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .border({
          width: { bottom: 1 },
          color: '#f0f0f0'
        })

        this.buildMenuItem('app.media.headest', '客户服务')
        this.buildMenuItem('app.media.safe', '账号安全')
        this.buildMenuItem('app.media.info', '关于我们', false)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ top: 12 })

      // 退出登录按钮
      Button('退出登录')
        .width('90%')
        .height(44)
        .backgroundColor(Color.White)
        .fontColor('#ff4d4f')
        .borderRadius(8)
        .margin({ top: 24 })
        .onClick(() => this.showToast())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }

  @Builder
  buildMenuItem(icon: string, label: string, showBorder: boolean = true) {
    Row() {
      Row() {
        Image($r(icon))
          .width(28)
          .height(28)
        Text(label)
          .fontSize(14)
          .fontColor('#333333')
          .margin({ left: 12 })
      }

      Text('›')
        .fontSize(20)
        .fontColor('#cccccc')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .border({
      width: { bottom: showBorder ? 1 : 0 },
      color: '#f0f0f0'
    })
    .onClick(() => this.showToast())
  }
}

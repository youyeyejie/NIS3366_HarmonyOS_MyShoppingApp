import { CartService } from '../services/CartService';

@Component
export struct BottomNavBar {
  @State currentIndex: number = 0;
  @State cartCount: number = 0;
  private cartService: CartService = CartService.getInstance();
  onTabChange?: (index: number) => void;

  aboutToAppear(): void {
    this.cartService.onCartChange(() => {
      this.cartCount = this.cartService.getCartCount();
    });
    this.cartCount = this.cartService.getCartCount();
  }

  build() {
    Row() {
      // 首页
      Column() {
        Stack() {
          Image($r('app.media.home'))
            .width(28)
            .height(28)
        }
        Text('首页')
          .fontSize(12)
          .fontColor(this.currentIndex === 0 ? '#ff4d4f' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentIndex = 0;
        if (this.onTabChange) {
          this.onTabChange(0);
        }
      })

      // 购物车
      Column() {
        Stack() {
          Image($r('app.media.cart'))
            .width(28)
            .height(28)
          if (this.cartCount > 0) {
            Text(this.cartCount > 99 ? '99+' : this.cartCount.toString())
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor('#ff4d4f')
              .borderRadius(10)
              .textAlign(TextAlign.Center)
              .width(this.cartCount > 99 ? 28 : 18)
              .height(18)
              .position({ x: 14, y: -6 })
          }
        }
        Text('购物车')
          .fontSize(12)
          .fontColor(this.currentIndex === 1 ? '#ff4d4f' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentIndex = 1;
        if (this.onTabChange) {
          this.onTabChange(1);
        }
      })

      // 我的
      Column() {
        Image($r('app.media.profile'))
          .width(28)
          .height(28)
        Text('我的')
          .fontSize(12)
          .fontColor(this.currentIndex === 2 ? '#ff4d4f' : '#999999')
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentIndex = 2;
        if (this.onTabChange) {
          this.onTabChange(2);
        }
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .border({
      width: { top: 1 },
      color: '#e5e5e5'
    })
    .padding({ top: 8, bottom: 8 })
  }
}

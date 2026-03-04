import { HomePage } from './HomePage';
import { CartPage } from './CartPage';
import { ProfilePage } from './ProfilePage';
import { BottomNavBar } from '../utils/BottomNavBar';

@Entry
@Component
export struct MainIndex {
  @State currentIndex: number = 0;

  switchToHome(): void {
    this.currentIndex = 0;
  }

  build() {
    Column() {
      // 根据当前索引显示对应页面
      Column() {
        if (this.currentIndex === 0) {
          HomePage()
        } else if (this.currentIndex === 1) {
          CartPage({ onGoShopping: this.switchToHome.bind(this) })
        } else {
          ProfilePage()
        }
      }
      .layoutWeight(1)
      .width('100%')

      // 底部导航栏
      BottomNavBar({
        currentIndex: this.currentIndex,
        onTabChange: (index: number) => {
          this.currentIndex = index;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

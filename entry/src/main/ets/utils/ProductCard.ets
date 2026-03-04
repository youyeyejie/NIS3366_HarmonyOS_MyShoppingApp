import { Product } from '../models/Product';
import { CartService } from '../services/CartService';

@Component
export struct ProductCard {
  private product: Product = {} as Product;
  private cartService: CartService = CartService.getInstance();
  @State private isPressed: boolean = false;

  build() {
    Column() {
      // 商品图片
      Image($r(this.product.img))
        .width('100%')
        .height(160)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 8, topRight: 8 })

      // 商品信息
      Column() {
        // 商品名称左对齐，一行，超出省略
        Text(this.product.name)
          .fontSize(14)
          .fontColor('#333333')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 价格和按钮同一行
        Row() {
          Row() {
            Text('¥')
              .fontSize(12)
              .fontColor('#ff4d4f')
            Text(this.product.price.toString())
              .fontSize(16)
              .fontColor('#ff4d4f')
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(VerticalAlign.Bottom)

          // 加入购物车按钮 - 带点击动效
          Text('加入购物车')
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor(this.isPressed ? '#cc3d3f' : '#ff4d4f')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(4)
            .scale(this.isPressed ? { x: 0.95, y: 0.95 } : { x: 1, y: 1 })
            .animation({
              duration: 100,
              curve: Curve.Ease
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                this.isPressed = true;
              } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
                this.isPressed = false;
              }
            })
            .onClick(() => {
              this.cartService.addToCart(this.product);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)
      }
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetY: 2
    })
  }
}

import { CartItem } from '../models/CartItem';
import { CartService } from '../services/CartService';

@Component
export struct CartItemCard {
  private item: CartItem = {} as CartItem;
  @Prop isSelected: boolean = false;
  private cartService: CartService = CartService.getInstance();
  
  onToggleSelect?: (productId: number) => void;
  onDecreaseQuantity?: (item: CartItem) => void;
  onIncreaseQuantity?: (item: CartItem) => void;
  onRemoveItem?: (item: CartItem) => void;

  build() {
    Row({ space: 12 }) {
      // 复选框
      Image($r(
        this.isSelected
            ? "app.media.squarecheck"
            : "app.media.square",
        ))
        .width(24)
        .height(24)
        .onClick(() => {
          this.isSelected = !this.isSelected;
          if (this.onToggleSelect && this.item.product) {
            this.onToggleSelect(this.item.product.id);
          }
        })

      // 商品图片 - 使用 $r() 引用资源
      Image($r(this.item.product.img))
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 商品信息
      Column() {
        Text(this.item.product.name)
          .fontSize(14)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text('¥')
            .fontSize(12)
            .fontColor('#ff4d4f')
          Text(this.item.product.price.toString())
            .fontSize(14)
            .fontColor('#ff4d4f')
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: 8 })

        // 数量控制
        Row({ space: 8 }) {
          Text('-')
            .fontSize(18)
            .fontColor('#333333')
            .width(28)
            .height(28)
            .backgroundColor('#f5f5f5')
            .borderRadius(14)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (this.onDecreaseQuantity) {
                this.onDecreaseQuantity(this.item);
              }
            })

          Text(this.item.quantity.toString())
            .fontSize(14)
            .fontColor('#333333')
            .width(30)
            .textAlign(TextAlign.Center)

          Text('+')
            .fontSize(18)
            .fontColor('#333333')
            .width(28)
            .height(28)
            .backgroundColor('#f5f5f5')
            .borderRadius(14)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (this.onIncreaseQuantity) {
                this.onIncreaseQuantity(this.item);
              }
            })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 删除按钮
      Column() {
        Text('删除')
          .fontSize(12)
          .fontColor('#999999')
          .onClick(() => {
            if (this.onRemoveItem) {
              this.onRemoveItem(this.item);
            }
          })
      }
      .justifyContent(FlexAlign.End)
      .height(80)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetY: 2
    })
  }
}

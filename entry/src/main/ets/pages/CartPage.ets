import { CartItem } from "../models/CartItem";
import { CartService } from "../services/CartService";
import { Toast } from "../utils/Toast";
import { CartItemCard } from "../utils/CartItemCard";

@Component
export struct CartPage {
  @State cartItems: CartItem[] = [];
  @State selectedItems: Set<number> = new Set();
  @State cartTotal: number = 0;
  @State isEmpty: boolean = true;
  @State hasMore: boolean = true;
  onGoShopping: () => void = () => {};
  private cartService: CartService = CartService.getInstance();

  aboutToAppear(): void {
    this.loadCartData();
    this.cartService.onCartChange(() => {
      this.loadCartData();
    });
  }
  loadCartData(): void {
    // 创建新的数组副本，确保触发状态更新
    const items = this.cartService.getCartItems();
    this.cartItems = items.map((item: CartItem): CartItem => {
      return { product: item.product, quantity: item.quantity } as CartItem;
    });
    this.isEmpty = this.cartItems.length === 0;
    this.hasMore = this.cartItems.length > 6;
    // 默认全选
    if (this.selectedItems.size === 0 && this.cartItems.length > 0) {
      this.cartItems.forEach((item) => this.selectedItems.add(item.product.id));
    }
    this.calculateTotal();
  }

  calculateTotal(): void {
    let total = 0;
    this.cartItems.forEach((item) => {
      if (this.selectedItems.has(item.product.id)) {
        total += item.product.price * item.quantity;
      }
    });
    this.cartTotal = total;
  }

  onToggleSelect(productId: number): void {
    if (this.selectedItems.has(productId)) {
      this.selectedItems.delete(productId);
    } else {
      this.selectedItems.add(productId);
    }
    this.calculateTotal();
  }

  onSelectAll(): void {
    if (this.selectedItems.size === this.cartItems.length) {
      this.selectedItems.clear();
    } else {
      this.selectedItems.clear();
      this.cartItems.forEach((item) => this.selectedItems.add(item.product.id));
    }
    this.calculateTotal();
  }

  onDecreaseQuantity(item: CartItem): void {
    const index = this.cartItems.findIndex((cartItem) => cartItem.product.id === item.product.id);
    if (index === -1) {
      return;
    }

    const current = this.cartItems[index];
    if (current.quantity > 1) {
      // 先更新本地状态，保证数量显示实时变化
      this.cartItems = this.cartItems.map((cartItem) => {
        if (cartItem.product.id === item.product.id) {
          return { product: cartItem.product, quantity: cartItem.quantity - 1 } as CartItem;
        }
        return cartItem;
      });
      this.calculateTotal();
      this.cartService.updateQuantity(item.product.id, current.quantity - 1);
    } else {
      this.cartItems = this.cartItems.filter((cartItem) => cartItem.product.id !== item.product.id);
      this.selectedItems.delete(item.product.id);
      this.isEmpty = this.cartItems.length === 0;
      this.calculateTotal();
      this.cartService.removeFromCart(item.product.id);
    }
  }

  onIncreaseQuantity(item: CartItem): void {
    const currentItem = this.cartItems.find((cartItem) => cartItem.product.id === item.product.id);
    if (currentItem) {
      // 先更新本地状态，保证数量显示实时变化
      this.cartItems = this.cartItems.map((cartItem) => {
        if (cartItem.product.id === item.product.id) {
          return { product: cartItem.product, quantity: cartItem.quantity + 1 } as CartItem;
        }
        return cartItem;
      });
      this.calculateTotal();
      this.cartService.updateQuantity(item.product.id, currentItem.quantity + 1);
    }
  }

  onRemoveItem(item: CartItem): void {
    this.cartService.removeFromCart(item.product.id);
    this.selectedItems.delete(item.product.id);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text("我的购物车")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333333")
      }
      .width("100%")
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      if (this.isEmpty) {
        // 空购物车
        Column() {
          Text("🛒")
            .fontSize(60)
            .opacity(0.5)
          Text("购物车还是空的哦~")
            .fontSize(16)
            .fontColor("#999999")
            .margin({ top: 20 })
          Button("去逛逛")
            .width(120)
            .height(40)
            .backgroundColor("#ff4d4f")
            .fontColor(Color.White)
            .margin({ top: 20 })
            .borderRadius(20)
            .onClick(() => {
              if (this.onGoShopping) {
                this.onGoShopping();
              }
            })
        }
        .width("100%")
        .height("100%")
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor("#f5f5f5");
      } else {
        // 购物车列表
        Column() {
          // 全选行
          Row() {
            Row() {
              Image($r(
                this.selectedItems.size === this.cartItems.length
                  ? "app.media.squarecheck"
                  : "app.media.square",
              ))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Cover)
                .margin({ right: 4 })
                .onClick(() => this.onSelectAll())
              Text("全选")
                .fontSize(14)
                .fontColor("#333333")
                .margin({ left: 8 })
                .onClick(() => this.onSelectAll())
            }
            Text("删除")
              .fontSize(14)
              .fontColor("#999999")
              .onClick(() => {
                // 删除选中的商品
                const toDelete = Array.from(this.selectedItems);
                toDelete.forEach((id) => this.cartService.removeFromCart(id));
                this.selectedItems.clear();
                this.calculateTotal();
              })
          }
          .width("100%")
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor(Color.White)
          // 商品列表 - 使用 LazyForEach
          List({ space: 12}) {
            ForEach(this.cartItems, (item: CartItem) => {
              ListItem() {
                CartItemCard({
                  item: item,
                  isSelected: this.selectedItems.has(item.product.id),
                  onToggleSelect: (productId: number) => this.onToggleSelect(productId),
                  onDecreaseQuantity: (cartItem: CartItem) => this.onDecreaseQuantity(cartItem),
                  onIncreaseQuantity: (cartItem: CartItem) => this.onIncreaseQuantity(cartItem),
                  onRemoveItem: (cartItem: CartItem) => this.onRemoveItem(cartItem),
                })
              };
            }, (item: CartItem) => `${item.product.id}-${item.quantity}`)
          }
          .width("100%")
          .layoutWeight(1)
          .padding(12)
          .backgroundColor("#f5f5f5")

          // 底部结算栏
          Row() {
            Row() {
              Text("合计：")
                .fontSize(14)
                .fontColor("#999999")
              Text("¥")
                .fontSize(14)
                .fontColor("#ff4d4f")
              Text(this.cartTotal.toString())
                .fontSize(18)
                .fontColor("#ff4d4f")
                .fontWeight(FontWeight.Bold)
            }
            Button("去结算")
              .width(100)
              .height(40)
              .backgroundColor("#ff4d4f")
              .fontColor(Color.White)
              .borderRadius(20)
              .onClick(() => Toast.showNotImplemented())
          }
          .width("100%")
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 16, right: 16, top: 12, bottom: 24 })
          .backgroundColor(Color.White)
          .border({
            width: { top: 1 },
            color: "#e5e5e5",
          })
          .margin({ bottom: 32 })
        }
        .width("100%")
        .height("100%");
      }
    }
    .width("100%")
    .height("100%");
  }
}

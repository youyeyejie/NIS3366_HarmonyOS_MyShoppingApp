import { CartItem } from "../models/CartItem";
import { CartService } from "../services/CartService";
import { Dialog } from "../utils/Dialog";
import { CartItemCard } from "../utils/CartItemCard";

/**
 * 购物车页面组件，显示用户已添加的商品列表，并提供修改数量、删除商品和结算等功能
 *
 * 包含购物车列表、全选功能、总价计算和结算按钮等核心功能
 */
@Component
export struct CartPage {
  @State cartItems: CartItem[] = [];
  @State selectedItems: Set<number> = new Set();
  @State cartTotal: number = 0;
  @State isEmpty: boolean = true;
  @State hasMore: boolean = true;
  scroller: Scroller = new Scroller();
  onGoShopping: () => void = () => {}; // 父组件传入的回调函数
  private cartService: CartService = CartService.getInstance();

  // 页面即将展示时加载购物车数据，并注册监听购物车变化的回调，确保数据实时更新
  aboutToAppear(): void {
    this.loadCartData();
    this.cartService.onCartChange(() => {
      this.loadCartData();
    });
  }
  /**
   * 加载购物车数据的方法，获取购物车中的商品列表，并更新组件状态。
   *
   * 同时计算购物车总价，并根据购物车是否为空来设置相关状态。
   */
  loadCartData(): void {
    const items = this.cartService.getCartItems();
    // 创建新的数组副本，确保触发状态更新
    this.cartItems = items.map((item: CartItem): CartItem => {
      return { product: item.product, quantity: item.quantity } as CartItem;
    });
    this.isEmpty = this.cartItems.length === 0;
    this.hasMore = this.cartItems.length > 6;
    // 默认全选
    if (this.selectedItems.size === 0 && this.cartItems.length > 0) {
      this.cartItems.forEach((item) => this.selectedItems.add(item.product.id));
    }
    // 计算总价
    this.calculateTotal();
  }

  /**
   * 计算购物车总价的方法，根据当前选中的商品来计算总价，并更新组件状态。
   */
  calculateTotal(): void {
    let total = 0;
    this.cartItems.forEach((item) => {
      if (this.selectedItems.has(item.product.id)) {
        total += item.product.price * item.quantity;
      }
    });
    this.cartTotal = total;
  }

  /**
   * 切换商品选中状态的方法，根据商品ID来切换选中状态，并重新计算总价。
   * @param productId 商品ID
   */
  onToggleSelect(productId: number): void {
    if (this.selectedItems.has(productId)) {
      this.selectedItems.delete(productId);
    } else {
      this.selectedItems.add(productId);
    }
    this.calculateTotal();
  }

  /**
   * 全选/全不选的方法，根据当前选中状态来切换全选状态，并重新计算总价。
   */
  onSelectAll(): void {
    if (this.selectedItems.size === this.cartItems.length) {
      this.selectedItems.clear();
    } else {
      this.selectedItems.clear();
      this.cartItems.forEach((item) => this.selectedItems.add(item.product.id));
    }
    this.calculateTotal();
  }

  /**
   * 从购物车中减少商品数量的方法，如果数量减少到0则从购物车中移除，并重新计算总价。
   * @param productId 商品ID
   */
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

  /**
   * 从购物车中增加商品数量的方法，并重新计算总价。
   * @param productId 商品ID
   */
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

  /**
   * 从购物车中移除商品的方法，根据商品ID来移除商品，并重新计算总价。
   */
  onRemoveItem(item: CartItem): void {
    this.cartService.removeFromCart(item.product.id);
    this.selectedItems.delete(item.product.id);
    this.calculateTotal();
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
          // 商品列表
          List({ space: 12, scroller: this.scroller }) {
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
          .scrollBar(BarState.Auto)

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
              .onClick(() => Dialog.showNotImplemented())
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

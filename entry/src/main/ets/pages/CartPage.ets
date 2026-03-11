import { CartItem } from "../models/CartItem";
import { CartService } from "../services/CartService";
import { Dialog } from "../utils/Dialog";
import { CartItemCard } from "../utils/CartItemCard";
import { CartDataSource } from "../utils/CartDataSource";

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
  @State isRefreshing: boolean = false;
  @State showNoMoreTip: boolean = false;
  @State dataSource: CartDataSource = new CartDataSource();
  scroller: Scroller = new Scroller();
  onGoShopping: () => void = () => {}; // 父组件传入的回调函数
  private cartService: CartService = CartService.getInstance();
  private hasInitializedSelection: boolean = false;
  private noMoreTipTimer: number = -1;
  private firstVisibleIndex: number = 0;
  private lastVisibleIndex: number = -1;
  private lastTouchY: number = -1;
  private lastScrollOffsetY: number = 0;

  // 页面即将展示时加载购物车数据，并注册监听购物车变化的回调，确保数据实时更新
  aboutToAppear(): void {
    this.loadCartData();
    this.cartService.onCartChange(() => {
      this.loadCartData();
    });
  }

  /**
   * 下拉刷新事件处理方法，触发数据源重新加载数据，并更新刷新状态。
   */
  onRefresh(): void {
    this.isRefreshing = true;
    this.dataSource.loadCartItems();
    this.showNoMoreTip = false;
    this.isRefreshing = false;
    console.info("Data refreshed");
  }

  /**
   * 加载购物车数据的方法，获取购物车中的商品列表，并更新组件状态。
   *
   * 同时计算购物车总价，并根据购物车是否为空来设置相关状态。
   */
  loadCartData(): void {
    const previousLength = this.cartItems.length;
    const items = this.cartService.getCartItems();
    // 创建新的数组副本，确保触发状态更新
    this.cartItems = items.map((item: CartItem): CartItem => {
      return { product: item.product, quantity: item.quantity } as CartItem;
    });
    this.dataSource.setItems(this.cartItems);
    this.isEmpty = this.cartItems.length === 0;
    this.syncSelectedItems(previousLength);
    if (this.cartItems.length === 0) {
      this.showNoMoreTip = false;
    }
    // 计算总价
    this.calculateTotal();
  }

  /**
   * 同步选中状态的方法，在购物车数据变化时根据商品ID来同步选中状态，确保用户的选择在数据更新后仍然保持一致。
   * @param previousLength 上一次购物车商品数量，用于判断是否需要初始化选中状态
   */
  private syncSelectedItems(previousLength: number): void {
    const currentIds = new Set<number>(this.cartItems.map((item) => item.product.id));
    const nextSelected = new Set<number>();

    this.selectedItems.forEach((productId) => {
      if (currentIds.has(productId)) {
        nextSelected.add(productId);
      }
    });

    if (
      (!this.hasInitializedSelection || previousLength === 0) &&
      this.cartItems.length > 0 &&
      nextSelected.size === 0
    ) {
      this.cartItems.forEach((item) => nextSelected.add(item.product.id));
      this.hasInitializedSelection = true;
    }

    if (this.cartItems.length === 0) {
      this.hasInitializedSelection = false;
    }

    this.selectedItems = nextSelected;
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
    console.log(`Total price calculated: ${this.cartTotal}`);
  }

  /**
   * 显示到底提示的方法，当用户滚动到列表底部时调用，显示一个提示Toast，并在约1.5秒后自动隐藏。
   */
  showNoMoreToast(): void {
    this.showNoMoreTip = true;
    if (this.noMoreTipTimer >= 0) {
      clearTimeout(this.noMoreTipTimer);
    }
    this.noMoreTipTimer = setTimeout(() => {
      this.showNoMoreTip = false;
      this.noMoreTipTimer = -1;
    }, 1500);
  }

  /**
   * 切换商品选中状态的方法，根据商品ID来切换选中状态，并重新计算总价。
   * @param productId 商品ID
   */
  onToggleSelect(productId: number): void {
    const nextSelected = new Set<number>(this.selectedItems);
    if (nextSelected.has(productId)) {
      nextSelected.delete(productId);
      console.log(`Product ${productId} deselected`);
    } else {
      nextSelected.add(productId);
      console.log(`Product ${productId} selected`);
    }
    this.selectedItems = nextSelected;
    this.calculateTotal();
  }

  /**
   * 全选/全不选的方法，根据当前选中状态来切换全选状态，并重新计算总价。
   */
  onSelectAll(): void {
    const nextSelected = new Set<number>();
    if (this.selectedItems.size !== this.cartItems.length) {
      this.cartItems.forEach((item) => nextSelected.add(item.product.id));
    }
    this.selectedItems = nextSelected;
    this.calculateTotal();
  }

  /**
   * 删除选中商品的方法，根据当前选中的商品ID来从购物车中移除对应的商品，并重新计算总价。
   */
  onDeleteSelected(): void {
    const toDelete = Array.from(this.selectedItems);
    if (toDelete.length === 0) {
      return;
    }
    toDelete.forEach((id) => this.cartService.removeFromCart(id));
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
      this.dataSource.setItems(this.cartItems);
      this.cartService.updateQuantity(item.product.id, current.quantity - 1);
    } else {
      this.cartItems = this.cartItems.filter((cartItem) => cartItem.product.id !== item.product.id);
      const nextSelected = new Set<number>(this.selectedItems);
      nextSelected.delete(item.product.id);
      this.selectedItems = nextSelected;
      this.dataSource.setItems(this.cartItems);
      this.isEmpty = this.cartItems.length === 0;
      this.calculateTotal();
      this.cartService.removeFromCart(item.product.id);
    }
    console.log(
      `Decreased quantity of product ${item.product.id}, new quantity: ${current.quantity - 1}`,
    );
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
      this.dataSource.setItems(this.cartItems);
      this.cartService.updateQuantity(item.product.id, currentItem.quantity + 1);
    }
    console.log(
      `Increased quantity of product ${item.product.id}, new quantity: ${currentItem ? currentItem.quantity + 1 : 1}`,
    );
  }

  /**
   * 从购物车中移除商品的方法，根据商品ID来移除商品，并重新计算总价。
   */
  onRemoveItem(item: CartItem): void {
    this.cartService.removeFromCart(item.product.id);
    const nextSelected = new Set<number>(this.selectedItems);
    nextSelected.delete(item.product.id);
    this.selectedItems = nextSelected;
    this.calculateTotal();
  }

  /**
   * 列表滚动索引回调：触底加载更多，同时在到底时显示提示。
   * @param firstIndex 当前第一个可见项的索引
   * @param lastIndex 当前最后一个可见项的索引
   */
  onCartScrollIndex(_firstIndex: number, lastIndex: number): void {
    this.firstVisibleIndex = _firstIndex;
    this.lastVisibleIndex = lastIndex;

    const total = this.dataSource.totalCount();
    if (total <= 0) {
      this.showNoMoreTip = false;
      return;
    }

    const yOffset = this.scroller.currentOffset().yOffset;
    const isScrollable = yOffset > 0;
    const movingToBottom = yOffset >= this.lastScrollOffsetY;
    const reachEnd = lastIndex >= total - 1;
    if (reachEnd && isScrollable && movingToBottom && !this.showNoMoreTip) {
      this.showNoMoreToast();
    }
    this.lastScrollOffsetY = yOffset;
  }

  /**
   * 列表触摸事件处理方法：记录触摸位置以判断上滑动作，并在上滑时尝试显示到底提示。
   * @param event 触摸事件对象
   */
  private onListTouch(event: TouchEvent): void {
    const touch = event.touches[0];
    if (event.type === TouchType.Down && touch) {
      this.lastTouchY = touch.y;
      return;
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.lastTouchY = -1;
      return;
    }
    if (event.type === TouchType.Move && touch) {
      const isUpSwipe = this.lastTouchY >= 0 && touch.y < this.lastTouchY;
      this.lastTouchY = touch.y;
      if (isUpSwipe) {
        const total = this.dataSource.totalCount();
        if (total <= 0 || this.showNoMoreTip) {
          return;
        }
        if (this.firstVisibleIndex === 0 && this.lastVisibleIndex >= total - 1) {
          this.showNoMoreToast();
        }
      }
      return;
    }
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
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor("#f5f5f5");
      } else {
        // 购物车列表
        Column() {
          // 全选行
          Row() {
            Row() {
              Image(
                $r(
                  this.selectedItems.size === this.cartItems.length
                    ? "app.media.squarecheck"
                    : "app.media.square",
                ),
              )
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
              .onClick(() => this.onDeleteSelected())
          }
          .width("100%")
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .justifyContent(FlexAlign.SpaceBetween)
          .backgroundColor(Color.White)

          // 商品列表
          Refresh({ refreshing: this.isRefreshing, offset: 50, friction: 70 }) {
            List({ space: 12, scroller: this.scroller }) {
              LazyForEach(
                this.dataSource,
                (item: CartItem) => {
                  ListItem() {
                    CartItemCard({
                      item: item,
                      isSelected: this.selectedItems.has(item.product.id),
                      onToggleSelect: (productId: number) => this.onToggleSelect(productId),
                      onDecreaseQuantity: (cartItem: CartItem) => this.onDecreaseQuantity(cartItem),
                      onIncreaseQuantity: (cartItem: CartItem) => this.onIncreaseQuantity(cartItem),
                      onRemoveItem: (cartItem: CartItem) => this.onRemoveItem(cartItem),
                    })
                  }
                  .onAppear(() => {
                    console.info(`Cart item ${item.product.id} appeared`);
                  })
                  .onDisAppear(() => {
                    console.info(`Cart item ${item.product.id} disappeared`);
                  });
                },
                (item: CartItem) => `${item.product.id}-${item.quantity}`,
              )
            }
            .width("100%")
            .layoutWeight(1)
            .padding(12)
            .backgroundColor("#f5f5f5")
            .scrollBar(BarState.Auto)
            .cachedCount(4)
            .onScrollIndex((firstIndex: number, lastIndex: number) => {
              this.onCartScrollIndex(firstIndex, lastIndex);
            })
            .onTouch((event: TouchEvent) => {
              this.onListTouch(event);
            })
          }
          .onRefreshing(() => {
            this.onRefresh();
          })
          .width("100%")
          .layoutWeight(1)

          // 到底提示
          Row() {
            Text("已经到底啦，没有更多商品了")
              .fontSize(13)
              .fontColor("#ffffff")
              .padding({ left: 14, right: 14, top: 8, bottom: 8 })
              .backgroundColor("rgba(0, 0, 0, 0.65)")
              .borderRadius(16)
          }
          .width("100%")
          .justifyContent(FlexAlign.Center)
          .position({ x: 0, y: "82%" })
          .opacity(this.showNoMoreTip ? 1 : 0)
          .translate({ x: 0, y: this.showNoMoreTip ? 0 : 12 })
          .animation({ duration: 220, curve: Curve.EaseInOut })
          .hitTestBehavior(HitTestMode.None)

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
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(Color.White)
          .border({
            width: { top: 1 },
            color: "#e5e5e5",
          })
        }
        .width("100%")
        .layoutWeight(1);
      }
    }
    .width("100%")
    .height("100%");
  }
}

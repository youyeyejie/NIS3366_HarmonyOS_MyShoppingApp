import { Product } from "../models/Product";
import { Category } from "../models/Category";
import { CategoryService } from "../services/CategoryService";
import { ProductDataSource } from "../utils/ProductDataSource";
import { ProductCard } from "../utils/ProductCard";
import { Dialog } from "../utils/Dialog";

/**
 * 首页组件，显示商品分类导航和商品列表
 *
 * 包含顶部标题栏、分类导航和商品列表等核心功能，同时支持下拉刷新和上拉加载更多。
 */
@Component
export struct HomePage {
  @State categories: Category[] = [];
  @State selectedCategory: string = "all";
  @State isRefreshing: boolean = false;
  @State showNoMoreTip: boolean = false;
  @State dataSource: ProductDataSource = new ProductDataSource();
  @State showBackToTop: boolean = false;
  private scroller: Scroller = new Scroller();
  private categoryService: CategoryService = CategoryService.getInstance();
  private noMoreTipTimer: number = -1;
  private firstVisibleIndex: number = 0;
  private lastVisibleIndex: number = -1;
  private lastTouchY: number = -1;
  private lastScrollOffsetY: number = 0;

  aboutToAppear(): void {
    this.categories = this.categoryService.getCategories();
    this.showNoMoreTip = false;
    this.lastTouchY = -1;
    this.lastScrollOffsetY = 0;
  }

  aboutToDisappear(): void {
    if (this.noMoreTipTimer >= 0) {
      clearTimeout(this.noMoreTipTimer);
      this.noMoreTipTimer = -1;
    }
  }

  /**
   * 分类点击事件处理方法，更新选中的分类，并重新加载商品数据。
   * @param categoryId 分类ID
   */
  onCategoryClick(categoryId: string): void {
    if (this.selectedCategory === categoryId) {
      return;
    }
    this.selectedCategory = categoryId;
    // 更新分类选中状态
    this.categories = this.categories.map(
      (cat) =>
        ({
          id: cat.id,
          name: cat.name,
          isSelected: cat.id === categoryId,
        }) as Category,
    );
    // 滚动到顶部
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
    // 设置分类并重新加载数据
    this.dataSource.setCategory(categoryId);
    this.showNoMoreTip = false;
  }

  /**
   * 下拉刷新事件处理方法，触发数据源重新加载数据，并更新刷新状态。
   */
  onRefresh(): void {
    this.isRefreshing = true;
    this.dataSource.loadProducts();
    this.showNoMoreTip = false;
    this.isRefreshing = false;
    console.info("Data refreshed");
  }

  /**
   * 显示到底提示 Toast：淡入后约 1.5 秒自动淡出。
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
    console.info("No more data to load");
  }

  /**
   * 列表滚动索引回调：触底加载更多，同时在到底时显示提示。
   */
  onGridScrollIndex(_firstIndex: number, lastIndex: number): void {
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
  private onGridTouch(event: TouchEvent): void {
    const touch = event.touches[0];

    // 如果是触摸开始，记录初始触摸位置
    if (event.type === TouchType.Down && touch) {
      this.lastTouchY = touch.y;
      return;
    }
    // 如果是触摸结束或取消，重置触摸位置
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.lastTouchY = -1;
      return;
    }
    // 如果是触摸移动，更新返回顶部按钮状态，并判断是否上滑以尝试显示到底提示
    if (event.type === TouchType.Move) {
      this.showBackToTop = this.scroller.currentOffset().yOffset > 100;
      if (touch) {
        const isUpSwipe = this.lastTouchY >= 0 && touch.y < this.lastTouchY;
        this.lastTouchY = touch.y;
        if (isUpSwipe) {
          const total = this.dataSource.totalCount();
          // 如果没有数据或已经显示到底提示，则不再尝试显示
          if (total <= 0 || this.showNoMoreTip) {
            return;
          }
          // 如果列表不可滚动且用户上滑了，显示到底提示
          if (this.firstVisibleIndex === 0 && this.lastVisibleIndex >= total - 1) {
            this.showNoMoreToast();
          }
        }
      }
      return;
    }

  }

  /**
   * 返回顶部按钮点击事件处理方法，触发滚动到顶部的动画。
   */
  scrollToTop(): void {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: {
        duration: 500,
        curve: Curve.EaseInOut,
      },
    });
    this.showBackToTop = false;
    console.info("Scrolling to top");
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text("毕办商城")
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333333")
        Row() {
          Image($r("app.media.search"))
            .width(24)
            .height(24)
            .onClick(() => Dialog.showNotImplemented())
          Image($r("app.media.bell"))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .onClick(() => Dialog.showNotImplemented())
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width("100%")
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      // 分类导航
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.categories, (category: Category) => {
            Text(category.name)
              .fontSize(14)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(category.isSelected ? "#ff4d4f" : "#e8e8e8")
              .fontColor(category.isSelected ? Color.White : "#666666")
              .borderRadius(16)
              .onClick(() => {
                this.onCategoryClick(category.id);
              });
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width("100%")
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor("#f5f5f5")

      // 商品列表 - 使用 Refresh 组件实现下拉刷新，采用 Grid 布局，使用 LazyForEach 实现懒加载
      Refresh({ refreshing: this.isRefreshing, offset: 50, friction: 70 }) {
        Grid(this.scroller) {
          LazyForEach(
            this.dataSource,
            (product: Product) => {
              GridItem() {
                ProductCard({ product: product })
              }
              .onAppear(() => {
                console.info(`Product ${product.id} appeared`);
              })
              .onDisAppear(() => {
                console.info(`Product ${product.id} disappeared`);
              });
            },
            (product: Product) => product.id.toString(),
          )
        }
        .columnsTemplate("1fr 1fr")
        .columnsGap(12)
        .rowsGap(12)
        .padding(12)
        .scrollBar(BarState.Off)
        .width("100%")
        .height("100%")
        .backgroundColor("#f5f5f5")
        .cachedCount(4)
        .onScrollIndex((firstIndex: number, lastIndex: number) => {
          this.onGridScrollIndex(firstIndex, lastIndex);
        })
        .onScrollStop(() => {
          this.showBackToTop = this.scroller.currentOffset().yOffset > 100;
        })
        .onTouch((event: TouchEvent) => {
          this.onGridTouch(event);
        })
      }
      .onRefreshing(() => {
        this.onRefresh();
      })
      .width("100%")
      .layoutWeight(1)

      // 底部提示 - 当用户上滑到列表底部时显示，约 1.5 秒后自动隐藏
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
      .position({ x: 0, y: "91%" })
      .opacity(this.showNoMoreTip ? 1 : 0)
      .translate({ x: 0, y: this.showNoMoreTip ? 0 : 12 })
      .animation({ duration: 220, curve: Curve.EaseInOut })
      .hitTestBehavior(HitTestMode.None)

      // 悬浮的返回顶部按钮
      Column() {
        Image($r("app.media.up"))
          .width(28)
          .height(28)
      }
      .width(44)
      .height(44)
      .backgroundColor("rgba(0, 0, 0, 0.5)")
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .position({ x: "82%", y: "90%" })
      .opacity(this.showBackToTop ? 1 : 0)
      .animation({ duration: 300 })
      .onClick(() => {
        this.scrollToTop();
      })
    }
    .width("100%")
    .height("100%");
  }
}

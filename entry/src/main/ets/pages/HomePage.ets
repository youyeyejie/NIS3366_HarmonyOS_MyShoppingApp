import { Product } from "../models/Product";
import { Category } from "../models/Category";
import { CategoryService } from "../services/CategoryService";
import { ProductDataSource } from "../utils/ProductDataSource";
import { ProductCard } from "../utils/ProductCard";
import { Dialog } from "../utils/Dialog";

class HomePageDataSource extends ProductDataSource {
  constructor() {
    super();
  }
}

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
  @State dataSource: HomePageDataSource = new HomePageDataSource();
  @State showBackToTop: boolean = false;
  private scroller: Scroller = new Scroller();
  private categoryService: CategoryService = CategoryService.getInstance();
  private noMoreTipTimer: number = -1;

  aboutToAppear(): void {
    this.categories = this.categoryService.getCategories();
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
   * 滚动停止事件处理方法，检查滚动位置并决定是否显示返回顶部按钮，同时触底时加载更多数据。
   */
  onScrollStop(): void {
    // 滚动停止时检查位置
    let yOffset = this.scroller.currentOffset().yOffset;
    this.showBackToTop = yOffset > 100;
  }

  /**
   * 列表滚动索引回调：触底加载更多，同时在到底时显示提示。
   */
  onGridScrollIndex(_firstIndex: number, lastIndex: number): void {
    const total = this.dataSource.totalCount();
    if (total <= 0) {
      this.showNoMoreTip = false;
      return;
    }

    const reachEnd = lastIndex >= total - 1;
    if (reachEnd && !this.showNoMoreTip) {
      this.showNoMoreToast();
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
                  .onAppear(() => {
                    console.info(`Product ${product.id} appeared`);
                  })
                  .onDisAppear(() => {
                    console.info(`Product ${product.id} disappeared`);
                  })
              };
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
          this.onScrollStop();
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Move) {
            // 滑动时获取当前位置
            let yOffset = this.scroller.currentOffset().yOffset;
            this.showBackToTop = yOffset > 100;
          }
        })
      }
      .onRefreshing(() => {
        this.onRefresh();
      })
      .width("100%")
      .layoutWeight(1)
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

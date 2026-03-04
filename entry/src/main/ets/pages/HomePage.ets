import { Product } from '../models/Product';
import { Category } from '../models/Category';
import { CategoryService } from '../services/CategoryService';
import { ProductDataSource } from '../utils/ProductDataSource';
import { ProductCard } from '../utils/ProductCard';
import { Toast } from '../utils/Toast';

class HomePageDataSource extends ProductDataSource {
  constructor() {
    super();
  }
}

@Entry
@Component
export struct HomePage {
  @State categories: Category[] = [];
  @State selectedCategory: string = 'all';
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = false;
  @State dataSource: HomePageDataSource = new HomePageDataSource();
  @State showBackToTop: boolean = false;
  private scroller: Scroller = new Scroller();
  private categoryService: CategoryService = CategoryService.getInstance();

  aboutToAppear(): void {
    this.categories = this.categoryService.getCategories();
  }

  onCategoryClick(categoryId: string): void {
    if (this.selectedCategory === categoryId) {
      return;
    }
    this.selectedCategory = categoryId;
    this.categories = this.categories.map(cat => ({
      id: cat.id,
      name: cat.name,
      isSelected: cat.id === categoryId
    } as Category));
    this.scroller.scrollTo({ xOffset: 0, yOffset: 0 });
    // 设置分类并重新加载数据
    this.dataSource.setCategory(categoryId);
  }

  onRefresh(): void {
    this.isRefreshing = true;
    this.dataSource.loadProducts();
    this.isRefreshing = false;
  }

  onScrollStop(): void {
    // 滚动停止时检查位置
    let yOffset = this.scroller.currentOffset().yOffset;
    this.showBackToTop = yOffset > 100;
    if (!this.isLoading && this.dataSource.getHasMore()) {
      this.dataSource.loadMore();
    }
  }

  scrollToTop(): void {
    this.scroller.scrollTo({
      xOffset: 0,
      yOffset: 0,
      animation: {
        duration: 500,
        curve: Curve.EaseInOut
      }
    });
    this.showBackToTop = false;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('毕办商城')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Row() {
          Image($r('app.media.search'))
            .width(24)
            .height(24)
            .onClick(() => Toast.showNotImplemented())
          Image($r('app.media.bell'))
            .width(24)
            .height(24)
            .margin({ left: 16 })
            .onClick(() => Toast.showNotImplemented())
        }
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor(Color.White)

      // 分类导航
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.categories, (category: Category) => {
            Text(category.name)
              .fontSize(14)
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .backgroundColor(category.isSelected ? '#ff4d4f' : '#e8e8e8')
              .fontColor(category.isSelected ? Color.White : '#666666')
              .borderRadius(16)
              .onClick(() => {
                this.onCategoryClick(category.id);
              })
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#f5f5f5')

      // 商品列表 - 使用 LazyForEach 实现懒加载
      Refresh({ refreshing: this.isRefreshing, offset: 50, friction: 70 }) {
        Scroll(this.scroller) {
          Column() {
            Grid() {
              LazyForEach(this.dataSource, (product: Product) => {
                GridItem() {
                  ProductCard({ product: product })
                }
              }, (product: Product) => product.id.toString())
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .padding(12)
            .width('100%')
            .backgroundColor('#f5f5f5')
            .onScrollIndex((firstIndex: number, lastIndex: number) => {
              // 滚动到接近底部时加载更多
              if (lastIndex >= this.dataSource.totalCount() - 2 && this.dataSource.getHasMore()) {
                this.dataSource.loadMore();
              }
            })

            // 到底提示
            if (!this.dataSource.getHasMore() && this.dataSource.totalCount() > 0) {
              Row() {
                Text('已经到底啦，没有更多商品了')
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding(16)
            }
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .width('100%')
        .backgroundColor('#f5f5f5')
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
      .width('100%')
      .layoutWeight(1)

      // 悬浮的返回顶部按钮
      Column() {
        Image($r('app.media.up'))
          .width(28)
          .height(28)
          
      }
      .width(44)
      .height(44)
      .backgroundColor('rgba(0, 0, 0, 0.5)')
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .position({ x: '82%', y: '90%' })
      .opacity(this.showBackToTop ? 1 : 0)
      .animation({ duration: 300 })
      .onClick(() => {
        this.scrollToTop();
      })
    }
    .width('100%')
    .height('100%')
  }
}

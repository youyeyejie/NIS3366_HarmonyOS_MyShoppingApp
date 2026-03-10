
import { Product } from '../models/Product';
import { ProductService } from '../services/ProductService';

/**
 * 商品数据源类，负责管理商品数据的加载和分页逻辑
 * 实现 IDataSource 接口，供组件使用
 */
export class ProductDataSource implements IDataSource {
  private products: Product[] = [];
  protected productService: ProductService = ProductService.getInstance();
  private listeners: DataChangeListener[] = [];
  private currentPage: number = 1;
  private readonly PAGE_SIZE: number = 6;
  private hasMore: boolean = true;
  protected category: string = 'all';

  constructor() {
    this.loadProducts();
  }

  /**
	 * 加载商品数据，支持分页加载和刷新
	 * @param loadMore 是否加载更多（分页）还是刷新（重置页码）
	 */
  loadProducts(loadMore: boolean = false): void {
    if (loadMore) {
      this.currentPage++;
    } else {
      this.currentPage = 1;
      this.products = [];
    }

    const newProducts = this.productService.getProducts(
      this.currentPage,
      this.PAGE_SIZE,
      this.category
    );

    if (loadMore) {
      this.products = [...this.products, ...newProducts];
    } else {
      this.products = newProducts;
    }

    this.hasMore = this.productService.hasMoreProducts(
      this.currentPage,
      this.PAGE_SIZE,
      this.category
    );

    this.notifyDataReload();
  }

	/**
	 * 加载更多数据，触发分页加载
	 */
  loadMore(): void {
    if (this.hasMore) {
      this.loadProducts(true);
    }
  }

	/**
	 * 获取是否还有更多数据可加载
	 * @returns 是否还有更多数据
	 */
  getHasMore(): boolean {
    return this.hasMore;
  }

	/**
	 * 获取当前数据总数
	 * @returns 当前数据总数
	 */
  getTotalCount(): number {
    return this.products.length;
  }

	/**
	 * 设置当前分类，重置数据并加载对应分类的商品
	 * @param category 分类ID
	 */
  setCategory(category: string): void {
    this.category = category;
    this.loadProducts();
  }

  // IDataSource 接口实现
	/**
	 * 获取当前数据总数
	 * @returns 当前数据总数
	 */
  totalCount(): number {
    return this.products.length;
  }

	/**
	 * 根据索引获取数据项
	 * @param index 数据索引
	 * @returns 数据项
	 */
  getData(index: number): Product {
    return this.products[index];
  }

	// 数据变更监听器管理
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }
}

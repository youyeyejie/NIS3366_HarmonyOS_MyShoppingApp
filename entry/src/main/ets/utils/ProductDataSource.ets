import { Product } from "../models/Product";
import { ProductService } from "../services/ProductService";

/**
 * 商品数据源类，负责管理商品数据的加载和分页逻辑
 * 实现 IDataSource 接口，供组件使用
 */
export class ProductDataSource implements IDataSource {
  private products: Product[] = [];
  protected productService: ProductService = ProductService.getInstance();
  private listeners: DataChangeListener[] = [];
  protected category: string = "all";

  constructor() {
    this.loadProducts();
  }

  /**
   * 加载商品数据（按分类全量刷新）
   */
  loadProducts(): void {
    this.products = this.productService.getProducts(this.category);
    this.notifyDataReload();
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
    this.listeners.forEach((listener) => {
      listener.onDataReloaded();
    });
  }
}

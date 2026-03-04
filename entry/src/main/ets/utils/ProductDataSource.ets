
import { Product } from '../models/Product';
import { ProductService } from '../services/ProductService';

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

    this.notifyDataChange();
  }

  loadMore(): void {
    if (this.hasMore) {
      this.loadProducts(true);
    }
  }

  getHasMore(): boolean {
    return this.hasMore;
  }

  getTotalCount(): number {
    return this.products.length;
  }

  setCategory(category: string): void {
    this.category = category;
    this.loadProducts();
  }

  // IDataSource 接口实现
  totalCount(): number {
    return this.products.length;
  }

  getData(index: number): Product {
    return this.products[index];
  }
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
  notifyDataChange(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }
}

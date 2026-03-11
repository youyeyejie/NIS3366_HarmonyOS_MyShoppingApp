import { CartItem } from "../models/CartItem";
import { CartService } from "../services/CartService";

/**
 * 购物车数据源，供 LazyForEach 按需渲染购物车商品。
 *
 * 实现 IDataSource 接口，供组件使用
 */
export class CartDataSource implements IDataSource {
  private items: CartItem[] = [];
  private listeners: DataChangeListener[] = [];
  protected cartService: CartService = CartService.getInstance();

  constructor(){
    this.loadCartItems();
  }

  /**
   * 加载购物车数据
   */
  loadCartItems(): void {
    this.items = this.cartService.getCartItems();
    this.notifyDataReload();
  }

  /**
   * 设置购物车数据，供外部调用更新数据
   * @param items 购物车商品列表
   */
  setItems(items: CartItem[]): void {
    this.items = items;
    this.notifyDataReload();
  }

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): CartItem {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const index = this.listeners.indexOf(listener);
    if (index >= 0) {
      this.listeners.splice(index, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener) => listener.onDataReloaded());
  }
}
import { CartItem } from '../models/CartItem';
import { CartService } from '../services/CartService';

export class CartDataSource implements IDataSource {
  private cartItems: CartItem[] = [];
  private cartService: CartService = CartService.getInstance();
  private listeners: DataChangeListener[] = [];

  constructor() {
    this.loadCartData();
  }

  loadCartData(): void {
    this.cartItems = this.cartService.getCartItems();
    this.notifyDataChange();
  }

  updateData(items: CartItem[]): void {
    this.cartItems = items;
    this.notifyDataChange();
  }

  // IDataSource 接口实现
  totalCount(): number {
    return this.cartItems.length;
  }

  getData(index: number): CartItem | undefined {
    if (index >= 0 && index < this.cartItems.length) {
      return this.cartItems[index];
    }
    return undefined;
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
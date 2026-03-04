import { Product } from '../models/Product';
import { CartItem } from '../models/CartItem';

// ==================== 服务类定义 ====================

// 全局购物车服务
export class CartService {
  private static instance: CartService;
  private cartItems: CartItem[] = [];
  private cartChangeCallbacks: (() => void)[] = [];

  private constructor() {}

  public static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService();
    }
    return CartService.instance;
  }

  // 添加商品到购物车
  public addToCart(product: Product): void {
    const existingItem = this.cartItems.find(item => item.product.id === product.id);
    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      this.cartItems.push({ product, quantity: 1 });
    }
    this.notifyCartChange();
  }

  // 从购物车移除商品
  public removeFromCart(productId: number): void {
    const index = this.cartItems.findIndex(item => item.product.id === productId);
    if (index > -1) {
      this.cartItems.splice(index, 1);
      this.notifyCartChange();
    }
  }

  // 更新商品数量
  public updateQuantity(productId: number, quantity: number): void {
    const item = this.cartItems.find(item => item.product.id === productId);
    if (item) {
      if (quantity <= 0) {
        this.removeFromCart(productId);
      } else {
        item.quantity = quantity;
        this.notifyCartChange();
      }
    }
  }

  // 获取购物车商品数量
  public getCartCount(): number {
    return this.cartItems.reduce((total, item) => total + item.quantity, 0);
  }

  // 获取购物车总价格
  public getCartTotal(): number {
    return this.cartItems.reduce((total, item) => total + (item.product.price * item.quantity), 0);
  }

  // 获取购物车所有商品
  public getCartItems(): CartItem[] {
    return this.cartItems;
  }

  // 清空购物车
  public clearCart(): void {
    this.cartItems = [];
    this.notifyCartChange();
  }

  // 监听购物车变化 - 支持多个监听器
  public onCartChange(callback: () => void): void {
    this.cartChangeCallbacks.push(callback);
  }

  // 通知购物车变化
  private notifyCartChange(): void {
    for (const callback of this.cartChangeCallbacks) {
      callback();
    }
  }
}

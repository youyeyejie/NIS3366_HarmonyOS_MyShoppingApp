import { ProductService } from '../services/ProductService';
import { CartItem } from '../models/CartItem';

/**
 * 购物车服务类，提供管理购物车的方法
 */
export class CartService {
  private static instance: CartService;
  private cartItems: CartItem[] = [];
  private cartChangeCallbacks: (() => void)[] = []; // 存储购物车变化回调函数

  private constructor() {}

  /**
   * 获取购物车服务实例（单例模式）
   */
  public static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService();
    }
    return CartService.instance;
  }

  /**
   * 添加商品到购物车
   * @param productId 要添加的商品ID
   */
  public addToCart(productId: number): void {
    // 检查购物车中是否已经存在该商品，如果存在则增加数量，否则添加新项
    const existingItem = this.cartItems.find(item => item.product.id === productId);
    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      const product = ProductService.getInstance().getProductById(productId);
      this.cartItems.push({ product: product!, quantity: 1 });
    }
    this.notifyCartChange();
  }

  /**
   * 从购物车中移除商品
   * @param productId 要移除的商品ID
   */
  public removeFromCart(productId: number): void {
    const index = this.cartItems.findIndex(item => item.product.id === productId);
    if (index > -1) {
      // 使用 splice 方法移除指定索引的商品项
      this.cartItems.splice(index, 1);
      this.notifyCartChange();
    }
  }

  /**
   * 更新商品数量
   * @param productId 商品ID
   * @param quantity 新数量
   */
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

  /**
   * 获取购物车商品数量
   */
  public getCartCount(): number {
    // 通过 reduce 方法累加购物车中所有商品的数量，返回总数量
    return this.cartItems.reduce((total, item) => total + item.quantity, 0);
  }

  /**
   * 获取购物车总价格
   */
  public getCartTotal(): number {
    return this.cartItems.reduce((total, item) => total + (item.product.price * item.quantity), 0);
  }

  /**
   * 获取购物车商品列表
   * @returns 购物车商品列表
   */
  public getCartItems(): CartItem[] {
    return this.cartItems;
  }

  /**
   * 清空购物车
   */
  public clearCart(): void {
    this.cartItems = [];
    this.notifyCartChange();
  }

  /**
   * 注册购物车变化回调函数，当购物车发生变化时调用
   * @param callback 购物车变化时的回调函数
   */
  public onCartChange(callback: () => void): void {
    this.cartChangeCallbacks.push(callback);
  }

  /**
   * 通知购物车变化，调用所有注册的回调函数
   */
  private notifyCartChange(): void {
    for (const callback of this.cartChangeCallbacks) {
      callback();
    }
  }
}

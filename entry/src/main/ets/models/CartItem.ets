import { Product } from './Product';

// 购物车商品项
export interface CartItem {
  product: Product;
  quantity: number;
}

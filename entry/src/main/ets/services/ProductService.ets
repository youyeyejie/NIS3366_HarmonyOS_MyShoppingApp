import { Product } from "../models/Product";

// 模拟商品数据
const MOCK_PRODUCTS: Product[] = [
    { id: 1, name: "Apple iPhone 15 256GB 黑色", price: 6999, img: "app.media.1", category: "电子产品" },
    { id: 2, name: "华为 Mate60 Pro 512GB 白色", price: 6799, img: "app.media.2", category: "电子产品" },
    { id: 3, name: "小米平板6 Pro 128GB 灰色", price: 2399, img: "app.media.3", category: "电子产品" },
    { id: 4, name: "苹果 AirPods Pro 2代", price: 1899, img: "app.media.4", category: "电子产品" },
    { id: 5, name: "大疆 Pocket 3 口袋相机", price: 3499, img: "app.media.5", category: "电子产品" },

    { id: 6, name: "耐克运动跑鞋 42码", price: 699, img: "app.media.6", category: "服装鞋帽" },
    { id: 7, name: "优衣库纯棉长袖T恤 白色", price: 99, img: "app.media.7", category: "服装鞋帽" },
    { id: 8, name: "李宁运动外套 黑色 L码", price: 399, img: "app.media.8", category: "服装鞋帽" },
    { id: 9, name: "阿迪达斯运动袜 5双装", price: 59, img: "app.media.9", category: "服装鞋帽" },
    { id: 10, name: "韩版百搭牛仔裤 29码", price: 159, img: "app.media.10", category: "服装鞋帽" },

    { id: 11, name: "家用纯棉四件套 1.8m", price: 299, img: "app.media.11", category: "家居用品" },
    { id: 12, name: "简约陶瓷水杯 400ml", price: 29, img: "app.media.12", category: "家居用品" },
    { id: 13, name: "多功能收纳盒 大号", price: 49, img: "app.media.13", category: "家居用品" },
    { id: 14, name: "静音落地风扇 白色", price: 199, img: "app.media.14", category: "家居用品" },
    { id: 15, name: "厨房不锈钢菜刀", price: 69, img: "app.media.15", category: "家居用品" },

    { id: 16, name: "保湿补水面霜 50g", price: 199, img: "app.media.16", category: "美妆护肤" },
    { id: 17, name: "防水防汗粉底液 30ml", price: 159, img: "app.media.17", category: "美妆护肤" },
    { id: 18, name: "温和洁面乳 100ml", price: 79, img: "app.media.18", category: "美妆护肤" },

    { id: 19, name: "新鲜草莓 500g", price: 39, img: "app.media.19", category: "食品生鲜" },
    { id: 20, name: "纯牛奶 250ml*12盒", price: 59, img: "app.media.20", category: "食品生鲜" }
];

export class ProductService {
  private static instance: ProductService;

  private constructor() {}

  public static getInstance(): ProductService {
    if (!ProductService.instance) {
      ProductService.instance = new ProductService();
    }
    return ProductService.instance;
  }
  // 获取商品列表（支持分页）
  public getProducts(page: number, pageSize: number, category?: string): Product[] {
    let filtered = MOCK_PRODUCTS;
    if (category && category !== "all") {
      filtered = MOCK_PRODUCTS.filter((p) => p.category === category);
    }
    const start = (page - 1) * pageSize;
    const end = start + pageSize;
    return filtered.slice(start, end);
  }
  // 检查是否还有更多商品
  public hasMoreProducts(page: number, pageSize: number, category?: string): boolean {
    let filtered = MOCK_PRODUCTS;
    if (category && category !== "all") {
      filtered = MOCK_PRODUCTS.filter((p) => p.category === category);
    }
    return page * pageSize < filtered.length;
  }
}

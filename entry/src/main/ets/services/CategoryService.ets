import { Category } from '../models/Category';

// 分类数据
const MOCK_CATEGORIES: Category[] = [
  { id: 'all', name: '全部', isSelected: true },
  { id: '电子产品', name: '电子产品', isSelected: false },
  { id: '服装鞋帽', name: '服装鞋帽', isSelected: false },
  { id: '家居用品', name: '家居用品', isSelected: false },
  { id: '美妆护肤', name: '美妆护肤', isSelected: false },
  { id: '食品生鲜', name: '食品生鲜', isSelected: false },
];

/**
 * 分类服务类，提供获取分类列表的方法
 */
export class CategoryService {
  private static instance: CategoryService;

  private constructor() {}


  /**
   * 获取单例实例
   * @returns CategoryService 单例实例
   */
  public static getInstance(): CategoryService {
    if (!CategoryService.instance) {
      CategoryService.instance = new CategoryService();
    }
    return CategoryService.instance;
  }


  /**
   * 获取分类列表
   * @returns 分类列表
   */
  public getCategories(): Category[] {
    return MOCK_CATEGORIES;
  }
}
import { UserInfo } from "../models/UserInfo";

// 用户数据
const MOCK_USER: UserInfo = {
  id: "1",
  name: "遥遥领先!",
  avatar: "app.media.avatar",
  memberLevel: "普通花粉",
};

/**
 * 用户服务类，提供获取用户信息的方法
 */
export class UserService {
  private static instance: UserService;

  private constructor() {}

  /**
   * 获取单例实例
   * @returns UserService 单例实例
   */
  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }

  /**
   * 获取用户信息
   * @returns UserInfo 用户信息
   */
  public getUserInfo(): UserInfo {
    return MOCK_USER;
  }
}

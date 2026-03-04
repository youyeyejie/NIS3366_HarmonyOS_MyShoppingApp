import { UserInfo } from "../models/UserInfo";

// 用户数据
const MOCK_USER: UserInfo = {
  id: "1",
  name: "遥遥领先!",
  avatar: "app.media.avatar",
  memberLevel: "星会员",
};

export class UserService {
  private static instance: UserService;

  private constructor() {}

  public static getInstance(): UserService {
    if (!UserService.instance) {
      UserService.instance = new UserService();
    }
    return UserService.instance;
  }
  // 获取用户信息
  public getUserInfo(): UserInfo {
    return MOCK_USER;
  }
}

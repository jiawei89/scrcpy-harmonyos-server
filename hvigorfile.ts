import { appTasks } from '@ohos/hvigor-ohos-plugin';

export default {
  system: appTasks,
  /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: [],
  /* Custom plugin to extend the functionality of Hvigor. */
  overrides: {
    // HarmonyOS 6.0.2 使用 overrides 而不是 config
    // 签名配置现在通过 DevEco Studio 的项目结构设置管理
    // 或者通过 oh-package.json5 中的 signingConfigs 配置
  }
};

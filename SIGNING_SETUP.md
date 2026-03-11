# HarmonyOS 签名配置说明

## 签名文件说明

本项目采用模块化的签名配置方式，签名信息存储在独立的配置文件中。

### 签名配置文件
- `signdata.json` - 签名信息配置文件（已添加到.gitignore）
- `build-profile.json5` - 工程级构建配置，包含签名配置
- `hvigorfile.ts` - 构建脚本，支持动态加载签名配置

### 签名文件生成方式

#### 方式一：自动签名（推荐用于开发）
1. 连接HarmonyOS真机到电脑
2. 在DevEco Studio中选择：File > Project Structure > Project > Signing Configs
3. 勾选"Automatically generate signature"
4. 系统会自动生成签名文件

#### 方式二：手动签名（用于发布）
1. 在DevEco Studio中选择：Build > Generate Key and CSR
2. 创建新的密钥库文件或选择现有文件
3. 填写密钥信息并生成CSR文件
4. 登录AppGallery Connect申请调试证书和Profile文件
5. 将生成的证书文件放入项目根目录

### 签名文件说明
- `debug.p12` - 密钥库文件（包含私钥）
- `debug.cer` - 数字证书文件
- `debug.p7b` - Profile文件

### 团队协作说明

由于签名文件包含敏感信息，建议：
1. 团队使用同一套调试签名文件
2. 将签名文件添加到.gitignore避免提交
3. 通过内部渠道共享签名文件

### 验证签名配置

运行以下命令验证签名配置：
```bash
# 构建应用
npm run build

# 或使用hvigor命令
hvigor assembleHap
```

### 常见问题

1. **签名失败**：检查签名文件路径和密码是否正确
2. **设备不匹配**：确保设备UDID已添加到Profile文件中
3. **证书过期**：重新申请新的调试证书
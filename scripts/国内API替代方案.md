# 🇨🇳 国内可用的翻译API方案

## ⚠️ 重要说明

由于OpenAI API在国内无法直接访问，以下是**完全可用的替代方案**：

---

## 🎯 推荐方案（按优先级）

### 方案1：智谱AI (GLM-4) ⭐ 最推荐
**优势**：
- ✅ 国内公司，访问稳定
- ✅ 完全兼容OpenAI API格式
- ✅ 翻译质量接近GPT-4
- ✅ 价格便宜（¥0.01/千tokens）
- ✅ 新用户送100万tokens免费额度

**申请步骤**：
1. 访问：https://open.bigmodel.cn
2. 注册账号（手机号即可）
3. 创建API密钥
4. 复制密钥（格式类似：`xxxx.xxxxxxxxxxxxxxxx`）

**使用方法**：
```powershell
$env:OPENAI_API_KEY = "你的智谱AI密钥"
$env:OPENAI_API_BASE = "https://open.bigmodel.cn/api/paas/v4"

.\scripts\publish-daily-commentary-v3-china.ps1 `
    -ContentFile chinese-only.json `
    -AutoTranslate `
    -ApiProvider "zhipu"
```

---

### 方案2：DeepSeek
**优势**：
- ✅ 国内公司，稳定访问
- ✅ 兼容OpenAI格式
- ✅ 价格极低（¥1/百万tokens）
- ✅ 新用户送500万tokens

**申请步骤**：
1. 访问：https://platform.deepseek.com
2. 注册账号
3. 创建API密钥
4. 复制密钥

**使用方法**：
```powershell
$env:OPENAI_API_KEY = "你的DeepSeek密钥"

.\scripts\publish-daily-commentary-v3-china.ps1 `
    -ContentFile chinese-only.json `
    -AutoTranslate `
    -ApiProvider "deepseek"
```

---

### 方案3：Moonshot AI (月之暗面)
**优势**：
- ✅ Kimi Chat背后的公司
- ✅ 兼容OpenAI格式
- ✅ 上下文长度大（200K）
- ✅ 新用户送15元体验金

**申请步骤**：
1. 访问：https://platform.moonshot.cn
2. 注册登录
3. 创建API Key
4. 复制密钥

**使用方法**：
```powershell
$env:OPENAI_API_KEY = "你的Moonshot密钥"

.\scripts\publish-daily-commentary-v3-china.ps1 `
    -ContentFile chinese-only.json `
    -AutoTranslate `
    -ApiProvider "moonshot"
```

---

### 方案4：阿里云百炼（通义千问）
**优势**：
- ✅ 阿里云服务，企业级稳定
- ✅ 兼容OpenAI格式
- ✅ 新用户送额度

**申请步骤**：
1. 访问：https://bailian.console.aliyun.com
2. 开通服务
3. 创建API Key

---

### 方案5：腾讯混元
**优势**：
- ✅ 腾讯云服务
- ✅ 企业级可靠性

**申请步骤**：
1. 访问：https://cloud.tencent.com/product/hunyuan
2. 开通服务

---

## 📊 价格对比

| 服务商 | 价格（每百万tokens） | 新用户赠送 | 推荐度 |
|--------|---------------------|-----------|--------|
| **智谱AI GLM-4** | ¥10 | 100万tokens | ⭐⭐⭐⭐⭐ |
| **DeepSeek** | ¥1 | 500万tokens | ⭐⭐⭐⭐⭐ |
| **Moonshot** | ¥12 | ¥15 | ⭐⭐⭐⭐ |
| 阿里通义 | ¥8-20 | 有额度 | ⭐⭐⭐ |
| 腾讯混元 | ¥15 | 有额度 | ⭐⭐⭐ |

**估算**：每次发布翻译约消耗 2000 tokens ≈ ¥0.02

---

## 🚀 我已经为你修改了脚本

新脚本：`publish-daily-commentary-v3-china.ps1`

支持的API提供商：
- ✅ `zhipu` - 智谱AI (默认推荐)
- ✅ `deepseek` - DeepSeek
- ✅ `moonshot` - Moonshot AI
- ✅ `openai` - OpenAI (需代理)

---

## 💡 快速开始（以智谱AI为例）

### 步骤1：注册智谱AI
```
浏览器打开：https://open.bigmodel.cn
点击"注册" → 手机号验证 → 完成
```

### 步骤2：获取API密钥
```
登录后点击"API Keys"
点击"创建新密钥"
复制密钥（格式：xxxx.xxxxxxxxxxxxxxxx）
```

### 步骤3：设置并使用
```powershell
# 设置API密钥
$env:ZHIPU_API_KEY = "你复制的密钥"

# 使用
.\scripts\publish-daily-commentary-v3-china.ps1 `
    -ContentFile scripts\daily-commentary-chinese-only.sample.json `
    -AutoTranslate `
    -ApiProvider "zhipu" `
    -Deploy
```

---

## 🔧 如果遇到问题

### 问题1：无法访问某个API
**解决**：切换到其他提供商（如DeepSeek或Moonshot）

### 问题2：API额度不足
**解决**：
- 充值（通常¥10可用很久）
- 注册新账号使用免费额度
- 切换到更便宜的DeepSeek

### 问题3：翻译质量不满意
**解决**：
- 使用GLM-4（智谱最新模型）
- 调整temperature参数（脚本中已优化）

---

## ⚡ 其他替代方案

### 方案A：本地翻译（完全免费）
使用Ollama + Qwen2模型本地翻译：
```powershell
# 安装Ollama
# 访问：https://ollama.com/download

# 下载中文翻译模型
ollama pull qwen2:7b

# 使用本地API
.\scripts\publish-daily-commentary-v3-china.ps1 `
    -ApiProvider "ollama" `
    -AutoTranslate
```

### 方案B：人工翻译助手
使用国内可访问的AI助手预翻译，然后复制到JSON：
- 文心一言（https://yiyan.baidu.com）
- 豆包（https://www.doubao.com）
- Kimi（https://kimi.moonshot.cn）

---

## 📝 总结

**最简单方案**：
1. 注册智谱AI（5分钟，免费100万tokens）
2. 复制API密钥
3. 运行新脚本
4. 完成！

**最省钱方案**：
DeepSeek（仅¥1/百万tokens，送500万）

**最稳定方案**：
阿里云百炼（企业级服务）

**完全免费方案**：
本地Ollama（无需网络，完全隐私）

---

需要我帮你配置哪个方案？🚀

## 新增需求

### 需求：应用内校验与支付 (In-App Verification & Payment)
系统必须支持两种主要的购买选项，并在服务器端进行订单校验。Android 渠道支持微信/支付宝，iOS 支持 IAP。

#### 场景：应用内购买校验 (iOS IAP)
- **当 (WHEN)** iOS 用户完成 App Store 的支付流程
- **那么 (THEN)** 应用将支付收据 (Receipt) 发送至 Go 后端 `/api/v1/payment/verify/apple`
- **并且 (AND)** Go 后端服务器验证收据有效性
- **并且 (AND)** 验证通过后，MySQL 更新用户的 `is_pro` 字段

#### 场景：Android 支付 (微信/支付宝)
- **当 (WHEN)** Android 用户点击升级 Pro
- **那么 (THEN)** 弹出微信支付或支付宝选项
- **并且 (AND)** 用户选择支付方式后，App 调用对应 SDK 调起支付
- **并且 (AND)** 支付完成后，微信/支付宝回调 Go 后端 `/api/v1/payment/notify/{provider}`
- **并且 (AND)** Go 后端验证签名和金额，更新用户的 `is_pro` 字段
- **并且 (AND)** 客户端轮询或通过长连接获取支付成功状态

### 需求：广告交互 (Ad Interaction)
系统必须为免费用户显示非侵入式广告。

#### 场景：免费用户查看记录
- **当 (WHEN)** 免费用户浏览应用
- **那么 (THEN)** 屏幕底部显示一个小横幅广告
- **并且 (AND)** 广告不遮挡内容或强制交互

#### 场景：Pro 用户查看记录
- **当 (WHEN)** Pro 用户浏览应用
- **那么 (THEN)** 不显示任何广告

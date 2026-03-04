# 任务 - 初始化毛孩子日记 (Furry Diary)

## 1. 项目设置与基础设施 (Infrastructure)

### 客户端 (Flutter)
- [x] 1.1 初始化 Flutter 项目 `furry_diary` 及目录结构。
- [x] 1.2 添加基础依赖：`hive`, `dio`, `json_serializable`, `riverpod`, `flutter_secure_storage`。
- [x] 1.3 添加业务依赖：`permission_handler`, `image_picker`, `flutter_local_notifications`。
- [x] 1.4 配置 `Hive` 本地存储与 `Sync` 状态模型。

### 服务端 (Go)
- [x] 1.5 初始化 Go 项目 `furry-server`。
- [x] 1.6 依赖安装：`gin`, `gorm`, `mysql`, `jwt`, `viper`。
- [x] 1.7 [Design] 设计 MySQL 数据库表：
    - `users`: `id`, `phone`, `password_hash`, `is_pro`。
    - `pets`: `id`, `user_id`, `name`, `...`。
    - `health_records`: `id`, `pet_id`, `type` (vaccine/deworm/etc), `date`, `next_due_date`。
    - `orders`: `id`, `user_id`, `amount`, `provider` (wechat/alipay/apple), `status`。
- [x] 1.8 搭建基础中间件：CORS, JWT Auth, Logging, Error Handling。

## 2. 功能：用户认证 (User Auth - CN)

- [x] 2.1 [Go] 集成 SMS 服务 (阿里云/腾讯云) 接口：`POST /auth/sms/send`。
- [x] 2.2 [Go] 实现手机号注册/登录接口：`POST /auth/login/phone` (自动注册)。
- [x] 2.3 [Flutter] 实现“访客模式”：无账号也可使用核心功能。
- [x] 2.4 [Flutter] 实现手机号登录 UI：输入手机号 -> 获取验证码 -> 登录。
- [x] 2.5 [Flutter] 实现“数据合并”逻辑：访客登录后，将本地数据上传合并到账号。

## 3. 功能：健康记录卡片 (Health Cards)

- [x] 3.1 [Flutter] 实现 `HealthCard` 组件：
    - 展示图标、上次记录时间。
    - 状态指示：正常/即将到期/已逾期 (基于 `next_due_date`)。
- [x] 3.2 [Flutter] 实现“健康卡片网格”页面：疫苗、驱虫、体检、用药、洗澡、体重。
- [x] 3.3 [Flutter] 实现 `TimelinePage`：通过卡片进入，展示该类型的历史记录轴。
- [x] 3.4 [Flutter] 录入表单：从卡片进入时自动锁定类型。

## 4. 核心功能：数据同步 (Cloud Sync)

- [x] 4.1 [Shared] 定义统一的数据模型 (Models) 和 JSON 结构。
- [x] 4.2 [Go] 实现同步接口 `POST /sync`：接收 `dirty` 数据，返回新数据。
- [x] 4.3 [Flutter] 实现 `SyncManager`：
    - 记录 `last_synced_at`。
    - 自动/手动触发同步。

## 5. 功能：盈利与支付 (Monetization - CN)

- [x] 5.1 [Go] 实现订单接口：`POST /payment/order` (创建预支付订单)。
- [x] 5.2 [Go] 实现回调接口：`POST /payment/notify/{provider}` (处理微信/支付宝回调)。
- [x] 5.3 [Go] 实现 IAP 验证：`POST /payment/verify/apple`。
- [x] 5.4 [Flutter] 集成支付 SDK (微信/支付宝/IAP)。
- [x] 5.5 [Flutter] 根据 `user.is_pro` 状态解锁高级功能 (如无限制记录)。

## 6. 其他功能

- [x] 6.1 [Flutter] 本地通知：根据 `next_due_date` 调度提醒。
- [x] 6.2 [Go] 实现文件上传接口 (头像/附件)。
- [x] 6.3 [Flutter] 完善个人中心与设置页。

## 7. 部署与发布

- [x] 7.1 [Go] 编写 `Dockerfile`。
- [x] 7.2 [Flutter] 构建 Android APK (Release 签名)。

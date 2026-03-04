# 设计 - 初始化 App

## 架构概览
- 客户端：Flutter（Android/iOS），离线优先，本地存储为主。
- 服务端：Go + Gin + Gorm + MySQL，提供认证、同步、支付与上传接口。
- 同步策略：基于 `last_synced_at` 的增量同步，客户端上传 `dirty` 变更后拉取更新。

## 关键模块
1. 用户认证：访客模式 + 手机号验证码登录。
2. 健康记录：卡片网格 + 类型时间轴 + 类型锁定录入。
3. 同步：`POST /api/v1/sync`。
4. 支付：Android 微信/支付宝、iOS IAP 验证。
5. 提醒：本地通知按 `next_due_date` 调度。

## 数据模型
- users(id, phone, password_hash, is_pro)
- pets(id, user_id, name, ...)
- health_records(id, pet_id, type, date, next_due_date)
- orders(id, user_id, amount, provider, status)

## 发布
- Android 通过 Flutter release 构建生成 APK。

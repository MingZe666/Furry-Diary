# Tasks

## 后端修复任务

- [x] Task 1: 修复 auth.go 验证码生成逻辑
  - [x] SubTask 1.1: 实现随机验证码生成函数
  - [x] SubTask 1.2: 修改 SendSMS 方法使用随机验证码
  - [x] SubTask 1.3: 开发环境下允许固定验证码但添加日志警告

- [x] Task 2: 修复 auth.go JWT生成错误处理
  - [x] SubTask 2.1: 添加错误处理，JWT生成失败时返回500错误
  - [x] SubTask 2.2: 统一所有登录接口的错误处理

- [x] Task 3: 修复 auth.go need_setup_profile 逻辑
  - [x] SubTask 3.1: 新用户创建时不设置默认昵称
  - [x] SubTask 3.2: 或者修改判断条件为检查是否为自动生成的昵称

- [x] Task 4: 修复 user.go 账户删除逻辑
  - [x] SubTask 4.1: 将硬删除改为软删除
  - [x] SubTask 4.2: 确保软删除正确设置 deleted_at 字段

- [x] Task 5: 修复 sync.go 解析错误处理
  - [x] SubTask 5.1: 添加 petID 解析错误处理
  - [x] SubTask 5.2: 解析失败时跳过该记录并记录日志

- [x] Task 6: 修复 sync.go DeletedAt 零值问题
  - [x] SubTask 6.1: 检查 DeletedAt 是否为空再返回
  - [x] SubTask 6.2: 空值返回 null 而非零值

- [x] Task 7: 修复 models.go JSON标签格式
  - [x] SubTask 7.1: 修正 SMSCode.ExpiresAt 的 JSON 标签

## 前端修复任务

- [x] Task 8: 修复 auth_service.dart 变量重新赋值问题
  - [x] SubTask 8.1: 使用新变量名接收 copyWith 结果
  - [x] SubTask 8.2: 修复所有相关位置（loginByPhone, loginByWechat, loginByQQ, fetchProfile）

- [x] Task 9: 修复 sync_manager.dart 脏数据判断逻辑
  - [x] SubTask 9.1: 为 PetProfile 添加 isSynced 字段
  - [x] SubTask 9.2: 修改脏数据判断逻辑基于 isSynced 标记

- [x] Task 10: 修复 devices_page.dart 空列表异常
  - [x] SubTask 10.1: 添加空列表检查
  - [x] SubTask 10.2: 空列表时设置 currentDeviceId 为 null

# Task Dependencies
- [Task 2] 可与 [Task 1] 并行
- [Task 8] 无依赖
- [Task 9] 需要先修改 PetProfile 模型
- [Task 10] 无依赖

# 代码审查问题修复检查清单

## 后端修复检查

- [x] auth.go 验证码生成使用随机值而非硬编码
- [x] auth.go JWT生成失败时正确返回错误
- [x] auth.go need_setup_profile 逻辑正确判断新用户
- [x] user.go 账户删除使用软删除
- [x] sync.go petID 解析错误被正确处理
- [x] sync.go DeletedAt 空值返回 null 而非零值
- [x] models.go SMSCode.ExpiresAt JSON 标签格式正确

## 前端修复检查

- [x] auth_service.dart 不再对 final 变量重新赋值
- [x] sync_manager.dart 脏数据判断基于 isSynced 标记
- [x] PetProfile 模型包含 isSynced 字段
- [x] devices_page.dart 空列表时不抛出异常

## 功能验证

- [x] 手机号登录流程正常（验证码生成、JWT生成、新用户判断）
- [x] 新用户注册后正确引导设置资料（need_setup_profile 逻辑修复）
- [x] 账户注销后数据被软删除（user.go 修复）
- [x] 数据同步正常工作（sync.go 错误处理、脏数据判断修复）
- [x] 设备管理页面正常显示（空列表处理修复）

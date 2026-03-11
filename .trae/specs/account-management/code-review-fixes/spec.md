# 代码审查问题修复 Spec

## Why
在账户管理功能实现过程中，发现后端和前端代码存在多个潜在问题，包括逻辑错误、错误处理缺失、安全问题等，需要修复以确保代码质量和系统稳定性。

## What Changes
- 修复后端 auth.go 中验证码生成逻辑和错误处理
- 修复后端 user.go 中账户删除应使用软删除
- 修复后端 sync.go 中错误处理缺失问题
- 修复后端 models.go 中 JSON 标签格式错误
- 修复前端 auth_service.dart 中变量重新赋值问题
- 修复前端 sync_manager.dart 中脏数据判断逻辑
- 修复前端 devices_page.dart 中空列表异常处理

## Impact
- Affected code: 
  - `furry_server/internal/handlers/auth.go`
  - `furry_server/internal/handlers/user.go`
  - `furry_server/internal/handlers/sync.go`
  - `furry_server/internal/models/models.go`
  - `furry_diary/lib/services/auth_service.dart`
  - `furry_diary/lib/services/sync_manager.dart`
  - `furry_diary/lib/pages/devices_page.dart`

## ADDED Requirements

### Requirement: 验证码生成逻辑
系统 SHALL 生成随机验证码而非使用硬编码值。

#### Scenario: 发送验证码
- **WHEN** 用户请求发送验证码
- **THEN** 系统应生成6位随机数字验证码
- **AND** 如果SMS提供商不可用，应记录日志并使用开发模式

### Requirement: 错误处理
所有可能失败的操作 SHALL 正确处理错误。

#### Scenario: JWT生成失败
- **WHEN** JWT生成失败
- **THEN** 应返回错误而非忽略

#### Scenario: 解析失败
- **WHEN** 解析ID失败
- **THEN** 应记录错误并跳过该记录

### Requirement: 软删除
账户删除 SHALL 使用软删除而非硬删除。

#### Scenario: 注销账户
- **WHEN** 用户注销账户
- **THEN** 系统应设置 deleted_at 字段而非物理删除记录

## MODIFIED Requirements

### Requirement: 脏数据判断
同步时脏数据判断 SHALL 基于同步状态而非 updatedAt 字段。

#### Scenario: 判断脏数据
- **WHEN** 同步上传数据
- **THEN** 应检查 isSynced 标记
- **AND** 宠物数据应添加 isSynced 字段支持

## 发现的问题清单

### 后端问题

#### 1. auth.go - 验证码硬编码 (高优先级)
**位置**: 第75行
**问题**: 验证码 `code := "123456"` 硬编码，应该生成随机验证码
**影响**: 安全风险，开发环境测试代码可能泄露到生产环境

#### 2. auth.go - JWT生成错误忽略 (中优先级)
**位置**: 第145、196、244行
**问题**: `token, _ := h.generateJWT(...)` 忽略了错误返回值
**影响**: JWT生成失败时可能导致后续操作异常

#### 3. auth.go - need_setup_profile 逻辑错误 (低优先级)
**位置**: 第151行
**问题**: 新用户创建时已设置默认昵称，`user.Nickname == ""` 永远为 false
**影响**: 新用户引导流程可能不正确

#### 4. user.go - 硬删除而非软删除 (高优先级)
**位置**: 第92行
**问题**: `h.DB.Delete(&models.User{}, uid)` 是硬删除
**影响**: 数据无法恢复，不符合需求文档要求

#### 5. sync.go - 解析错误忽略 (中优先级)
**位置**: 第70、106行
**问题**: `petID, _ := strconv.ParseUint(...)` 忽略错误
**影响**: 无效ID可能导致数据关联错误

#### 6. sync.go - DeletedAt 零值问题 (低优先级)
**位置**: 第170、192行
**问题**: `p.DeletedAt.Time` 当 DeletedAt 为空时返回零值
**影响**: 可能导致前端收到 "0001-01-01" 日期

#### 7. models.go - JSON标签格式错误 (高优先级)
**位置**: 第115行
**问题**: `json:"expires_at;not null"` 格式错误，应该是两个独立的标签
**影响**: JSON序列化可能失败

### 前端问题

#### 8. auth_service.dart - 变量重新赋值 (高优先级)
**位置**: 第61、92、125、197行
**问题**: `user = user.copyWith(token: token)` 对 final 变量重新赋值
**影响**: 编译错误或运行时异常

#### 9. sync_manager.dart - 脏数据判断逻辑 (中优先级)
**位置**: 第78行
**问题**: `pets.where((p) => p.updatedAt != null)` 判断逻辑不正确
**影响**: 可能同步不必要的数据或遗漏需要同步的数据

#### 10. devices_page.dart - 空列表异常 (中优先级)
**位置**: 第39行
**问题**: `_devices.first` 在列表为空时会抛出异常
**影响**: 设备列表为空时应用崩溃

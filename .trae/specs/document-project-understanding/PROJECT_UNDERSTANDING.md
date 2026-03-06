# 毛孩子日记 - 项目理解文档

> 本文档整合了项目的核心信息，包括定位、架构、技术栈、功能模块、代码设计细节等，便于开发者快速了解项目全貌。

---

## 目录

1. [项目定位](#1-项目定位)
2. [架构概览](#2-架构概览)
3. [技术栈](#3-技术栈)
4. [功能模块](#4-功能模块)
5. [商业模式](#5-商业模式)
6. [数据模型](#6-数据模型)
7. [API 接口](#7-api-接口)
8. [开发指南](#8-开发指南)
9. [UI 设计](#9-ui-设计)
10. [代码设计细节](#10-代码设计细节)

---

## 1. 项目定位

### 1.1 基本信息

| 项目 | 内容 |
|------|------|
| **名称** | 毛孩子日记 |
| **口号** | 离线也安心，记录毛孩子的每一次成长 |
| **类型** | 宠物健康管理工具 |

### 1.2 核心价值

- **纯本地离线**：无联网权限也能使用，数据安全私密
- **极简设计**：无广告打扰，专注宠物健康记录
- **不社交、不电商**：纯粹的工具属性，无社区、无商城

### 1.3 目标用户

- 养猫、养狗的宠物主人
- 需要记录宠物疫苗、驱虫、体检等健康信息的用户
- 注重隐私、偏好离线工具的用户

### 1.4 使用场景

- 记录宠物疫苗接种时间和下次提醒
- 追踪驱虫、体检、洗澡等健康事项
- 导出疫苗本用于宠物医院就诊
- 多宠物家庭的档案管理

---

## 2. 架构概览

### 2.1 项目结构

```
Furry-Diary/
├── furry_diary/              # Flutter 前端应用
│   ├── android/              # Android 平台配置
│   ├── assets/               # 静态资源（图标等）
│   ├── lib/
│   │   ├── main.dart             # 应用入口
│   │   ├── config/               # 构建配置
│   │   ├── l10n/                 # 国际化资源
│   │   ├── models/               # 数据模型
│   │   ├── navigation/           # 导航相关
│   │   ├── pages/                # UI 页面
│   │   ├── providers/            # 状态管理
│   │   ├── services/             # 服务层
│   │   └── widgets/              # 通用组件
│   ├── pubspec.yaml          # 依赖配置
│   └── analysis_options.yaml  # 代码规范配置
│
├── furry_server/             # Go 后端服务
│   ├── cmd/
│   │   └── server/
│   │       └── main.go           # 服务入口
│   ├── internal/
│   │   ├── handlers/             # HTTP 处理器
│   │   ├── middleware/           # 中间件
│   │   ├── models/               # 数据模型
│   │   └── services/             # 业务服务
│   ├── migrations/               # 数据库迁移
│   ├── Dockerfile                # Docker 构建文件
│   └── go.mod                    # Go 模块配置
│
├── openspec/                 # 项目规格文档
│   ├── Project.md                # 产品定位文档
│   ├── config.yaml               # 规格配置
│   ├── specs/                    # 功能规格说明
│   └── changes/                  # 变更记录
│
└── .trae/                    # Trae IDE 配置
    ├── rules/                    # 项目规则
    └── specs/                    # 规格文档
```

### 2.2 模块划分

#### 前端模块（Flutter）

| 模块 | 目录 | 职责 |
|------|------|------|
| 入口 | `main.dart` | 应用初始化、Provider 注入 |
| 页面 | `pages/` | 各功能页面的 UI 实现 |
| 状态管理 | `providers/` | Riverpod Provider 定义 |
| 服务层 | `services/` | 业务逻辑、数据存储、网络请求 |
| 数据模型 | `models/` | 实体类定义、序列化 |
| 国际化 | `l10n/` | 多语言资源 |
| 组件 | `widgets/` | 可复用 UI 组件 |

#### 后端模块（Go）

| 模块 | 目录 | 职责 |
|------|------|------|
| 入口 | `cmd/server/` | 服务启动、路由配置 |
| 处理器 | `internal/handlers/` | HTTP 请求处理 |
| 中间件 | `internal/middleware/` | 日志、错误处理、JWT 认证 |
| 模型 | `internal/models/` | 数据库模型定义 |
| 服务 | `internal/services/` | 业务逻辑（短信等） |

### 2.3 数据流

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter App                           │
│  ┌─────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │  Pages  │───▶│  Providers  │───▶│     Services        │  │
│  │  (UI)   │◀───│ (Riverpod)  │◀───│ (LocalStore/Auth)   │  │
│  └─────────┘    └─────────────┘    └──────────┬──────────┘  │
│                                              │              │
│                    ┌─────────────────────────┼────────────┐ │
│                    │                         ▼            │ │
│                    │  ┌─────────────────────────────────┐ │ │
│                    │  │         Hive (本地存储)          │ │ │
│                    │  └─────────────────────────────────┘ │ │
│                    └─────────────────────────┬────────────┘ │
└──────────────────────────────────────────────┼─────────────┘
                                               │ (可选同步)
                                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Go Server (可选)                        │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │  Handlers   │───▶│  Services   │───▶│    MySQL        │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. 技术栈

### 3.1 前端技术栈（Flutter）

| 技术 | 版本 | 用途 |
|------|------|------|
| **Flutter** | 3.2+ | 跨平台移动应用框架 |
| **Riverpod** | 2.4.9 | 状态管理 |
| **Hive** | 2.2.3 | 本地 NoSQL 数据库 |
| **Dio** | 5.3.3 | HTTP 网络请求 |
| **in_app_purchase** | 3.2.0 | 应用内购买 |
| **flutter_localizations** | SDK | 国际化支持 |
| **intl** | 0.20.2 | 国际化工具 |
| **flutter_local_notifications** | 17.2.4 | 本地通知 |
| **flutter_secure_storage** | 9.0.0 | 安全存储 |
| **image_picker** | 1.1.2 | 图片选择 |
| **flutter_animate** | 4.5.2 | 动画效果 |
| **flutter_slidable** | 4.0.3 | 滑动操作 |
| **path_provider** | 2.1.5 | 文件路径 |
| **file_picker** | 8.1.2 | 文件选择 |
| **share_plus** | 10.0.2 | 分享功能 |
| **uuid** | 4.5.3 | UUID 生成 |
| **connectivity_plus** | 5.0.2 | 网络状态检测 |

### 3.2 后端技术栈（Go）

| 技术 | 用途 |
|------|------|
| **Gin** | Web 框架 |
| **GORM** | ORM 框架 |
| **MySQL** | 关系型数据库 |
| **Viper** | 配置管理 |
| **JWT** | 身份认证 |

### 3.3 技术选型原因

| 技术 | 选型原因 |
|------|----------|
| **Flutter** | 跨平台开发效率高，一套代码支持 iOS/Android |
| **Riverpod** | 编译时安全，易于测试，支持依赖注入 |
| **Hive** | 轻量级本地存储，无需原生依赖，性能优秀 |
| **Gin** | 高性能 HTTP 框架，API 设计简洁 |
| **GORM** | 功能完善的 ORM，支持自动迁移 |

---

## 4. 功能模块

### 4.1 宠物档案（Pet Profile）

**功能描述**：管理宠物的基本信息

| 字段 | 类型 | 说明 |
|------|------|------|
| 头像 | 图片 | 支持拍照或相册选择 |
| 名字 | 文本 | 必填 |
| 物种 | 文本 | 如猫、狗 |
| 品种 | 文本 | 如英短、金毛 |
| 性别 | 枚举 | 公/母 |
| 是否绝育 | 布尔 | - |
| 体重 | 数值 | kg |
| 毛色 | 文本 | - |
| 芯片号 | 文本 | 宠物芯片编号 |
| 生日 | 日期 | - |
| 领养日期 | 日期 | - |

### 4.2 健康记录（Health Records）

**功能描述**：记录宠物的健康相关事项

| 记录类型 | 图标 | 说明 |
|----------|------|------|
| 疫苗 | 💉 | 疫苗接种记录 |
| 驱虫 | 🐛 | 体内/体外驱虫 |
| 体检 | 🏥 | 健康检查 |
| 用药 | 💊 | 药物治疗 |
| 洗澡 | 🛁 | 洗护美容 |
| 体重 | ⚖️ | 体重追踪 |

**记录字段**：
- 记录日期
- 标题/名称
- 备注
- 下次提醒日期

### 4.3 提醒系统（Reminders）

**功能描述**：基于健康记录的下次提醒时间进行本地通知

| 功能 | 说明 |
|------|------|
| 提醒提前天数 | 可配置，默认 3 天 |
| 提醒周期 | 一次性/每日/每周/每月 |
| 提醒渠道 | 推送通知（本地） |
| 待办列表 | 首页展示即将到期和已逾期的提醒 |

### 4.4 数据导出（Data Export）

**功能描述**：导出和备份宠物数据

| 功能 | 免费版 | Pro 版 |
|------|--------|--------|
| 导出 JSON 数据 | ✅ | ✅ |
| 导出 PDF 疫苗本 | ❌ | ✅ |
| 图片分享 | ✅ | ✅ |
| 自动备份 | ❌ | ✅ |

### 4.5 云端同步（Cloud Sync）

**功能描述**：可选的云端数据同步功能

| 功能 | 说明 |
|------|------|
| 手机号登录 | 短信验证码登录 |
| 数据同步 | 上传/下载健康记录 |
| 冲突处理 | 基于时间戳的合并策略 |

---

## 5. 商业模式

### 5.1 版本对比

| 功能 | 免费版 | Pro 版 |
|------|--------|--------|
| 宠物数量 | 1 只 | 无限 |
| 记录数量 | 每只 30 条 | 无限 |
| 基础提醒 | ✅ | ✅ |
| 自定义提醒 | ❌ | ✅ |
| PDF 导出 | ❌ | ✅ |
| 自动备份 | ❌ | ✅ |
| 广告 | 无 | 无 |
| 后续新功能 | - | 免费更新 |

### 5.2 定价策略

| 平台 | 价格 |
|------|------|
| iOS | 6~12 元 |
| Android | 3~8 元 |

**付费模式**：一次性买断，不搞订阅

### 5.3 盈利点

1. **Pro 版内购**（主收入）
   - 解锁无限宠物和记录
   - 解锁 PDF 导出和自定义提醒

2. **小额捐赠**（可选）
   - 3 元/6 元赞赏
   - 不解锁功能，纯粹支持开发者

---

## 6. 数据模型

### 6.1 核心实体

#### PetProfile（宠物档案）

```dart
class PetProfile {
  final String id;              // 唯一标识
  final String name;            // 名字（必填）
  final String? avatarPath;     // 头像路径
  final String? type;           // 物种
  final String? breed;          // 品种
  final String? gender;         // 性别
  final bool? isNeutered;       // 是否绝育
  final double? weight;         // 体重
  final String? color;          // 毛色
  final String? chipNo;         // 芯片号
  final DateTime? birthday;     // 生日
  final DateTime? adoptionDate; // 领养日期
}
```

#### HealthRecord（健康记录）

```dart
class HealthRecord {
  final String id;              // 唯一标识
  final String petId;           // 关联宠物 ID
  final RecordType type;        // 记录类型
  final DateTime date;          // 记录日期
  final DateTime? nextDueDate;  // 下次提醒日期
  final String? note;           // 备注
  final String? title;          // 标题
  bool isSynced;                // 是否已同步
  DateTime updatedAt;           // 更新时间
}
```

#### UserModel（用户模型）

```dart
class UserModel {
  final String id;              // 唯一标识
  final bool isGuest;           // 是否游客
  final bool isPro;             // 是否 Pro 用户
  final String? phone;          // 手机号
  final String? token;          // 认证令牌
  final String? nickname;       // 昵称
  final String? avatarPath;     // 头像路径
}
```

#### RecordType（记录类型枚举）

```dart
enum RecordType { 
  vaccine,    // 疫苗
  deworm,     // 驱虫
  checkup,    // 体检
  medication, // 用药
  bath,       // 洗澡
  weight,     // 体重
  other       // 其他
}
```

### 6.2 实体关系

```
┌─────────────┐       ┌─────────────────┐
│   UserModel │       │   PetProfile    │
├─────────────┤       ├─────────────────┤
│ id          │       │ id              │
│ isGuest     │       │ name            │
│ isPro       │       │ type            │
│ phone       │       │ breed           │
│ token       │       │ ...             │
└─────────────┘       └────────┬────────┘
                               │ 1:N
                               ▼
                      ┌─────────────────┐
                      │  HealthRecord   │
                      ├─────────────────┤
                      │ id              │
                      │ petId (FK)      │
                      │ type            │
                      │ date            │
                      │ nextDueDate     │
                      │ ...             │
                      └─────────────────┘
```

### 6.3 存储方案

| 存储位置 | 技术 | 内容 |
|----------|------|------|
| 本地 | Hive | 用户信息、宠物档案、健康记录、设置 |
| 云端（可选） | MySQL | 用户账号、同步数据、订单 |

#### Hive Box 设计

| Box 名称 | 存储内容 |
|----------|----------|
| `user_box` | 当前用户信息 |
| `pets_box` | 宠物档案列表 |
| `records_box` | 健康记录列表 |
| `sync_box` | 同步状态、备份设置、提醒设置 |

---

## 7. API 接口

### 7.1 接口列表

| 方法 | 端点 | 说明 | 认证 |
|------|------|------|------|
| POST | `/api/v1/auth/sms/send` | 发送短信验证码 | ❌ |
| POST | `/api/v1/auth/login/phone` | 手机号登录 | ❌ |
| POST | `/api/v1/sync` | 数据同步 | ❌ |
| POST | `/api/v1/upload` | 文件上传 | ❌ |
| GET | `/api/v1/download/apk` | APK 下载 | ❌ |
| GET | `/api/v1/download/apk/meta` | APK 版本信息 | ❌ |
| POST | `/api/v1/payment/order` | 创建订单 | ✅ |
| POST | `/api/v1/payment/verify/apple` | Apple 支付验证 | ✅ |
| POST | `/api/v1/payment/notify/:provider` | 支付回调 | ❌ |

### 7.2 认证机制

- **JWT Token**：登录成功后返回 token
- **请求头**：`Authorization: Bearer <token>`
- **中间件**：`middleware.JWTAuth()` 验证 token

### 7.3 接口详情

#### 发送短信验证码

```http
POST /api/v1/auth/sms/send
Content-Type: application/json

{
  "phone": "13800138000"
}
```

#### 手机号登录

```http
POST /api/v1/auth/login/phone
Content-Type: application/json

{
  "phone": "13800138000",
  "code": "123456"
}

Response:
{
  "user": {
    "id": "user-xxx",
    "phone": "13800138000",
    "isPro": false,
    "token": "jwt_token_here"
  }
}
```

#### APK 版本信息

```http
GET /api/v1/download/apk/meta

Response:
{
  "version": "0.1.3-beta",
  "fileName": "maohaizi-riji-v0.1.3-20260304.apk",
  "downloadUrl": "http://xxx/api/v1/download/apk"
}
```

---

## 8. 开发指南

### 8.1 环境准备

```powershell
# 查看设备
flutter devices

# 拉取依赖
flutter pub get
```

### 8.2 运行项目

```powershell
# 本地模式运行
flutter run -d <device_id> --dart-define=ACCOUNT_MODE=local --no-pub

# 云端模式运行
flutter run -d <device_id> --dart-define=ACCOUNT_MODE=cloud --no-pub
```

### 8.3 构建打包

```powershell
# 本地模式 APK
flutter build apk --dart-define=ACCOUNT_MODE=local --no-tree-shake-icons

# 云端模式 APK
flutter build apk --dart-define=ACCOUNT_MODE=cloud --no-tree-shake-icons
```

### 8.4 账户模式

| 模式 | 参数 | 行为 |
|------|------|------|
| 本地模式 | `ACCOUNT_MODE=local` | 升级 Pro 不要求登录 |
| 云端模式 | `ACCOUNT_MODE=cloud` | 升级 Pro 前要求登录 |

**切换模式前建议清理数据**：

```powershell
adb -s <device_id> shell pm clear <package_name>
```

### 8.5 内测分发流程

1. **本地打包**
   ```powershell
   flutter build apk --dart-define=ACCOUNT_MODE=local --no-tree-shake-icons
   ```

2. **配置服务端**（修改 `furry_server/cmd/server/main.go`）
   - `apk.path`: APK 文件路径
   - `apk.download_name`: 下载文件名
   - `apk.version`: 版本号

3. **启动服务**
   ```powershell
   cd furry_server
   go run cmd/server/main.go
   ```

4. **验证接口**
   ```powershell
   curl http://<服务器IP>:8080/api/v1/download/apk/meta
   ```

5. **分发链接**：分享 `downloadUrl` 给内测用户

---

## 9. UI 设计

### 9.1 主题色

| 颜色 | 色值 | 用途 |
|------|------|------|
| 珊瑚橙 | `#FF8A65` | 主色调、强调色 |
| 薄荷绿 | `#81C784` | 健康相关、成功状态 |
| 婴儿蓝 | `#64B5F6` | 辅助色 |
| 暖奶油 | `#FFF8DC` | 背景色 |
| 深棕 | `#4E342E` | 文字色 |

### 9.2 设计风格

- **设计语言**：Material 3
- **圆角风格**：大圆角（24px 卡片、16px 按钮）
- **按钮形状**：Stadium 边框（胶囊形）
- **阴影**：轻柔阴影，elevation: 0
- **动画**：使用 flutter_animate 实现流畅过渡

### 9.3 页面结构

```
AppShell (底部导航容器)
├── 首页 (HomePage)
│   ├── 欢迎语
│   ├── 宠物卡片列表
│   └── 近期待办提醒
│
├── 档案 (PetProfilePage)
│   ├── 宠物列表
│   └── 添加/编辑宠物
│
├── 记录 (HealthGridPage)
│   ├── 健康卡片网格
│   └── 记录时间轴
│
└── 我的 (SettingsPage)
    ├── 账号状态
    ├── Pro 升级
    ├── 备份恢复
    └── 设置选项
```

### 9.4 国际化

| 语言 | 代码 | 状态 |
|------|------|------|
| 中文 | `zh` | ✅ 完成 |
| 英文 | `en` | ✅ 完成 |

**资源文件位置**：
- `lib/l10n/app_zh.arb`：中文资源
- `lib/l10n/app_en.arb`：英文资源
- `lib/l10n/generated/`：生成的本地化代码

---

## 10. 代码设计细节

### 10.1 前端代码架构

#### 10.1.1 入口文件 main.dart

**初始化流程**：

```dart
Future<void> main() async {
  // 1. 确保 Flutter 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 初始化本地存储
  final localStore = LocalStore();
  await localStore.init();

  // 3. 启动应用，注入 Provider
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
      ],
      child: MyApp(localStore: localStore),
    ),
  );
}
```

**关键点**：
- `LocalStore` 在 main 中初始化，通过 Provider 注入
- 使用 `ProviderScope.overrides` 覆盖默认 Provider

#### 10.1.2 AppShell 导航实现

**页面容器**：

```dart
class _AppShellState extends State<AppShell> {
  int currentIndex = 0;  // 当前选中的 tab 索引

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(localStore: widget.localStore, bottomNavigationBar: navBar),
      PetProfilePage(localStore: widget.localStore, isPro: false, bottomNavigationBar: navBar),
      HealthGridPage(localStore: widget.localStore, isPro: false, bottomNavigationBar: navBar),
      SettingsPage(isPro: false, bottomNavigationBar: navBar),
    ];

    return PopScope(
      canPop: currentIndex == 0,  // 只有在首页才能退出
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          setState(() => currentIndex = 0);  // 返回键回到首页
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: pages),  // 保持页面状态
      ),
    );
  }
}
```

**关键点**：
- 使用 `IndexedStack` 保持所有页面状态
- `PopScope` 处理返回键逻辑，非首页时返回首页

#### 10.1.3 各 Page 职责

| Page | 文件 | 职责 |
|------|------|------|
| HomePage | `home_page.dart` | 首页：宠物卡片、待办提醒、快速添加 |
| PetProfilePage | `pet_profile_page.dart` | 宠物档案：列表展示、添加/编辑宠物 |
| HealthGridPage | `health_grid_page.dart` | 健康记录：卡片网格、类型筛选 |
| HealthFormPage | `health_form_page.dart` | 记录表单：新增/编辑健康记录 |
| HealthRecordDetailPage | `health_record_detail_page.dart` | 记录详情：查看/编辑单条记录 |
| SettingsPage | `settings_page.dart` | 设置：账号、Pro 升级、备份、偏好设置 |
| LoginPage | `login_page.dart` | 登录：手机号验证码登录 |
| ProPurchasePage | `pro_purchase_page.dart` | Pro 购买：内购流程 |
| BackupRestorePage | `backup_restore_page.dart` | 备份恢复：导出/导入数据 |

### 10.2 状态管理设计

#### 10.2.1 Provider 组织结构

```
providers/
├── auth_provider.dart      # 用户认证状态
├── locale_provider.dart    # 语言设置
└── build_config_provider.dart  # 构建配置
```

#### 10.2.2 核心 Provider 设计

**localStoreProvider**：

```dart
// 声明：在 main.dart 中 override
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider not overridden');
});
```

**authProvider**：

```dart
// 用户状态管理
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localStore = ref.watch(localStoreProvider);
  return AuthNotifier(authService, localStore);
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier(this._authService, this._localStore) 
      : super(_localStore.getCurrentUser());  // 初始化时从本地加载

  Future<void> login(String phone, String code) async { ... }
  Future<void> logout() async { ... }
}
```

**dioProvider**：

```dart
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.example.com'));
});
```

#### 10.2.3 状态流转

```
┌─────────────────────────────────────────────────────────────┐
│                      Widget (Consumer)                       │
│                           │                                  │
│                    ref.watch()                               │
│                           ▼                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    Provider                              ││
│  │                         │                                ││
│  │                  ref.read()                              ││
│  │                         ▼                                ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │                  Service                             │││
│  │  │    (AuthService / LocalStore / SyncManager)         │││
│  │  └─────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### 10.3 服务层设计

#### 10.3.1 LocalStore（本地存储）

**核心实现**：

```dart
class LocalStore {
  // 数据变更通知器
  final ValueNotifier<int> dataChangedNotifier = ValueNotifier<int>(0);
  
  void notifyDataChanged() {
    dataChangedNotifier.value++;
  }

  // Box 名称常量
  static const String userBoxName = 'user_box';
  static const String recordsBoxName = 'records_box';
  static const String syncBoxName = 'sync_box';
  static const String petsBoxName = 'pets_box';

  // 初始化
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(userBoxName);
    await Hive.openBox<Map>(recordsBoxName);
    await Hive.openBox<String>(syncBoxName);
    await Hive.openBox<Map>(petsBoxName);
  }

  // 用户相关
  Future<void> saveUser(UserModel user) async { ... }
  UserModel? getCurrentUser() { ... }
  Future<void> clearUser() async { ... }

  // 宠物相关
  List<PetProfile> allPets() { ... }
  Future<void> upsertPet(PetProfile pet) async { ... }
  Future<void> deletePet(String petId) async { ... }

  // 记录相关
  List<HealthRecord> allRecords() { ... }
  Future<void> upsertRecords(List<HealthRecord> records) async { ... }
  Future<void> deleteRecord(String recordId) async { ... }

  // 设置相关
  int getReminderAdvanceDays() { ... }
  Future<void> setReminderAdvanceDays(int days) async { ... }
}
```

#### 10.3.2 AuthService（认证服务）

```dart
class AuthService {
  final Dio _dio;
  final LocalStore _localStore;

  // 进入游客模式
  Future<UserModel> enterGuestMode() async {
    final guest = UserModel(
      id: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      isGuest: true,
      isPro: false,
    );
    await _localStore.saveUser(guest);
    return guest;
  }

  // 请求短信验证码
  Future<void> requestSmsCode(String phone) async {
    await _dio.post('/api/v1/auth/sms/send', data: {'phone': phone});
  }

  // 手机号登录
  Future<UserModel> loginByPhone({required String phone, required String code}) async {
    final response = await _dio.post(
      '/api/v1/auth/login/phone',
      data: {'phone': phone, 'code': code},
    );
    final user = UserModel.fromJson(response.data['user']);
    await _localStore.saveUser(user);
    return user;
  }
}
```

#### 10.3.3 SyncManager（同步管理）

```dart
class SyncManager {
  final Dio _dio;
  final LocalStore _localStore;

  Future<void> sync() async {
    // 1. 获取本地未同步的记录
    final dirty = _localStore.allRecords().where((r) => !r.isSynced);
    
    // 2. 构建同步载荷
    final payload = SyncPayload(
      lastSyncedAt: _localStore.getLastSyncedAt(),
      dirty: dirty.toList(),
    );
    
    // 3. 发送到服务器
    final response = await _dio.post('/api/v1/sync', data: payload.toRawJson());
    
    // 4. 更新本地状态
    await _localStore.saveLastSyncedAt(DateTime.now());
  }
}
```

#### 10.3.4 AutoBackupService（自动备份）

```dart
class AutoBackupService {
  static final AutoBackupService instance = AutoBackupService._();
  AutoBackupService._();

  void onDataChanged(LocalStore localStore) {
    if (!localStore.getAutoBackupEnabled()) return;
    
    final lastBackup = localStore.getLastAutoBackupAt();
    final frequency = localStore.getAutoBackupFrequency();
    
    // 检查是否需要备份
    if (_shouldBackup(lastBackup, frequency)) {
      _performBackup(localStore);
    }
  }

  Future<void> _performBackup(LocalStore localStore) async {
    final data = await localStore.exportDataMap();
    // 保存到文件...
    await localStore.saveLastAutoBackupAt(DateTime.now());
  }
}
```

### 10.4 数据模型设计

#### 10.4.1 JSON 序列化实现

```dart
class PetProfile {
  // ... 字段定义

  // 从 JSON 反序列化
  factory PetProfile.fromJson(Map<String, dynamic> json) => PetProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarPath: json['avatarPath'] as String?,
    type: json['type'] as String?,
    breed: json['breed'] as String?,
    gender: json['gender'] as String?,
    isNeutered: json['isNeutered'] as bool?,
    weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
    color: json['color'] as String?,
    chipNo: json['chipNo'] as String?,
    birthday: json['birthday'] == null ? null : DateTime.parse(json['birthday'] as String),
    adoptionDate: json['adoptionDate'] == null ? null : DateTime.parse(json['adoptionDate'] as String),
  );

  // 序列化为 JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarPath': avatarPath,
    'type': type,
    'breed': breed,
    'gender': gender,
    'isNeutered': isNeutered,
    'weight': weight,
    'color': color,
    'chipNo': chipNo,
    'birthday': birthday?.toIso8601String(),
    'adoptionDate': adoptionDate?.toIso8601String(),
  };
}
```

#### 10.4.2 RecordType 枚举

```dart
enum RecordType { 
  vaccine,    // 疫苗
  deworm,     // 驱虫
  checkup,    // 体检
  medication, // 用药
  bath,       // 洗澡
  weight,     // 体重
  other       // 其他
}

// 使用示例
factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
  // ...
  type: RecordType.values.firstWhere((item) => item.name == json['type']),
);

Map<String, dynamic> toJson() => {
  // ...
  'type': type.name,  // 序列化为字符串
};
```

### 10.5 后端代码架构

#### 10.5.1 main.go 启动流程

```go
func main() {
    // 1. 设置默认配置
    viper.SetDefault("server.port", "8080")
    viper.SetDefault("jwt.secret", "dev-secret")
    viper.SetDefault("mysql.dsn", "root:root@tcp(127.0.0.1:3306)/furry?parseTime=true")

    // 2. 连接数据库
    db, err := gorm.Open(mysql.Open(viper.GetString("mysql.dsn")), &gorm.Config{})
    if err != nil {
        log.Fatal(err)
    }

    // 3. 自动迁移
    db.AutoMigrate(&models.User{}, &models.Pet{}, &models.HealthRecord{}, &models.Order{})

    // 4. 初始化 Handler
    authHandler := &handlers.AuthHandler{DB: db, JWTSecret: viper.GetString("jwt.secret")}
    syncHandler := &handlers.SyncHandler{DB: db}
    paymentHandler := &handlers.PaymentHandler{DB: db}
    downloadHandler := &handlers.DownloadHandler{...}

    // 5. 配置路由
    r := gin.New()
    r.Use(middleware.Logger(), cors.Default(), middleware.ErrorHandler())

    v1 := r.Group("/api/v1")
    {
        // 公开接口
        v1.POST("/auth/sms/send", authHandler.SendSMS)
        v1.POST("/auth/login/phone", authHandler.LoginPhone)
        
        // 需要认证的接口
        auth := v1.Group("/")
        auth.Use(middleware.JWTAuth(viper.GetString("jwt.secret")))
        {
            auth.POST("payment/order", paymentHandler.CreateOrder)
        }
    }

    // 6. 启动服务
    log.Fatal(r.Run(":" + viper.GetString("server.port")))
}
```

#### 10.5.2 Handler 设计模式

```go
// handlers/auth.go
type AuthHandler struct {
    DB         *gorm.DB
    JWTSecret  string
    SMSProvider services.SMSProvider
}

func (h *AuthHandler) SendSMS(c *gin.Context) {
    var req struct {
        Phone string `json:"phone" binding:"required"`
    }
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": "invalid request"})
        return
    }
    
    code := generateCode()
    h.SMSProvider.Send(req.Phone, code)
    
    c.JSON(200, gin.H{"message": "sent"})
}

func (h *AuthHandler) LoginPhone(c *gin.Context) {
    // 验证码校验 -> 创建/查询用户 -> 生成 JWT -> 返回
}
```

#### 10.5.3 Middleware 机制

```go
// middleware/middleware.go

// 日志中间件
func Logger() gin.HandlerFunc {
    return gin.Logger()
}

// 错误处理中间件
func ErrorHandler() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Next()
        if len(c.Errors) > 0 {
            c.JSON(500, gin.H{"error": c.Errors.String()})
        }
    }
}

// JWT 认证中间件
func JWTAuth(secret string) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        // 验证 token...
        c.Next()
    }
}
```

#### 10.5.4 GORM 模型定义

```go
// models/models.go
type User struct {
    gorm.Model
    Phone        string `gorm:"uniqueIndex;size:20"`
    PasswordHash string `gorm:"size:255"`
    IsPro        bool   `gorm:"default:false"`
    Pets         []Pet
}

type Pet struct {
    gorm.Model
    UserID    uint
    Name      string `gorm:"size:64;not null"`
    Breed     string `gorm:"size:64"`
    Birthday  *time.Time
    Gender    string `gorm:"size:16"`
    Color     string `gorm:"size:32"`
    ChipNo    string `gorm:"size:64"`
    AvatarURL string `gorm:"size:255"`
}

type HealthRecord struct {
    ID          string `gorm:"primaryKey;size:64"`
    UserID      uint
    PetID       uint
    Type        string `gorm:"size:32;not null"`
    Title       string `gorm:"size:128"`
    Note        string
    Date        time.Time
    NextDueDate *time.Time
    UpdatedAt   time.Time
}

type Order struct {
    ID       string `gorm:"primaryKey;size:64"`
    UserID   uint
    Amount   int64
    Provider string `gorm:"size:20"`
    Status   string `gorm:"size:20"`
}
```

### 10.6 关键代码片段

#### 10.6.1 数据变更通知机制

```dart
// LocalStore 中定义通知器
class LocalStore {
  final ValueNotifier<int> dataChangedNotifier = ValueNotifier<int>(0);
  
  void notifyDataChanged() {
    dataChangedNotifier.value++;
  }
}

// 在数据变更时调用
Future<void> upsertPet(PetProfile pet) async {
  final box = Hive.box<Map>(petsBoxName);
  await box.put(pet.id, pet.toJson());
  notifyDataChanged();  // 通知监听者
}

// 在 Widget 中监听
class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.localStore.dataChangedNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    _loadData();  // 数据变更时刷新 UI
  }

  @override
  void dispose() {
    widget.localStore.dataChangedNotifier.removeListener(_onDataChanged);
    super.dispose();
  }
}
```

#### 10.6.2 级联删除实现

```dart
Future<void> deletePet(String petId) async {
  final box = Hive.box<Map>(petsBoxName);
  await box.delete(petId);

  // 级联删除该宠物的所有健康记录
  final recBox = Hive.box<Map>(recordsBoxName);
  final keysToDelete = recBox.keys.where((key) {
    final value = recBox.get(key);
    if (value != null) {
      final record = HealthRecord.fromJson(Map<String, dynamic>.from(value));
      return record.petId == petId;  // 筛选关联记录
    }
    return false;
  }).toList();

  await recBox.deleteAll(keysToDelete);  // 批量删除
  notifyDataChanged();
}
```

#### 10.6.3 数据导入导出实现

```dart
// 导出数据
Future<Map<String, dynamic>> exportDataMap() async {
  return {
    'version': 1,
    'exported_at': DateTime.now().toIso8601String(),
    'pets': allPets().map((e) => e.toJson()).toList(),
    'records': allRecords().map((e) => e.toJson()).toList(),
    'reminder_settings': {
      'advance_days': getReminderAdvanceDays(),
      'repeat_cycle': getReminderRepeatCycle(),
      'channels': getReminderChannels().toList(),
    },
  };
}

// 导入数据
Future<void> importDataMap(Map<String, dynamic> data) async {
  // 导入宠物
  if (data.containsKey('pets') && data['pets'] is List) {
    final petBox = Hive.box<Map>(petsBoxName);
    await petBox.clear();
    for (final petJson in data['pets']) {
      final pet = PetProfile.fromJson(Map<String, dynamic>.from(petJson));
      await petBox.put(pet.id, pet.toJson());
    }
  }

  // 导入记录
  if (data.containsKey('records') && data['records'] is List) {
    final recBox = Hive.box<Map>(recordsBoxName);
    await recBox.clear();
    for (final recJson in data['records']) {
      final rec = HealthRecord.fromJson(Map<String, dynamic>.from(recJson));
      await recBox.put(rec.id, rec.toJson());
    }
  }

  // 导入设置
  // ...

  notifyDataChanged();
}
```

---

## 附录

### A. 文件索引

| 类型 | 文件路径 | 说明 |
|------|----------|------|
| 入口 | `furry_diary/lib/main.dart` | 应用入口 |
| 模型 | `furry_diary/lib/models/app_models.dart` | 数据模型 |
| 存储 | `furry_diary/lib/services/local_store.dart` | 本地存储 |
| 认证 | `furry_diary/lib/services/auth_service.dart` | 认证服务 |
| 状态 | `furry_diary/lib/providers/auth_provider.dart` | 认证状态 |
| 首页 | `furry_diary/lib/pages/home_page.dart` | 首页 |
| 后端入口 | `furry_server/cmd/server/main.go` | 服务入口 |
| 数据库迁移 | `furry_server/migrations/001_init.sql` | 初始化 SQL |

### B. 常用命令速查

```powershell
# Flutter
flutter devices                    # 查看设备
flutter pub get                    # 拉取依赖
flutter run --dart-define=ACCOUNT_MODE=local  # 本地模式运行
flutter build apk --dart-define=ACCOUNT_MODE=local  # 构建 APK

# Go
cd furry_server && go run cmd/server/main.go  # 启动后端服务

# ADB
adb shell pm clear <package>       # 清理应用数据
```

### C. 相关文档

- [产品定位文档](../openspec/Project.md)
- [功能规格说明](../openspec/specs/)
- [项目规则](../.trae/rules/project_rules.md)

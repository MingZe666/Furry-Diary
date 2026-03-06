# 生理期功能需求文档

> 版本: v1.0  
> 日期: 2026-03-06  
> 状态: 待评审

---

## 1. 功能概述

### 1.1 功能定位

生理期追踪功能是针对未绝育母宠(母狗、母猫)的健康管理模块,帮助宠物主人记录和预测宠物的发情周期,提供科学的生理健康管理支持。

### 1.2 目标用户

- 养未绝育母狗的宠物主人
- 养未绝育母猫的宠物主人
- 需要追踪宠物生殖健康的用户

### 1.3 核心价值

- **科学追踪**: 记录发情周期的各个阶段,科学预测下次发情时间
- **健康监测**: 记录生理期症状和行为变化,及时发现异常
- **贴心提醒**: 在下次生理期临近时提前通知,做好准备工作
- **数据可视化**: 通过日历和统计图表直观展示周期规律

---

## 2. 功能需求

### 2.1 核心功能

#### 2.1.1 生理期记录

**功能描述**: 记录单次生理期的详细信息

**记录字段**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| 宠物ID | String | ✅ | 关联的宠物档案 |
| 开始日期 | DateTime | ✅ | 生理期开始日期 |
| 结束日期 | DateTime | ❌ | 生理期结束日期(可后续补充) |
| 持续天数 | int | ❌ | 自动计算(结束日期-开始日期+1) |
| 周期阶段 | Enum | ❌ | 前情期/情期/后情期/休情期 |
| 分泌物颜色 | String | ❌ | 如:粉红/鲜红/暗红/淡黄 |
| 分泌物量 | Enum | ❌ | 少量/中等/大量 |
| 外阴肿胀 | Enum | ❌ | 无/轻度/中度/重度 |
| 行为变化 | List<String> | ❌ | 多选:烦躁/粘人/食欲下降/频繁排尿等 |
| 症状备注 | String | ❌ | 其他症状描述 |
| 是否异常 | bool | ❌ | 标记异常周期 |
| 创建时间 | DateTime | ✅ | 记录创建时间 |
| 更新时间 | DateTime | ✅ | 最后更新时间 |

**业务规则**:

1. 只有性别为"母"且未绝育的宠物才能使用此功能
2. 开始日期必填,结束日期可以在生理期结束后补充
3. 持续天数自动计算,无需用户输入
4. 支持编辑和删除历史记录
5. 免费用户最多记录10条生理期记录,Pro用户无限制

#### 2.1.2 周期预测

**功能描述**: 根据历史记录预测下次生理期时间

**预测算法**:

1. **首次记录处理**(记录=0条):
   - 引导用户选择：
     - 选项A：这是宠物第一次生理期 → 使用默认周期预测
     - 选项B：宠物之前有过生理期 → 引导补充历史记录（最多补充最近3次）
   - 默认周期基于物种和品种：
     - 小型犬（如吉娃娃、泰迪）：180天（6个月）
     - 中型犬（如柯基、边牧）：210天（7个月）
     - 大型犬（如金毛、拉布拉多）：300天（10个月）
     - 猫咪：21天（2-3周）
   - 默认持续时间（单次发情持续天数）：
     - 小型犬：18天（2-3周）
     - 中型犬：18天（2-3周）
     - 大型犬：18天（2-3周）
     - 猫咪：8天（7-10天）
   - 明确提示：基于平均周期预测，准确度较低
   
2. **基础算法**(记录=1条): 
   - 使用默认周期预测
   - 提示：积累更多数据后预测会更准确
   
3. **加权算法**(记录≥2条时):
   - 计算历史周期的平均间隔天数
   - 最近3次周期权重更高
   - 权重分配: 最近一次40%, 第二次35%, 第三次25%
   - **优化因素**:
     - 年龄因素: 年轻宠物(1-3岁)周期可能更频繁，权重调整+5%
     - 季节因素: 猫咪在春季(3-5月)更易发情，权重调整+10%
     - 移动平均: 使用3次记录的移动平均值，平滑异常值
   - 预测公式: 加权平均周期 = Σ(周期长度 × 权重 × 调整系数)

4. **异常处理**:
   - **异常检测规则**:
     - 持续时间异常: 超过30天或少于3天
     - 间隔时间异常: 小于45天或超过365天
     - 分泌物颜色异常: 绿色、黑色、脓性分泌物
     - 行为异常: 过度焦虑、拒食、持续舔舐导致红肿
   - 异常周期不参与预测计算
   - 提示用户咨询兽医
   - 在记录详情页标记异常并显示异常原因

**预测展示**:

| 展示项 | 说明 |
|--------|------|
| 预测开始日期 | 下次生理期预计开始时间 |
| 预测结束日期 | 开始日期 + 平均持续天数 |
| 距离天数 | 距离预测开始日期还有多少天 |
| 置信度 | 根据历史记录数量显示预测准确度 |
| 预测依据 | 显示预测基于默认值/历史记录 |

**置信度规则**:

- 首次记录(默认值): 置信度低,提示"基于平均周期预测，准确度较低"
- 记录1条: 置信度低,提示"数据不足，建议继续记录"
- 记录2-5条: 置信度中等
- 记录6条以上: 置信度高

**首次记录引导流程**:

```
用户第一次点击"记录生理期"
   ↓
弹出引导对话框：
┌─────────────────────────────────┐
│  🌸 记录生理期                   │
├─────────────────────────────────┤
│  这是XX第一次生理期吗？          │
│                                 │
│  ○ 是的，这是第一次              │
│    （将基于平均周期预测）        │
│                                 │
│  ○ 不是，之前有过生理期          │
│    （可补充历史记录）            │
│                                 │
│  [取消]  [继续]                 │
└─────────────────────────────────┘
   ↓
选择"是的，这是第一次"
   → 进入正常记录表单
   → 保存后显示预测（基于默认周期）
   
选择"不是，之前有过生理期"
   → 引导补充历史记录
   → 最多补充最近3次
   → 基于历史记录预测
```

#### 2.1.3 症状和行为记录

**功能描述**: 记录生理期期间的症状和行为变化

**预设选项**:

**行为变化**(多选):
- 烦躁不安
- 情绪低落
- 更加粘人
- 食欲下降
- 频繁排尿
- 舔舐外阴
- 寻找配偶
- 攻击性增强
- 活动减少
- 其他

**身体症状**(多选):
- 外阴肿胀
- 乳房胀大
- 体温升高
- 饮水量增加
- 其他

**分泌物情况**:
- 颜色: 粉红/鲜红/暗红/淡黄/透明
- 量: 少量/中等/大量

#### 2.1.4 提醒功能

**功能描述**: 在生理期临近时发送提醒通知

**提醒规则**:

| 提醒类型 | 触发条件 | 提醒内容 |
|----------|----------|----------|
| 临近提醒 | 距离预测开始日期7天 | "XX的生理期预计将在X天后开始,请做好准备" |
| 开始提醒 | 预测开始日期当天 | "XX的生理期预计今天开始,请注意观察" |
| 结束提醒 | 预测结束日期+2天 | "XX的生理期应该已经结束,请确认并记录结束日期" |
| 异常提醒 | 超过预测日期7天未开始 | "XX的生理期已超期,请观察或咨询兽医" |

**提醒设置**:

- 提前提醒天数: 可配置(默认7天)
- 提醒时间: 可配置(默认上午9:00)
- 提醒开关: 可单独关闭某类提醒

#### 2.1.5 数据可视化

**功能描述**: 通过日历和图表展示生理期数据

**日历视图**:

- 在日历上标记生理期日期范围
- 使用不同颜色区分不同阶段:
  - 前情期: 浅粉色
  - 情期: 粉红色
  - 后情期: 淡红色
  - 预测日期: 虚线标记
- 点击日期可查看/编辑当天的记录

**统计图表**:

1. **周期长度趋势图**:
   - X轴: 记录序号
   - Y轴: 周期长度(天)
   - 显示平均线

2. **持续天数分布图**:
   - 柱状图展示持续天数分布
   - 显示平均持续天数

3. **症状统计**:
   - 饼图展示常见症状占比
   - 帮助用户了解宠物规律

---

## 3. 数据模型设计

### 3.1 EstrusRecord(生理期记录)

**Flutter 客户端模型**:

```dart
class EstrusRecord {
  final String id;                    // 唯一标识
  final String petId;                 // 关联宠物ID
  final DateTime startDate;           // 开始日期
  final DateTime? endDate;            // 结束日期
  final int? durationDays;            // 持续天数(自动计算)
  final EstrusPhase? phase;           // 周期阶段
  final String? dischargeColor;       // 分泌物颜色
  final DischargeAmount? dischargeAmount; // 分泌物量
  final SwellingLevel? vulvaSwelling; // 外阴肿胀程度
  final List<String> behaviorChanges; // 行为变化
  final List<String> symptoms;        // 身体症状
  final String? note;                 // 备注
  final bool isAbnormal;              // 是否异常
  final List<String>? abnormalReasons; // 异常原因
  bool isSynced;                      // 是否已同步
  DateTime createdAt;                 // 创建时间
  DateTime updatedAt;                 // 更新时间
}
```

**枚举定义**:

```dart
enum EstrusPhase {
  proestrus,    // 前情期
  estrus,       // 情期
  diestrus,     // 后情期
  anestrus,     // 休情期
}

enum DischargeAmount {
  light,        // 少量
  moderate,     // 中等
  heavy,        // 大量
}

enum SwellingLevel {
  none,         // 无
  mild,         // 轻度
  moderate,     // 中度
  severe,       // 重度
}
```

**服务端模型(Go)**:

```go
type EstrusRecord struct {
    ID              string     `json:"id" gorm:"primaryKey;size:64"`
    UserID          uint       `json:"user_id" gorm:"index;not null"`
    PetID           uint       `json:"pet_id" gorm:"index;not null"`
    StartDate       time.Time  `json:"start_date" gorm:"not null"`
    EndDate         *time.Time `json:"end_date"`
    DurationDays    *int       `json:"duration_days"`
    Phase           string     `json:"phase" gorm:"size:32"`
    DischargeColor  string     `json:"discharge_color" gorm:"size:32"`
    DischargeAmount string     `json:"discharge_amount" gorm:"size:32"`
    VulvaSwelling   string     `json:"vulva_swelling" gorm:"size:32"`
    BehaviorChanges string     `json:"behavior_changes" gorm:"type:text"` // JSON数组
    Symptoms        string     `json:"symptoms" gorm:"type:text"`          // JSON数组
    Note            string     `json:"note"`
    IsAbnormal      bool       `json:"is_abnormal" gorm:"default:false"`
    AbnormalReasons string     `json:"abnormal_reasons" gorm:"type:text"` // JSON数组
    CreatedAt       time.Time  `json:"created_at"`
    UpdatedAt       time.Time  `json:"updated_at"`
}
```

### 3.2 数据库表结构

**MySQL 表设计**:

```sql
CREATE TABLE IF NOT EXISTS estrus_records (
  id VARCHAR(64) PRIMARY KEY,
  user_id BIGINT NOT NULL,
  pet_id BIGINT NOT NULL,
  start_date DATETIME NOT NULL,
  end_date DATETIME NULL,
  duration_days INT NULL,
  phase VARCHAR(32) NULL,
  discharge_color VARCHAR(32) NULL,
  discharge_amount VARCHAR(32) NULL,
  vulva_swelling VARCHAR(32) NULL,
  behavior_changes TEXT NULL,
  symptoms TEXT NULL,
  note TEXT NULL,
  is_abnormal BOOLEAN DEFAULT FALSE,
  abnormal_reasons TEXT NULL, -- JSON数组
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_er_user_id (user_id),
  INDEX idx_er_pet_id (pet_id),
  INDEX idx_er_start_date (start_date)
);
```

### 3.3 Hive 存储设计

**新增 Box**:

```dart
static const String estrusBoxName = 'estrus_box';
```

**存储内容**:
- 生理期记录列表
- 周期预测缓存
- 提醒设置

---

## 4. UI/UX 设计

### 4.1 页面结构

```
生理期模块
├── 生理期主页 (EstrusHomePage)
│   ├── 当前状态卡片
│   │   ├── 宠物信息
│   │   ├── 当前周期阶段
│   │   └── 预测下次生理期
│   ├── 快速记录按钮
│   └── 历史记录入口
│
├── 日历视图页 (EstrusCalendarPage)
│   ├── 月历展示
│   ├── 生理期标记
│   └── 预测日期标记
│
├── 记录表单页 (EstrusFormPage)
│   ├── 基本信息(开始/结束日期)
│   ├── 症状选择
│   ├── 行为变化选择
│   └── 备注输入
│
├── 记录详情页 (EstrusDetailPage)
│   ├── 基本信息展示
│   ├── 症状列表
│   ├── 行为变化列表
│   ├── 异常标记和原因
│   └── 编辑/删除操作
│
├── 统计页面 (EstrusStatsPage)
│   ├── 周期长度趋势图
│   ├── 持续天数分布
│   └── 症状统计
│
└── 知识页面 (EstrusKnowledgePage)
    ├── 生理期基础知识
    ├── 各阶段症状说明
    ├── 护理建议
    ├── 常见问题解答
    └── 何时需要咨询兽医
```

### 4.2 入口设计

**方案一: 独立入口**(推荐)

在健康记录网格页面新增"生理期"卡片:
- 图标: 🌸(樱花)
- 名称: 生理期
- 仅对符合条件的宠物显示(母、未绝育)
- 点击进入生理期主页

**方案二: 集成到宠物档案**

在宠物档案详情页新增"生理期追踪"入口:
- 仅对符合条件的宠物显示
- 点击进入生理期主页

### 4.3 交互设计

#### 4.3.1 首次记录引导流程

```
用户第一次点击"记录生理期"按钮
   ↓
检测该宠物是否有历史记录
   ↓
无历史记录 → 弹出引导对话框
   ↓
┌─────────────────────────────────────┐
│  🌸 记录生理期                       │
├─────────────────────────────────────┤
│  这是XX第一次生理期吗？              │
│                                     │
│  ○ 是的，这是第一次                  │
│    将基于平均周期预测下次生理期      │
│                                     │
│  ○ 不是，之前有过生理期              │
│    可补充历史记录以提高预测准确度    │
│                                     │
│  [取消]  [继续]                     │
└─────────────────────────────────────┘
   ↓
选择"是的，这是第一次"
   → 进入新手引导页面
   ┌─────────────────────────────────────┐
   │  📚 生理期知识小课堂                  │
   ├─────────────────────────────────────┤
   │  🔍 如何识别生理期？                 │
   │  • 外阴肿胀发红                     │
   │  • 血性分泌物                       │
   │  • 行为变化（如频繁舔舐）            │
   │                                     │
   │  💡 小贴士：                        │
   │  • 记录开始日期和结束日期           │
   │  • 注意观察分泌物颜色和量           │
   │  • 保持清洁，避免感染               │
   │                                     │
   │  [跳过]  [开始记录]                 │
   └─────────────────────────────────────┘
   → 进入正常记录表单
   → 保存后显示预测信息
   ┌─────────────────────────────────┐
   │  ✅ 已记录生理期                 │
   │                                 │
   │  📅 预测下次生理期：2026年9月6日  │
   │  ⚠️ 基于平均周期预测             │
   │     （准确度较低）               │
   │  💡 继续记录可提高预测准确度      │
   └─────────────────────────────────┘
   
选择"不是，之前有过生理期"
   → 进入历史记录补充页面
   ┌─────────────────────────────────────┐
   │  📝 补充历史记录                     │
   ├─────────────────────────────────────┤
   │  记录 1                             │
   │  开始日期：[选择日期]               │
   │  结束日期：[选择日期] (可选)        │
   │  [+ 添加更多记录]                   │
   │                                     │
   │  记录 2                             │
   │  开始日期：[选择日期]               │
   │  结束日期：[选择日期] (可选)        │
   │  [删除]                             │
   │                                     │
   │  💡 最多可补充3条历史记录            │
   │                                     │
   │  [跳过]  [保存并继续]               │
   └─────────────────────────────────────┘
   → 保存历史记录
   → 进入正常记录表单
   → 基于历史记录预测
```

#### 4.3.2 快速记录流程(非首次)

```
1. 点击"记录生理期"按钮
   ↓
2. 选择宠物(如果有多只符合条件的宠物)
   ↓
3. 选择开始日期(默认今天)
   ↓
4. 可选: 选择症状和行为
   ↓
5. 保存记录
   ↓
6. 显示预测信息
```

#### 4.3.3 编辑结束日期

```
1. 在记录详情页点击"编辑"
   ↓
2. 选择结束日期
   ↓
3. 自动计算持续天数
   ↓
4. 保存更新
   ↓
5. 重新计算预测
```

### 4.4 视觉设计

**主题色**:
- 主色: 粉红色系 `#F48FB1` (温柔粉)
- 辅助色: 浅粉色 `#FCE4EC`
- 强调色: 玫红色 `#EC407A`

**图标设计**:
- 主图标: 🌸 樱花(象征女性生理周期)
- 记录图标: 📅 日历
- 统计图标: 📊 图表

**状态标签**:
- 进行中: 粉红色背景
- 已结束: 灰色背景
- 预测中: 虚线边框

---

## 5. 技术实现要点

### 5.1 前端实现

#### 5.1.1 新增文件

```
lib/
├── models/
│   └── estrus_models.dart          # 生理期数据模型
├── pages/
│   ├── estrus_home_page.dart       # 生理期主页
│   ├── estrus_calendar_page.dart   # 日历视图
│   ├── estrus_form_page.dart       # 记录表单
│   ├── estrus_detail_page.dart     # 记录详情
│   ├── estrus_stats_page.dart      # 统计页面
│   └── estrus_history_input_page.dart # 历史记录补充页面
├── services/
│   └── estrus_service.dart         # 生理期业务逻辑
└── widgets/
    ├── estrus_card.dart            # 生理期卡片组件
    ├── estrus_calendar.dart        # 日历组件
    ├── symptom_selector.dart       # 症状选择器
    └── first_record_dialog.dart    # 首次记录引导对话框
```

#### 5.1.2 LocalStore 扩展

```dart
class LocalStore {
  static const String estrusBoxName = 'estrus_box';
  
  // 初始化
  Future<void> init() async {
    // ... 现有代码
    await Hive.openBox<Map>(estrusBoxName);
  }
  
  // 生理期记录相关
  List<EstrusRecord> allEstrusRecords() { ... }
  List<EstrusRecord> estrusRecordsByPet(String petId) { ... }
  Future<void> upsertEstrusRecord(EstrusRecord record) async { ... }
  Future<void> deleteEstrusRecord(String recordId) async { ... }
  
  // 周期预测
  EstrusPrediction? predictNextEstrus(String petId) { ... }
}
```

#### 5.1.3 周期预测算法

```dart
class EstrusService {
  /// 默认周期参考值（发情间隔）
  static const Map<String, int> defaultCycles = {
    'dog_small': 180,    // 小型犬：6个月
    'dog_medium': 210,   // 中型犬：7个月
    'dog_large': 300,    // 大型犬：10个月
    'cat': 21,           // 猫咪：2-3周
  };
  
  /// 默认持续时间参考值（单次发情持续天数）
  static const Map<String, int> defaultDuration = {
    'dog_small': 18,     // 小型犬：2-3周
    'dog_medium': 18,    // 中型犬：2-3周
    'dog_large': 18,     // 大型犬：2-3周
    'cat': 8,            // 猫咪：7-10天
  };
  
  /// 小型犬品种列表
  static const List<String> smallDogBreeds = [
    '吉娃娃', '泰迪', '博美', '约克夏', '马尔济斯', '比熊', 
    '贵宾', '雪纳瑞', '西施', '巴哥', '柯基',
  ];
  
  /// 大型犬品种列表
  static const List<String> largeDogBreeds = [
    '金毛', '拉布拉多', '德牧', '哈士奇', '阿拉斯加', 
    '萨摩耶', '边境牧羊犬', '罗威纳', '杜宾',
  ];
  
  /// 获取默认周期
  int getDefaultCycle(String species, String? breed) {
    if (species == '猫') return defaultCycles['cat']!;
    
    // 根据品种判断体型
    if (breed != null) {
      if (smallDogBreeds.any((b) => breed.contains(b))) {
        return defaultCycles['dog_small']!;
      }
      if (largeDogBreeds.any((b) => breed.contains(b))) {
        return defaultCycles['dog_large']!;
      }
    }
    
    return defaultCycles['dog_medium']!;
  }
  
  /// 获取默认持续时间
  int getDefaultDuration(String species, String? breed) {
    if (species == '猫') return defaultDuration['cat']!;
    
    // 根据品种判断体型
    if (breed != null) {
      if (smallDogBreeds.any((b) => breed.contains(b))) {
        return defaultDuration['dog_small']!;
      }
      if (largeDogBreeds.any((b) => breed.contains(b))) {
        return defaultDuration['dog_large']!;
      }
    }
    
    return defaultDuration['dog_medium']!;
  }
  
  /// 计算周期长度(两次生理期开始日期的间隔)
  List<int> calculateCycleLengths(List<EstrusRecord> records) {
    final sorted = records..sort((a, b) => a.startDate.compareTo(b.startDate));
    final lengths = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      final days = sorted[i].startDate.difference(sorted[i-1].startDate).inDays;
      lengths.add(days);
    }
    return lengths;
  }
  
  /// 预测下次生理期
  EstrusPrediction predictNextEstrus(
    List<EstrusRecord> records, {
    required String species,
    String? breed,
  }) {
    // 首次记录：使用默认周期
    if (records.isEmpty) {
      final defaultCycle = getDefaultCycle(species, breed);
      final now = DateTime.now();
      return EstrusPrediction(
        predictedDate: now.add(Duration(days: defaultCycle)),
        averageCycle: defaultCycle,
        confidence: PredictionConfidence.low,
        predictionBasis: PredictionBasis.defaultValue,
        message: '基于平均周期预测，准确度较低',
      );
    }
    
    final cycleLengths = calculateCycleLengths(records);
    
    // 只有一条记录：使用默认周期
    if (cycleLengths.isEmpty) {
      final defaultCycle = getDefaultCycle(species, breed);
      return EstrusPrediction(
        predictedDate: records.last.startDate.add(Duration(days: defaultCycle)),
        averageCycle: defaultCycle,
        confidence: PredictionConfidence.low,
        predictionBasis: PredictionBasis.defaultValue,
        message: '数据不足，建议继续记录',
      );
    }
    
    // 加权平均(最近3次)
    double weightedSum = 0;
    double totalWeight = 0;
    
    final recentCycles = cycleLengths.reversed.take(3).toList();
    final weights = [0.4, 0.35, 0.25];
    
    for (int i = 0; i < recentCycles.length; i++) {
      weightedSum += recentCycles[i] * weights[i];
      totalWeight += weights[i];
    }
    
    final avgCycle = (weightedSum / totalWeight).round();
    final predictedDate = records.last.startDate.add(Duration(days: avgCycle));
    
    // 计算置信度
    final confidence = _calculateConfidence(records.length);
    
    return EstrusPrediction(
      predictedDate: predictedDate,
      averageCycle: avgCycle,
      confidence: confidence,
      predictionBasis: PredictionBasis.historicalData,
      message: confidence == PredictionConfidence.high 
        ? '预测准确度较高' 
        : confidence == PredictionConfidence.medium 
          ? '预测准确度中等'
          : '数据不足，建议继续记录',
    );
  }
  
  PredictionConfidence _calculateConfidence(int recordCount) {
    if (recordCount >= 6) return PredictionConfidence.high;
    if (recordCount >= 2) return PredictionConfidence.medium;
    return PredictionConfidence.low;
  }
}

/// 预测依据枚举
enum PredictionBasis {
  defaultValue,     // 默认值
  historicalData,   // 历史数据
}

/// 预测置信度枚举
enum PredictionConfidence {
  low,
  medium,
  high,
}

/// 预测结果模型
class EstrusPrediction {
  final DateTime predictedDate;
  final int averageCycle;
  final PredictionConfidence confidence;
  final PredictionBasis predictionBasis;
  final String message;
  
  EstrusPrediction({
    required this.predictedDate,
    required this.averageCycle,
    required this.confidence,
    required this.predictionBasis,
    required this.message,
  });
}
```

### 5.2 后端实现

#### 5.2.1 新增文件

```
furry_server/
├── internal/
│   ├── models/
│   │   └── estrus.go               # 生理期模型
│   └── handlers/
│       └── estrus_handler.go       # 生理期接口处理器
└── migrations/
    └── 002_estrus_records.sql      # 数据库迁移脚本
```

#### 5.2.2 API 接口设计

| 方法 | 端点 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/v1/estrus/records` | 获取生理期记录列表 | ✅ |
| POST | `/api/v1/estrus/records` | 创建生理期记录 | ✅ |
| PUT | `/api/v1/estrus/records/:id` | 更新生理期记录 | ✅ |
| DELETE | `/api/v1/estrus/records/:id` | 删除生理期记录 | ✅ |
| GET | `/api/v1/estrus/prediction/:pet_id` | 获取周期预测 | ✅ |

### 5.3 数据同步

**同步策略**:
- 生理期记录纳入现有的同步机制
- 在 `SyncPayload` 中新增 `estrus_records` 字段
- 使用相同的冲突处理逻辑(基于时间戳)

---

## 6. 商业模式

### 6.1 功能限制

| 功能 | 免费版 | Pro 版 |
|------|--------|--------|
| 记录数量 | 10 条 | 无限 |
| 基础记录 | ✅ | ✅ |
| 周期预测 | ✅ | ✅ |
| 日历视图 | ✅ | ✅ |
| 统计图表 | ❌ | ✅ |
| 高级提醒 | ❌ | ✅ |
| 数据导出 | ❌ | ✅ |
| 繁殖计划 | ❌ | ✅ |
| 多宠物管理 | 1只 | 最多5只 |

### 6.2 升级引导

- 当免费用户记录达到10条时,提示升级Pro
- 在统计页面显示"Pro专属功能"标识
- 在高级提醒设置中提示升级

---

## 7. 后续可做功能

### 7.1 功能完整性
- [ ] **繁殖计划功能**：增加繁殖相关的记录和提醒，如最佳配种时间、孕期追踪等
- [ ] **数据导入/导出**：支持Excel/CSV格式的数据导入和导出，方便用户迁移数据

### 7.2 技术实现
- [ ] **AI预测模型**：基于更多历史数据和外部因素（如环境温度、饮食），使用机器学习模型提高预测准确度
- [ ] **多平台同步**：增加Web端管理界面，实现多设备数据实时同步

### 7.3 用户体验
- [ ] **社区功能**：添加用户社区，分享经验和交流护理心得
- [ ] **个性化推荐**：根据宠物品种和历史数据，提供个性化的护理建议

---

## 8. 国际化

### 8.1 新增文案

**中文**:

```json
{
  "estrus": "生理期",
  "estrus_record": "生理期记录",
  "estrus_calendar": "生理期日历",
  "estrus_prediction": "周期预测",
  "start_date": "开始日期",
  "end_date": "结束日期",
  "duration_days": "持续天数",
  "next_prediction": "预计下次生理期",
  "days_until_next": "距离下次还有 {days} 天",
  "behavior_changes": "行为变化",
  "symptoms": "症状",
  "discharge_color": "分泌物颜色",
  "discharge_amount": "分泌物量",
  "vulva_swelling": "外阴肿胀",
  "proestrus": "前情期",
  "estrus": "情期",
  "diestrus": "后情期",
  "anestrus": "休情期",
  "prediction_confidence_low": "数据不足,预测准确度较低",
  "prediction_confidence_medium": "预测准确度中等",
  "prediction_confidence_high": "预测准确度较高",
  "estrus_reminder": "生理期提醒",
  "estrus_coming_soon": "{petName}的生理期预计将在{days}天后开始",
  "estrus_started": "{petName}的生理期预计今天开始",
  "estrus_should_end": "{petName}的生理期应该已经结束",
  "estrus_overdue": "{petName}的生理期已超期",
  "first_record_title": "记录生理期",
  "first_record_question": "这是{petName}第一次生理期吗？",
  "first_time_option": "是的，这是第一次",
  "first_time_hint": "将基于平均周期预测下次生理期",
  "not_first_time_option": "不是，之前有过生理期",
  "not_first_time_hint": "可补充历史记录以提高预测准确度",
  "history_input_title": "补充历史记录",
  "history_input_hint": "最多可补充3条历史记录",
  "add_more_records": "添加更多记录",
  "skip_and_continue": "跳过",
  "save_and_continue": "保存并继续",
  "prediction_basis_default": "基于平均周期预测",
  "prediction_basis_historical": "基于历史记录预测",
  "prediction_accuracy_low": "准确度较低",
  "continue_recording_hint": "继续记录可提高预测准确度",
  "record_saved": "已记录生理期",
  "knowledge_title": "生理期知识小课堂",
  "how_to_identify": "如何识别生理期？",
  "swelling_redness": "外阴肿胀发红",
  "bloody_discharge": "血性分泌物",
  "behavior_changes": "行为变化（如频繁舔舐）",
  "tips_title": "小贴士：",
  "record_dates": "记录开始日期和结束日期",
  "observe_discharge": "注意观察分泌物颜色和量",
  "keep_clean": "保持清洁，避免感染",
  "skip": "跳过",
  "start_recording": "开始记录",
  "abnormal_title": "异常标记",
  "abnormal_reasons": "异常原因",
  "pro_feature": "Pro专属功能",
  "cloud_backup": "云备份与恢复"
}
```

**英文**:

```json
{
  "estrus": "Estrus",
  "estrus_record": "Estrus Record",
  "estrus_calendar": "Estrus Calendar",
  "estrus_prediction": "Cycle Prediction",
  "start_date": "Start Date",
  "end_date": "End Date",
  "duration_days": "Duration",
  "next_prediction": "Next Predicted Estrus",
  "days_until_next": "{days} days until next",
  "behavior_changes": "Behavior Changes",
  "symptoms": "Symptoms",
  "discharge_color": "Discharge Color",
  "discharge_amount": "Discharge Amount",
  "vulva_swelling": "Vulva Swelling",
  "proestrus": "Proestrus",
  "estrus": "Estrus",
  "diestrus": "Diestrus",
  "anestrus": "Anestrus",
  "prediction_confidence_low": "Insufficient data, low prediction accuracy",
  "prediction_confidence_medium": "Medium prediction accuracy",
  "prediction_confidence_high": "High prediction accuracy",
  "estrus_reminder": "Estrus Reminder",
  "estrus_coming_soon": "{petName}'s estrus is expected in {days} days",
  "estrus_started": "{petName}'s estrus is expected to start today",
  "estrus_should_end": "{petName}'s estrus should have ended",
  "estrus_overdue": "{petName}'s estrus is overdue",
  "first_record_title": "Record Estrus",
  "first_record_question": "Is this {petName}'s first estrus?",
  "first_time_option": "Yes, this is the first time",
  "first_time_hint": "Will predict based on average cycle",
  "not_first_time_option": "No, had estrus before",
  "not_first_time_hint": "Can add historical records to improve accuracy",
  "history_input_title": "Add Historical Records",
  "history_input_hint": "Can add up to 3 historical records",
  "add_more_records": "Add more records",
  "skip_and_continue": "Skip",
  "save_and_continue": "Save and Continue",
  "prediction_basis_default": "Based on average cycle",
  "prediction_basis_historical": "Based on historical records",
  "prediction_accuracy_low": "Low accuracy",
  "continue_recording_hint": "Continue recording to improve prediction accuracy",
  "record_saved": "Estrus recorded",
  "knowledge_title": "Estrus Knowledge Class",
  "how_to_identify": "How to identify estrus?",
  "swelling_redness": "Vulva swelling and redness",
  "bloody_discharge": "Bloody discharge",
  "behavior_changes": "Behavior changes (e.g., frequent licking)",
  "tips_title": "Tips:",
  "record_dates": "Record start and end dates",
  "observe_discharge": "Observe discharge color and amount",
  "keep_clean": "Keep clean to avoid infection",
  "skip": "Skip",
  "start_recording": "Start Recording",
  "abnormal_title": "Abnormal Mark",
  "abnormal_reasons": "Abnormal Reasons",
  "pro_feature": "Pro Exclusive Feature",
  "cloud_backup": "Cloud Backup & Restore"
}
```

---

## 8. 测试要点

### 8.1 功能测试

- [ ] 创建生理期记录
- [ ] 编辑生理期记录
- [ ] 删除生理期记录
- [ ] 周期预测准确性
- [ ] 提醒通知触发
- [ ] 日历视图展示
- [ ] 统计图表生成
- [ ] 数据同步
- [ ] 首次记录引导流程
- [ ] 历史记录补充功能
- [ ] 默认周期预测(首次记录)
- [ ] 基于品种的默认周期选择

### 8.2 边界测试

- [ ] 只有符合条件的宠物才能使用
- [ ] 免费用户记录数量限制
- [ ] 单条记录的编辑和删除
- [ ] 异常周期的处理
- [ ] 预测日期已过的情况
- [ ] 首次记录选择"是第一次"的流程
- [ ] 首次记录选择"不是第一次"的流程
- [ ] 历史记录补充最多3条的限制
- [ ] 不同物种(狗/猫)的默认周期差异
- [ ] 不同体型狗狗的默认周期差异

### 8.3 性能测试

- [ ] 大量记录的加载性能
- [ ] 日历渲染性能
- [ ] 统计图表生成性能

---

## 9. 风险评估

### 9.1 技术风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 预测算法不准确 | 用户信任度降低 | 提供置信度提示,引导用户积累数据 |
| 数据丢失 | 用户数据损失 | 完善备份机制,支持数据导出 |
| 性能问题 | 用户体验差 | 优化查询和渲染,使用缓存 |

### 9.2 业务风险

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 用户不理解功能 | 使用率低 | 提供引导说明,简化操作流程 |
| 隐私顾虑 | 用户拒绝使用 | 强调本地存储,数据不外泄 |

---

## 10. 后续迭代方向

### 10.1 短期迭代(v1.1)

- 支持绝育手术记录(自动关闭生理期功能)
- 新增生理期照片记录
- 优化预测算法

### 10.2 中期迭代(v1.2)

- 支持繁殖计划管理
- 新增配种记录
- 怀孕周期追踪

### 10.3 长期迭代(v2.0)

- AI辅助诊断异常周期
- 与宠物医院数据互通
- 社区经验分享

---

## 附录

### A. 参考资料

- 狗狗生理期基础知识: https://www.kupet.cn/read-1748271236a1421512.html
- 宠物健康管理最佳实践
- 女性生理期追踪App设计参考

### B. 术语表

| 术语 | 英文 | 说明 |
|------|------|------|
| 发情期 | Estrus | 雌性动物的排卵期 |
| 前情期 | Proestrus | 发情前期 |
| 后情期 | Diestrus | 发情后期 |
| 休情期 | Anestrus | 非发情期 |
| 动情周期 | Estrus Cycle | 完整的生殖周期 |

### C. 默认周期参考数据

| 宠物类型 | 发情间隔（默认周期） | 单次发情持续时间 |
|---------|---------------------|-----------------|
| 小型犬（泰迪/吉娃娃） | 6个月（180天） | 2-3周（14-21天） |
| 中型犬（柯基/边牧） | 6-8个月（180-240天） | 2-3周（14-21天） |
| 大型犬（金毛/拉布拉多） | 8-12个月（240-360天） | 2-3周（14-21天） |
| 猫咪（通用） | 2-3周（14-21天） | 7-10天（未受孕则快速进入下一轮） |

**注**：以上数据为平均值，实际周期因个体差异、年龄、健康状况等因素可能有所不同。

### D. 相关文档

- [项目理解文档](../.trae/specs/document-project-understanding/PROJECT_UNDERSTANDING.md)
- [项目开发规则](../.trae/rules/project_rules.md)

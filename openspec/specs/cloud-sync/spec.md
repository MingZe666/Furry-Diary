## 新增需求

### 需求：数据同步 (Data Synchronization)
系统必须通过自定义 RESTful API 在所有已登录设备之间同步数据。

#### 场景：自动同步机制
- **当 (WHEN)** 设备连接互联网并有本地未同步更改（`is_synced = false`）
- **那么 (THEN)** 后台服务调用 `POST /api/v1/sync` 上传变更
- **并且 (AND)** 接收服务器返回的新数据并更新本地数据库
- **并且 (AND)** 更新本地的 `last_synced_at` 时间戳

#### 场景：增量拉取
- **当 (WHEN)** 用户手动刷新或应用启动
- **那么 (THEN)** 调用 `GET /api/v1/sync?since=<last_timestamp>`
- **并且 (AND)** 仅拉取自该时间点后服务器端发生变更的数据

### 需求：文件存储 (File Storage)
系统必须支持通过 API 上传和下载文件（图片/备份）。

#### 场景：图片上传
- **当 (WHEN)** 用户上传宠物头像或记录图片
- **那么 (THEN)** 客户端先请求上传凭证或直接上传至后端 `/api/v1/upload`
- **并且 (AND)** 后端返回文件的 URL 存储在记录中

# 毛孩子日记

本项目支持两种账户管理模式，并可在打包或运行时通过参数切换。

## 账户模式（编译时参数）

- `ACCOUNT_MODE=local`：本地模式，升级 Pro 不要求先登录。
- `ACCOUNT_MODE=cloud`：云端模式，升级 Pro 前要求先登录。

说明：`ACCOUNT_MODE` 为编译期参数，切换模式后需要重新运行或重新打包。

## 常用命令

### 1. 查看设备

```powershell
flutter devices
```

### 2. 拉取依赖（按需）

```powershell
flutter pub get
```

### 3. 本地模式运行（local）

```powershell
flutter run -d <device_id> --dart-define=ACCOUNT_MODE=local --no-pub
```

### 4. 云端模式运行（cloud）

```powershell
flutter run -d <device_id> --dart-define=ACCOUNT_MODE=cloud --no-pub
```

### 5. 打包 APK（local）

```powershell
flutter build apk --dart-define=ACCOUNT_MODE=local --no-tree-shake-icons
```

### 6. 打包 APK（cloud）

```powershell
flutter build apk --dart-define=ACCOUNT_MODE=cloud --no-tree-shake-icons
```

## 内测分发流程（先不买域名）

### 1. 本地打包

```powershell
flutter build apk --dart-define=ACCOUNT_MODE=local --no-tree-shake-icons
```

产物路径：`build/app/outputs/flutter-apk/app-release.apk`

### 2. 上传到后端可访问位置

- 将 `app-release.apk` 放到 `furry_server` 配置的 `apk.path` 对应位置。
- 当前默认配置在 `furry_server/cmd/server/main.go`：
	- `apk.path`
	- `apk.download_name`
	- `apk.version`

建议每次内测版本都更新：

- `apk.download_name`：例如 `maohaizi-riji-v0.1.3-20260304.apk`
- `apk.version`：例如 `0.1.3-beta`

### 3. 启动下载服务

```powershell
cd ..\furry_server
go run cmd/server/main.go
```

### 4. 验证接口是否可用

```powershell
curl http://<服务器IP>:8080/api/v1/download/apk/meta
```

返回应包含：`version`、`fileName`、`downloadUrl`。

### 5. 发给内测用户

- 分享 `downloadUrl`。
- 微信里点击链接后，提示用户：右上角 -> 在浏览器打开 -> 下载并安装。

### 6. 回滚流程（发错包时）

- 用上一个可用 APK 覆盖 `apk.path` 指向文件。
- 把 `apk.version` 改回上一版本并重启服务。
- 用户重新打开下载链接即可安装回滚版本。

## 行为预期

- local 模式：点击“升级 Pro”直接进入购买页。
- cloud 模式：游客点击“升级 Pro”先进入登录页，登录成功后进入购买页。

## 切换模式前建议

为避免两种模式的登录态和会员态互相影响，建议切换模式前清理应用数据：

```powershell
adb -s <device_id> shell pm list packages | findstr furry
adb -s <device_id> shell pm clear <your_package_name>
```
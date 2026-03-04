# Furry Server Ubuntu 部署（最小可用版）

> 目标：30-60 分钟跑通账户登录、数据同步、APK 下载接口。  
> 适用：Ubuntu 22.04 + 公网服务器（1C2G 起步）

## 0. 服务器准备

- 安全组开放：`22`、`80`、`443`、`8080`
- 你需要：
  - 服务器公网 IP（记为 `SERVER_IP`）
  - SSH 账号（通常 `root`）

```bash
ssh root@SERVER_IP
```

---

## 1. 安装基础环境

```bash
apt update
apt install -y curl wget git unzip nginx mysql-server
```

### 1.1 安装 Go（建议 1.22+）

```bash
cd /tmp
wget https://go.dev/dl/go1.22.12.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.22.12.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
source /etc/profile

go version
```

---

## 2. 初始化 MySQL

```bash
systemctl enable mysql
systemctl start mysql

mysql -e "CREATE DATABASE IF NOT EXISTS furry DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'furry'@'127.0.0.1' IDENTIFIED BY 'StrongPass_123!';"
mysql -e "GRANT ALL PRIVILEGES ON furry.* TO 'furry'@'127.0.0.1'; FLUSH PRIVILEGES;"
```

> 生产请把密码改强，并限制来源 IP。

---

## 3. 上传并启动后端

### 3.1 上传代码

方式 A：直接 git clone（推荐）

```bash
cd /opt
git clone <你的仓库地址> maohaizi
```

方式 B：本地打包上传后解压到 `/opt/maohaizi`

### 3.2 构建 furry_server

```bash
cd /opt/maohaizi/furry_server
/usr/local/go/bin/go mod tidy
/usr/local/go/bin/go build -o furry-server ./cmd/server
```

---

## 4. 配置运行参数（systemd 环境变量）

创建环境文件：

```bash
cat > /opt/maohaizi/furry_server/.env << 'EOF'
server.port=8080
jwt.secret=replace-with-your-jwt-secret
mysql.dsn=furry:StrongPass_123!@tcp(127.0.0.1:3306)/furry?parseTime=true
apk.path=/opt/maohaizi/furry_diary/build/app/outputs/flutter-apk/app-release.apk
apk.download_name=maohaizi-riji
apk.version=1.0.0-beta
EOF
```

> 如果你的 `app-release.apk` 不在这个路径，请改 `apk.path`。

---

## 5. 使用 systemd 常驻

```bash
cat > /etc/systemd/system/furry-server.service << 'EOF'
[Unit]
Description=Furry Diary API Server
After=network.target mysql.service

[Service]
Type=simple
WorkingDirectory=/opt/maohaizi/furry_server
ExecStart=/opt/maohaizi/furry_server/furry-server
Restart=always
RestartSec=3
EnvironmentFile=/opt/maohaizi/furry_server/.env

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable furry-server
systemctl restart furry-server
systemctl status furry-server --no-pager
```

查看日志：

```bash
journalctl -u furry-server -f
```

---

## 6. 配置 Nginx 反向代理

```bash
cat > /etc/nginx/sites-available/furry << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/furry /etc/nginx/sites-enabled/furry
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx
```

---

## 7. 联调验证（服务器侧）

```bash
curl http://127.0.0.1:8080/api/v1/download/apk/meta
curl http://SERVER_IP/api/v1/download/apk/meta
```

你应看到 JSON，包含：

- `version`
- `fileName`
- `downloadUrl`

登录接口 smoke test：

```bash
curl -X POST http://SERVER_IP/api/v1/auth/sms/send \
  -H 'Content-Type: application/json' \
  -d '{"phone":"13800000000"}'

curl -X POST http://SERVER_IP/api/v1/auth/login/phone \
  -H 'Content-Type: application/json' \
  -d '{"phone":"13800000000","code":"123456"}'
```

---

## 8. Flutter 端改为统一账户模式

在你的 Flutter 配置里把 API 基地址改为：

- `http://SERVER_IP`（内测）
- `https://your-domain.com`（正式）

并移除 `ACCOUNT_MODE` 的本地/云端分叉逻辑，统一要求登录后同步。

---

## 9. 后续上线建议（建议尽快）

1. 上域名 + HTTPS（Certbot）
2. 把 `jwt.secret` 改成高强度随机字符串
3. MySQL 定时备份（每日）
4. Nginx 限流与基础防护
5. 日志切割与告警

---

## 10. 常见故障排查

### 10.1 服务起不来

```bash
systemctl status furry-server --no-pager
journalctl -u furry-server -n 200 --no-pager
```

### 10.2 数据库连接失败

- 检查 `.env` 中 `mysql.dsn`
- 检查 MySQL 是否运行：

```bash
systemctl status mysql --no-pager
```

### 10.3 APK 下载 404

- 检查 `apk.path` 是否存在
- 检查文件权限是否可读

```bash
ls -lah /opt/maohaizi/furry_diary/build/app/outputs/flutter-apk/
```

---

## 11. 快速回滚（发布失败）

1. 替换回上一个可用 APK 文件
2. 更新 `.env` 的 `apk.version`
3. 重启服务

```bash
systemctl restart furry-server
```

用户重新下载即可。

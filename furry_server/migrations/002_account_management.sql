-- 账户管理功能数据库迁移
-- 版本: 002
-- 日期: 2026-03-11

-- 修改 users 表，添加新字段
ALTER TABLE `users` ADD COLUMN `nickname` VARCHAR(64) DEFAULT NULL COMMENT '昵称';
ALTER TABLE `users` ADD COLUMN `avatar_url` VARCHAR(255) DEFAULT NULL COMMENT '头像URL';
ALTER TABLE `users` ADD COLUMN `email` VARCHAR(128) DEFAULT NULL COMMENT '邮箱';
ALTER TABLE `users` ADD COLUMN `wechat_openid` VARCHAR(64) DEFAULT NULL COMMENT '微信OpenID';
ALTER TABLE `users` ADD COLUMN `qq_openid` VARCHAR(64) DEFAULT NULL COMMENT 'QQ OpenID';
ALTER TABLE `users` ADD COLUMN `pro_expired_at` DATETIME DEFAULT NULL COMMENT 'Pro会员过期时间';
ALTER TABLE `users` ADD COLUMN `last_synced_at` DATETIME DEFAULT NULL COMMENT '最后同步时间';
ALTER TABLE `users` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间';

-- 添加唯一索引
CREATE UNIQUE INDEX `idx_wechat_openid` ON `users` (`wechat_openid`);
CREATE UNIQUE INDEX `idx_qq_openid` ON `users` (`qq_openid`);

-- 创建设备表
CREATE TABLE `devices` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `device_id` VARCHAR(64) NOT NULL COMMENT '设备唯一标识',
    `device_name` VARCHAR(128) DEFAULT NULL COMMENT '设备名称',
    `device_type` VARCHAR(20) DEFAULT NULL COMMENT '设备类型: ios/android',
    `last_login_at` DATETIME DEFAULT NULL COMMENT '最后登录时间',
    `last_active_at` DATETIME DEFAULT NULL COMMENT '最后活跃时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    UNIQUE KEY `uk_user_device` (`user_id`, `device_id`),
    INDEX `idx_user_id` (`user_id`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='设备表';

-- 创建同步记录表
CREATE TABLE `sync_records` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `record_type` VARCHAR(20) NOT NULL COMMENT '记录类型: pet/health_record',
    `record_id` VARCHAR(64) NOT NULL COMMENT '记录ID',
    `action` VARCHAR(20) NOT NULL COMMENT '操作类型: create/update/delete',
    `data` JSON DEFAULT NULL COMMENT '记录数据',
    `synced_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '同步时间',
    
    INDEX `idx_user_record` (`user_id`, `record_type`, `record_id`),
    INDEX `idx_synced_at` (`synced_at`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='同步记录表';

-- 修改 pets 表，添加新字段
ALTER TABLE `pets` ADD COLUMN `user_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '用户ID';
ALTER TABLE `pets` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间';
ALTER TABLE `pets` ADD INDEX `idx_user_id` (`user_id`);
ALTER TABLE `pets` ADD CONSTRAINT `fk_pets_user` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE;

-- 修改 health_records 表，添加新字段
ALTER TABLE `health_records` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL COMMENT '软删除时间';

-- 创建验证码记录表
CREATE TABLE `sms_codes` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
    `code` VARCHAR(6) NOT NULL COMMENT '验证码',
    `purpose` VARCHAR(20) DEFAULT 'login' COMMENT '用途: login/bind',
    `expires_at` DATETIME NOT NULL COMMENT '过期时间',
    `used_at` DATETIME DEFAULT NULL COMMENT '使用时间',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_phone_purpose` (`phone`, `purpose`),
    INDEX `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='短信验证码表';

-- 创建登录日志表
CREATE TABLE `login_logs` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
    `device_id` VARCHAR(64) DEFAULT NULL COMMENT '设备ID',
    `device_name` VARCHAR(128) DEFAULT NULL COMMENT '设备名称',
    `device_type` VARCHAR(20) DEFAULT NULL COMMENT '设备类型',
    `ip_address` VARCHAR(45) DEFAULT NULL COMMENT 'IP地址',
    `login_type` VARCHAR(20) DEFAULT 'phone' COMMENT '登录方式: phone/wechat/qq',
    `status` VARCHAR(20) DEFAULT 'success' COMMENT '状态: success/failed',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_created_at` (`created_at`),
    
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志表';

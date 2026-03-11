package main

import (
	"log"
	"path/filepath"

	"furry-server/internal/handlers"
	"furry-server/internal/middleware"
	"furry-server/internal/models"
	"furry-server/internal/services"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

func main() {
	viper.SetDefault("server.port", "8080")
	viper.SetDefault("jwt.secret", "dev-secret")
	viper.SetDefault("mysql.dsn", "root:root@tcp(127.0.0.1:3306)/furry?parseTime=true")
	viper.SetDefault("apk.path", "../furry_diary/build/app/outputs/flutter-apk/app-release.apk")
	viper.SetDefault("apk.download_name", "maohaizi-riji-release.apk")
	viper.SetDefault("apk.version", "latest")

	db, err := gorm.Open(mysql.Open(viper.GetString("mysql.dsn")), &gorm.Config{})
	if err != nil {
		log.Fatal(err)
	}

	if err := db.AutoMigrate(
		&models.User{},
		&models.Device{},
		&models.Pet{},
		&models.HealthRecord{},
		&models.Order{},
		&models.SyncRecord{},
		&models.SMSCode{},
		&models.LoginLog{},
	); err != nil {
		log.Fatal(err)
	}

	authHandler := &handlers.AuthHandler{
		DB:          db,
		JWTSecret:   viper.GetString("jwt.secret"),
		SMSProvider: services.MockSMSProvider{},
	}
	userHandler := &handlers.UserHandler{DB: db}
	deviceHandler := &handlers.DeviceHandler{DB: db}
	syncHandler := &handlers.SyncHandler{DB: db}
	paymentHandler := &handlers.PaymentHandler{DB: db}
	uploadHandler := &handlers.UploadHandler{}
	downloadHandler := &handlers.DownloadHandler{
		APKPath:      filepath.Clean(viper.GetString("apk.path")),
		DownloadName: viper.GetString("apk.download_name"),
		APKVersion:   viper.GetString("apk.version"),
	}

	r := gin.New()
	r.Use(middleware.Logger())
	r.Use(cors.Default())
	r.Use(middleware.ErrorHandler())

	v1 := r.Group("/api/v1")
	{
		// 认证相关 - 无需登录
		v1.POST("/auth/sms/send", authHandler.SendSMS)
		v1.POST("/auth/login/phone", authHandler.LoginPhone)
		v1.POST("/auth/login/wechat", authHandler.LoginWechat)
		v1.POST("/auth/login/qq", authHandler.LoginQQ)

		// 需要认证的路由
		auth := v1.Group("/")
		auth.Use(middleware.JWTAuth(viper.GetString("jwt.secret")))
		{
			// 用户相关
			auth.GET("/user/profile", userHandler.GetProfile)
			auth.PUT("/user/profile", userHandler.UpdateProfile)
			auth.POST("/user/logout", userHandler.Logout)
			auth.DELETE("/user/account", userHandler.DeleteAccount)

			// 绑定第三方账号
			auth.POST("/auth/bind/phone", authHandler.BindPhone)
			auth.POST("/auth/bind/wechat", authHandler.BindWechat)
			auth.POST("/auth/bind/qq", authHandler.BindQQ)

			// 设备管理
			auth.POST("/devices/register", deviceHandler.RegisterDevice)
			auth.GET("/devices", deviceHandler.GetDevices)
			auth.DELETE("/devices/:id", deviceHandler.RemoveDevice)

			// 数据同步
			auth.POST("/sync/upload", syncHandler.Upload)
			auth.GET("/sync/download", syncHandler.Download)

			// 支付
			auth.POST("/payment/order", paymentHandler.CreateOrder)
			auth.POST("/payment/verify/apple", paymentHandler.VerifyApple)
		}

		// 支付回调 - 无需认证
		v1.POST("/payment/notify/:provider", paymentHandler.Notify)

		// 文件上传 - 无需认证（临时）
		v1.POST("/upload", uploadHandler.Upload)

		// APK下载 - 无需认证
		v1.GET("/download/apk", downloadHandler.DownloadAPK)
		v1.GET("/download/apk/meta", downloadHandler.LatestAPKMeta)
	}

	log.Fatal(r.Run(":" + viper.GetString("server.port")))
}

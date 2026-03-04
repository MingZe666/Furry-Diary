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
	if err := db.AutoMigrate(&models.User{}, &models.Pet{}, &models.HealthRecord{}, &models.Order{}); err != nil {
		log.Fatal(err)
	}

	authHandler := &handlers.AuthHandler{DB: db, JWTSecret: viper.GetString("jwt.secret"), SMSProvider: services.MockSMSProvider{}}
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
		v1.POST("/auth/sms/send", authHandler.SendSMS)
		v1.POST("/auth/login/phone", authHandler.LoginPhone)
		v1.POST("/sync", syncHandler.Sync)
		v1.POST("/upload", uploadHandler.Upload)
		v1.GET("/download/apk", downloadHandler.DownloadAPK)
		v1.GET("/download/apk/meta", downloadHandler.LatestAPKMeta)

		auth := v1.Group("/")
		auth.Use(middleware.JWTAuth(viper.GetString("jwt.secret")))
		{
			auth.POST("payment/order", paymentHandler.CreateOrder)
			auth.POST("payment/verify/apple", paymentHandler.VerifyApple)
		}
		v1.POST("/payment/notify/:provider", paymentHandler.Notify)
	}

	log.Fatal(r.Run(":" + viper.GetString("server.port")))
}

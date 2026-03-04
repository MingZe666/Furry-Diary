package handlers

import (
	"net/http"
	"strconv"
	"time"

	"furry-server/internal/models"
	"furry-server/internal/services"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"gorm.io/gorm"
)

type AuthHandler struct {
	DB          *gorm.DB
	JWTSecret   string
	SMSProvider services.SMSProvider
}

type sendSMSRequest struct {
	Phone string `json:"phone" binding:"required"`
}

type loginPhoneRequest struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required"`
}

func (h *AuthHandler) SendSMS(c *gin.Context) {
	var req sendSMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	code := "123456"
	if err := h.SMSProvider.SendCode(req.Phone, code); err != nil {
		c.JSON(http.StatusBadGateway, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "sent"})
}

func (h *AuthHandler) LoginPhone(c *gin.Context) {
	var req loginPhoneRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.Code != "123456" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid code"})
		return
	}

	var user models.User
	err := h.DB.Where("phone = ?", req.Phone).First(&user).Error
	if err != nil {
		if err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		user = models.User{Phone: req.Phone, IsPro: false}
		if createErr := h.DB.Create(&user).Error; createErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": createErr.Error()})
			return
		}
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": strconv.FormatUint(uint64(user.ID), 10),
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
	})
	signed, err := token.SignedString([]byte(h.JWTSecret))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": signed,
		"user": gin.H{
			"id":      strconv.FormatUint(uint64(user.ID), 10),
			"phone":   user.Phone,
			"isGuest": false,
			"isPro":   user.IsPro,
			"token":   signed,
		},
	})
}

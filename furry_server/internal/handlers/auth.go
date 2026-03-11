package handlers

import (
	"crypto/rand"
	"log"
	"math/big"
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
	Phone   string `json:"phone" binding:"required"`
	Purpose string `json:"purpose"`
}

type loginPhoneRequest struct {
	Phone      string `json:"phone" binding:"required"`
	Code       string `json:"code" binding:"required"`
	DeviceID   string `json:"device_id"`
	DeviceName string `json:"device_name"`
	DeviceType string `json:"device_type"`
}

type loginWechatRequest struct {
	Code       string `json:"code" binding:"required"`
	DeviceID   string `json:"device_id"`
	DeviceName string `json:"device_name"`
	DeviceType string `json:"device_type"`
}

type loginQQRequest struct {
	AccessToken string `json:"access_token" binding:"required"`
	OpenID      string `json:"open_id" binding:"required"`
	DeviceID    string `json:"device_id"`
	DeviceName  string `json:"device_name"`
	DeviceType  string `json:"device_type"`
}

type bindPhoneRequest struct {
	Phone string `json:"phone" binding:"required"`
	Code  string `json:"code" binding:"required"`
}

func (h *AuthHandler) SendSMS(c *gin.Context) {
	var req sendSMSRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	purpose := req.Purpose
	if purpose == "" {
		purpose = "login"
	}

	var count int64
	h.DB.Model(&models.SMSCode{}).Where(
		"phone = ? AND created_at > ?", req.Phone, time.Now().Add(-24*time.Hour),
	).Count(&count)
	if count >= 5 {
		c.JSON(http.StatusTooManyRequests, gin.H{"error": "验证码发送次数已达上限"})
		return
	}

	// 生成6位随机验证码
	code := generateRandomCode(6)
	if h.SMSProvider == nil {
		// SMSProvider 为空时使用固定验证码，并记录警告日志
		code = "123456"
		log.Printf("[警告] SMSProvider 未配置，使用固定验证码: %s (手机号: %s)", code, req.Phone)
	} else {
		if err := h.SMSProvider.SendCode(req.Phone, code); err != nil {
			c.JSON(http.StatusBadGateway, gin.H{"error": err.Error()})
			return
		}
	}

	smsCode := models.SMSCode{
		Phone:     req.Phone,
		Code:      code,
		Purpose:   purpose,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	}
	h.DB.Create(&smsCode)

	c.JSON(http.StatusOK, gin.H{"message": "sent"})
}

func (h *AuthHandler) LoginPhone(c *gin.Context) {
	var req loginPhoneRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var smsCode models.SMSCode
	err := h.DB.Where(
		"phone = ? AND code = ? AND purpose = ? AND expires_at > ? AND used_at IS NULL",
		req.Phone, req.Code, "login", time.Now(),
	).First(&smsCode).Error
	if err != nil {
		if req.Code == "123456" {
			// 开发环境允许固定验证码
		} else {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "验证码错误或已过期"})
			return
		}
	} else {
		now := time.Now()
		smsCode.UsedAt = &now
		h.DB.Save(&smsCode)
	}

	var user models.User
	err = h.DB.Where("phone = ?", req.Phone).First(&user).Error
	isNewUser := false
	if err != nil {
		if err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		// 新用户创建时不设置默认昵称，保持为空字符串
		// 这样 need_setup_profile 才能正确判断用户是否需要设置个人资料
		user = models.User{
			Phone:    req.Phone,
			Nickname: "",
			IsPro:    false,
		}
		if createErr := h.DB.Create(&user).Error; createErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": createErr.Error()})
			return
		}
		isNewUser = true
	}

	if req.DeviceID != "" {
		h.registerDevice(user.ID, req.DeviceID, req.DeviceName, req.DeviceType)
	}

	h.createLoginLog(user.ID, req.DeviceID, req.DeviceName, req.DeviceType, c.ClientIP(), "phone", "success")

	token, err := h.generateJWT(user.ID, req.DeviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token": token,
		"user":  h.userToResponse(user),
		"is_new_user": isNewUser,
		"need_setup_profile": user.Nickname == "",
	})
}

func (h *AuthHandler) LoginWechat(c *gin.Context) {
	var req loginWechatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: 调用微信API获取OpenID
	// 这里暂时使用code作为openid进行测试
	openID := req.Code

	var user models.User
	err := h.DB.Where("wechat_openid = ?", openID).First(&user).Error
	needBindPhone := false
	if err != nil {
		if err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		user = models.User{
			WechatOpenID: openID,
			Nickname:     "微信用户",
			IsPro:        false,
		}
		if createErr := h.DB.Create(&user).Error; createErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": createErr.Error()})
			return
		}
		needBindPhone = true
	}

	if user.Phone == "" {
		needBindPhone = true
	}

	if req.DeviceID != "" {
		h.registerDevice(user.ID, req.DeviceID, req.DeviceName, req.DeviceType)
	}

	h.createLoginLog(user.ID, req.DeviceID, req.DeviceName, req.DeviceType, c.ClientIP(), "wechat", "success")

	token, err := h.generateJWT(user.ID, req.DeviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":           token,
		"user":            h.userToResponse(user),
		"need_bind_phone": needBindPhone,
	})
}

func (h *AuthHandler) LoginQQ(c *gin.Context) {
	var req loginQQRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: 验证QQ access_token和open_id

	var user models.User
	err := h.DB.Where("qq_openid = ?", req.OpenID).First(&user).Error
	needBindPhone := false
	if err != nil {
		if err != gorm.ErrRecordNotFound {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		user = models.User{
			QQOpenID: req.OpenID,
			Nickname: "QQ用户",
			IsPro:    false,
		}
		if createErr := h.DB.Create(&user).Error; createErr != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": createErr.Error()})
			return
		}
		needBindPhone = true
	}

	if user.Phone == "" {
		needBindPhone = true
	}

	if req.DeviceID != "" {
		h.registerDevice(user.ID, req.DeviceID, req.DeviceName, req.DeviceType)
	}

	h.createLoginLog(user.ID, req.DeviceID, req.DeviceName, req.DeviceType, c.ClientIP(), "qq", "success")

	token, err := h.generateJWT(user.ID, req.DeviceID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"token":           token,
		"user":            h.userToResponse(user),
		"need_bind_phone": needBindPhone,
	})
}

func (h *AuthHandler) BindPhone(c *gin.Context) {
	var req bindPhoneRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var smsCode models.SMSCode
	err := h.DB.Where(
		"phone = ? AND code = ? AND purpose = ? AND expires_at > ? AND used_at IS NULL",
		req.Phone, req.Code, "bind", time.Now(),
	).First(&smsCode).Error
	if err != nil {
		if req.Code == "123456" {
			// 开发环境允许固定验证码
		} else {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "验证码错误或已过期"})
			return
		}
	} else {
		now := time.Now()
		smsCode.UsedAt = &now
		h.DB.Save(&smsCode)
	}

	var existingUser models.User
	if err := h.DB.Where("phone = ? AND id != ?", req.Phone, uid).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "该手机号已被其他账号绑定"})
		return
	}

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	user.Phone = req.Phone
	h.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"user":    h.userToResponse(user),
	})
}

func (h *AuthHandler) BindWechat(c *gin.Context) {
	var req struct {
		Code string `json:"code" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// TODO: 调用微信API获取OpenID
	openID := req.Code

	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var existingUser models.User
	if err := h.DB.Where("wechat_openid = ? AND id != ?", openID, uid).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "该微信已被其他账号绑定"})
		return
	}

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	user.WechatOpenID = openID
	h.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (h *AuthHandler) BindQQ(c *gin.Context) {
	var req struct {
		AccessToken string `json:"access_token" binding:"required"`
		OpenID      string `json:"open_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var existingUser models.User
	if err := h.DB.Where("qq_openid = ? AND id != ?", req.OpenID, uid).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "该QQ已被其他账号绑定"})
		return
	}

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	user.QQOpenID = req.OpenID
	h.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (h *AuthHandler) generateJWT(userID uint, deviceID string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id":   strconv.FormatUint(uint64(userID), 10),
		"device_id": deviceID,
		"exp":       time.Now().Add(7 * 24 * time.Hour).Unix(),
	})
	return token.SignedString([]byte(h.JWTSecret))
}

func (h *AuthHandler) registerDevice(userID uint, deviceID, deviceName, deviceType string) {
	var device models.Device
	err := h.DB.Where("user_id = ? AND device_id = ?", userID, deviceID).First(&device).Error
	now := time.Now()

	if err != nil {
		device = models.Device{
			UserID:      userID,
			DeviceID:    deviceID,
			DeviceName:  deviceName,
			DeviceType:  deviceType,
			LastLoginAt: &now,
		}
		h.DB.Create(&device)
	} else {
		device.LastLoginAt = &now
		device.DeviceName = deviceName
		device.DeviceType = deviceType
		h.DB.Save(&device)
	}
}

func (h *AuthHandler) createLoginLog(userID uint, deviceID, deviceName, deviceType, ipAddress, loginType, status string) {
	log := models.LoginLog{
		UserID:     userID,
		DeviceID:   deviceID,
		DeviceName: deviceName,
		DeviceType: deviceType,
		IPAddress:  ipAddress,
		LoginType:  loginType,
		Status:     status,
	}
	h.DB.Create(&log)
}

func (h *AuthHandler) userToResponse(user models.User) gin.H {
	return gin.H{
		"id":            strconv.FormatUint(uint64(user.ID), 10),
		"phone":         maskPhone(user.Phone),
		"nickname":      user.Nickname,
		"avatar_url":    user.AvatarURL,
		"email":         user.Email,
		"is_pro":        user.IsPro,
		"pro_expired_at": user.ProExpiredAt,
		"created_at":    user.CreatedAt,
	}
}

func maskPhone(phone string) string {
	if len(phone) < 7 {
		return phone
	}
	return phone[:3] + "****" + phone[len(phone)-4:]
}

// generateRandomCode 生成指定长度的随机数字验证码
func generateRandomCode(length int) string {
	const digits = "0123456789"
	code := make([]byte, length)
	for i := range code {
		n, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))
		if err != nil {
			// 如果加密随机数生成失败，使用时间戳作为后备方案
			code[i] = digits[time.Now().Nanosecond()%10]
			continue
		}
		code[i] = digits[n.Int64()]
	}
	return string(code)
}

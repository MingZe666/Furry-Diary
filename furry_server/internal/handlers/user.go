package handlers

import (
	"net/http"
	"strconv"
	"time"

	"furry-server/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UserHandler struct {
	DB *gorm.DB
}

func (h *UserHandler) GetProfile(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	c.JSON(http.StatusOK, h.userToResponse(user))
}

func (h *UserHandler) UpdateProfile(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var req struct {
		Nickname  string `json:"nickname"`
		AvatarURL string `json:"avatar_url"`
		Email     string `json:"email"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	if req.Nickname != "" {
		if len(req.Nickname) < 2 || len(req.Nickname) > 20 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "昵称长度需在2-20个字符之间"})
			return
		}
		user.Nickname = req.Nickname
	}
	if req.AvatarURL != "" {
		user.AvatarURL = req.AvatarURL
	}
	if req.Email != "" {
		user.Email = req.Email
	}

	h.DB.Save(&user)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"user":    h.userToResponse(user),
	})
}

func (h *UserHandler) Logout(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var req struct {
		DeviceID string `json:"device_id"`
	}
	c.ShouldBindJSON(&req)

	if req.DeviceID != "" {
		h.DB.Where("user_id = ? AND device_id = ?", uid, req.DeviceID).Delete(&models.Device{})
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

func (h *UserHandler) DeleteAccount(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	// 先查询用户，确保用户存在
	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	// 使用软删除，GORM 会自动设置 deleted_at 字段
	h.DB.Delete(&user)

	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"message": "账户已注销",
	})
}

func (h *UserHandler) userToResponse(user models.User) gin.H {
	return gin.H{
		"id":             strconv.FormatUint(uint64(user.ID), 10),
		"phone":          maskPhone(user.Phone),
		"nickname":       user.Nickname,
		"avatar_url":     user.AvatarURL,
		"email":          user.Email,
		"is_pro":         user.IsPro,
		"pro_expired_at": user.ProExpiredAt,
		"created_at":     user.CreatedAt,
		"wechat_bound":   user.WechatOpenID != "",
		"qq_bound":       user.QQOpenID != "",
	}
}

type DeviceHandler struct {
	DB *gorm.DB
}

func (h *DeviceHandler) RegisterDevice(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var req struct {
		DeviceID   string `json:"device_id" binding:"required"`
		DeviceName string `json:"device_name"`
		DeviceType string `json:"device_type"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	maxDevices := 1
	if user.IsPro {
		maxDevices = 3
	}

	var deviceCount int64
	h.DB.Model(&models.Device{}).Where("user_id = ?", uid).Count(&deviceCount)

	var existingDevice models.Device
	deviceExists := h.DB.Where("user_id = ? AND device_id = ?", uid, req.DeviceID).First(&existingDevice).Error == nil

	if !deviceExists && int(deviceCount) >= maxDevices {
		var oldestDevice models.Device
		h.DB.Where("user_id = ?", uid).Order("last_login_at ASC").First(&oldestDevice)
		h.DB.Delete(&oldestDevice)
	}

	now := time.Now()
	device := models.Device{
		UserID:      uint(uid),
		DeviceID:    req.DeviceID,
		DeviceName:  req.DeviceName,
		DeviceType:  req.DeviceType,
		LastLoginAt: &now,
	}

	if deviceExists {
		h.DB.Where("user_id = ? AND device_id = ?", uid, req.DeviceID).
			Assign(map[string]interface{}{
				"device_name":   req.DeviceName,
				"device_type":   req.DeviceType,
				"last_login_at": now,
			}).
			FirstOrCreate(&device)
	} else {
		h.DB.Create(&device)
	}

	h.DB.Model(&models.Device{}).Where("user_id = ?", uid).Count(&deviceCount)

	c.JSON(http.StatusOK, gin.H{
		"success":       true,
		"devices_count": deviceCount,
		"max_devices":   maxDevices,
	})
}

func (h *DeviceHandler) GetDevices(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var user models.User
	if err := h.DB.First(&user, uid).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	maxDevices := 1
	if user.IsPro {
		maxDevices = 3
	}

	var devices []models.Device
	h.DB.Where("user_id = ?", uid).Order("last_login_at DESC").Find(&devices)

	currentDeviceID, _ := c.Get("device_id")

	deviceResponses := make([]gin.H, 0, len(devices))
	for _, d := range devices {
		deviceResponses = append(deviceResponses, gin.H{
			"id":              d.ID,
			"device_id":       d.DeviceID,
			"device_name":     d.DeviceName,
			"device_type":     d.DeviceType,
			"last_login_at":   d.LastLoginAt,
			"last_active_at":  d.LastActiveAt,
			"is_current":      d.DeviceID == currentDeviceID,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"devices":     deviceResponses,
		"max_devices": maxDevices,
	})
}

func (h *DeviceHandler) RemoveDevice(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	deviceIDStr := c.Param("id")
	deviceID, err := strconv.ParseUint(deviceIDStr, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的设备ID"})
		return
	}

	result := h.DB.Where("id = ? AND user_id = ?", deviceID, uid).Delete(&models.Device{})
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "设备不存在"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"success": true})
}

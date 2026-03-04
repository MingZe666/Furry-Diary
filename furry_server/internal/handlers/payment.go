package handlers

import (
	"net/http"
	"strconv"

	"furry-server/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PaymentHandler struct {
	DB *gorm.DB
}

type createOrderRequest struct {
	Provider string `json:"provider" binding:"required"`
	Amount   int64  `json:"amount" binding:"required"`
}

func (h *PaymentHandler) CreateOrder(c *gin.Context) {
	var req createOrderRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	userIDRaw, _ := c.Get("user_id")
	userID, _ := strconv.ParseUint(userIDRaw.(string), 10, 64)

	order := models.Order{
		ID:       uuid.NewString(),
		UserID:   uint(userID),
		Amount:   req.Amount,
		Provider: req.Provider,
		Status:   "created",
	}
	if err := h.DB.Create(&order).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"order": order})
}

func (h *PaymentHandler) Notify(c *gin.Context) {
	provider := c.Param("provider")
	orderID := c.PostForm("order_id")

	var order models.Order
	if err := h.DB.Where("id = ?", orderID).First(&order).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "order not found"})
		return
	}
	order.Status = "paid"
	h.DB.Save(&order)
	h.DB.Model(&models.User{}).Where("id = ?", order.UserID).Update("is_pro", true)
	c.JSON(http.StatusOK, gin.H{"provider": provider, "status": "ok"})
}

func (h *PaymentHandler) VerifyApple(c *gin.Context) {
	var payload map[string]string
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	receipt := payload["receipt"]
	if receipt == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "missing receipt"})
		return
	}

	userIDRaw, _ := c.Get("user_id")
	userID, _ := strconv.ParseUint(userIDRaw.(string), 10, 64)
	h.DB.Model(&models.User{}).Where("id = ?", userID).Update("is_pro", true)
	c.JSON(http.StatusOK, gin.H{"verified": true})
}

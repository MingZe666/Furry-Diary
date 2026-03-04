package handlers

import (
	"net/http"
	"time"

	"furry-server/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SyncHandler struct {
	DB *gorm.DB
}

type syncPayload struct {
	LastSyncedAt *time.Time            `json:"lastSyncedAt"`
	Dirty        []models.HealthRecord `json:"dirty"`
}

func (h *SyncHandler) Sync(c *gin.Context) {
	var payload syncPayload
	if err := c.ShouldBindJSON(&payload); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for _, record := range payload.Dirty {
		if record.ID == "" {
			continue
		}
		record.UpdatedAt = time.Now()
		h.DB.Save(&record)
	}

	query := h.DB.Model(&models.HealthRecord{})
	if payload.LastSyncedAt != nil {
		query = query.Where("updated_at > ?", *payload.LastSyncedAt)
	}
	var records []models.HealthRecord
	query.Find(&records)

	c.JSON(http.StatusOK, gin.H{"records": records, "serverTime": time.Now()})
}

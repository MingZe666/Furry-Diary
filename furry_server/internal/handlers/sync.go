package handlers

import (
	"log"
	"net/http"
	"strconv"
	"time"

	"furry-server/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type SyncHandler struct {
	DB *gorm.DB
}

type syncUploadRequest struct {
	LastSyncedAt *time.Time `json:"last_synced_at"`
	Pets         []petData  `json:"pets"`
	Records      []recordData `json:"records"`
}

type petData struct {
	ID         string     `json:"id"`
	Name       string     `json:"name"`
	Type       string     `json:"type"`
	Breed      string     `json:"breed"`
	Gender     string     `json:"gender"`
	Color      string     `json:"color"`
	ChipNo     string     `json:"chip_no"`
	AvatarURL  string     `json:"avatar_url"`
	Birthday   *time.Time `json:"birthday"`
	UpdatedAt  time.Time  `json:"updated_at"`
	DeletedAt  *time.Time `json:"deleted_at"`
}

type recordData struct {
	ID          string     `json:"id"`
	PetID       string     `json:"pet_id"`
	Type        string     `json:"type"`
	Title       string     `json:"title"`
	Note        string     `json:"note"`
	Date        time.Time  `json:"date"`
	NextDueDate *time.Time `json:"next_due_date"`
	UpdatedAt   time.Time  `json:"updated_at"`
	DeletedAt   *time.Time `json:"deleted_at"`
}

func (h *SyncHandler) Upload(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	var req syncUploadRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for _, pet := range req.Pets {
		var existingPet models.Pet
		err := h.DB.Where("id = ?", pet.ID).First(&existingPet).Error

		if pet.DeletedAt != nil {
			if err == nil {
				h.DB.Delete(&existingPet)
			}
			continue
		}

		petID, err := strconv.ParseUint(pet.ID, 10, 64)
		if err != nil {
			log.Printf("解析 pet.ID 失败: %v, pet.ID: %s", err, pet.ID)
			continue
		}
		newPet := models.Pet{
			ID:        uint(petID),
			UserID:    uint(uid),
			Name:      pet.Name,
			Type:      pet.Type,
			Breed:     pet.Breed,
			Gender:    pet.Gender,
			Color:     pet.Color,
			ChipNo:    pet.ChipNo,
			AvatarURL: pet.AvatarURL,
			Birthday:  pet.Birthday,
			UpdatedAt: pet.UpdatedAt,
		}

		if err == nil {
			if pet.UpdatedAt.After(existingPet.UpdatedAt) {
				newPet.CreatedAt = existingPet.CreatedAt
				h.DB.Save(&newPet)
			}
		} else {
			h.DB.Create(&newPet)
		}
	}

	for _, record := range req.Records {
		var existingRecord models.HealthRecord
		err := h.DB.Where("id = ?", record.ID).First(&existingRecord).Error

		if record.DeletedAt != nil {
			if err == nil {
				h.DB.Delete(&existingRecord)
			}
			continue
		}

		petID, err := strconv.ParseUint(record.PetID, 10, 64)
		if err != nil {
			log.Printf("解析 record.PetID 失败: %v, record.PetID: %s", err, record.PetID)
			continue
		}
		newRecord := models.HealthRecord{
			ID:          record.ID,
			UserID:      uint(uid),
			PetID:       uint(petID),
			Type:        record.Type,
			Title:       record.Title,
			Note:        record.Note,
			Date:        record.Date,
			NextDueDate: record.NextDueDate,
			UpdatedAt:   record.UpdatedAt,
		}

		if err == nil {
			if record.UpdatedAt.After(existingRecord.UpdatedAt) {
				h.DB.Save(&newRecord)
			}
		} else {
			h.DB.Create(&newRecord)
		}
	}

	now := time.Now()
	h.DB.Model(&models.User{}).Where("id = ?", uid).Update("last_synced_at", now)

	c.JSON(http.StatusOK, gin.H{
		"success":   true,
		"synced_at": now,
	})
}

func (h *SyncHandler) Download(c *gin.Context) {
	userID, _ := c.Get("user_id")
	uid, _ := strconv.ParseUint(userID.(string), 10, 64)

	lastSyncedAtStr := c.Query("last_synced_at")
	var lastSyncedAt *time.Time
	if lastSyncedAtStr != "" {
		t, err := time.Parse(time.RFC3339, lastSyncedAtStr)
		if err == nil {
			lastSyncedAt = &t
		}
	}

	var pets []models.Pet
	petQuery := h.DB.Unscoped().Where("user_id = ?", uid)
	if lastSyncedAt != nil {
		petQuery = petQuery.Where("updated_at > ?", *lastSyncedAt)
	}
	petQuery.Find(&pets)

	petResponses := make([]gin.H, 0, len(pets))
	for _, p := range pets {
		var deletedAt interface{}
		if p.DeletedAt.Valid {
			deletedAt = p.DeletedAt.Time
		}
		petResponses = append(petResponses, gin.H{
			"id":         strconv.FormatUint(uint64(p.ID), 10),
			"name":       p.Name,
			"type":       p.Type,
			"breed":      p.Breed,
			"gender":     p.Gender,
			"color":      p.Color,
			"chip_no":    p.ChipNo,
			"avatar_url": p.AvatarURL,
			"birthday":   p.Birthday,
			"updated_at": p.UpdatedAt,
			"deleted_at": deletedAt,
		})
	}

	var records []models.HealthRecord
	recordQuery := h.DB.Unscoped().Where("user_id = ?", uid)
	if lastSyncedAt != nil {
		recordQuery = recordQuery.Where("updated_at > ?", *lastSyncedAt)
	}
	recordQuery.Find(&records)

	recordResponses := make([]gin.H, 0, len(records))
	for _, r := range records {
		var deletedAt interface{}
		if r.DeletedAt.Valid {
			deletedAt = r.DeletedAt.Time
		}
		recordResponses = append(recordResponses, gin.H{
			"id":            r.ID,
			"pet_id":        strconv.FormatUint(uint64(r.PetID), 10),
			"type":          r.Type,
			"title":         r.Title,
			"note":          r.Note,
			"date":          r.Date,
			"next_due_date": r.NextDueDate,
			"updated_at":    r.UpdatedAt,
			"deleted_at":    deletedAt,
		})
	}

	now := time.Now()
	h.DB.Model(&models.User{}).Where("id = ?", uid).Update("last_synced_at", now)

	c.JSON(http.StatusOK, gin.H{
		"pets":      petResponses,
		"records":   recordResponses,
		"synced_at": now,
	})
}

func (h *SyncHandler) Sync(c *gin.Context) {
	var payload struct {
		LastSyncedAt *time.Time            `json:"lastSyncedAt"`
		Dirty        []models.HealthRecord `json:"dirty"`
	}
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

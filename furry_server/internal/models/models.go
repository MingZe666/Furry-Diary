package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID           uint           `json:"id" gorm:"primaryKey"`
	Phone        string         `json:"phone" gorm:"uniqueIndex;size:20"`
	PasswordHash string         `json:"-"`
	Nickname     string         `json:"nickname" gorm:"size:64"`
	AvatarURL    string         `json:"avatar_url" gorm:"size:255"`
	Email        string         `json:"email" gorm:"size:128"`
	WechatOpenID string         `json:"-" gorm:"uniqueIndex;size:64"`
	QQOpenID     string         `json:"-" gorm:"uniqueIndex;size:64"`
	IsPro        bool           `json:"is_pro" gorm:"default:false"`
	ProExpiredAt *time.Time     `json:"pro_expired_at"`
	LastSyncedAt *time.Time     `json:"last_synced_at"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `json:"-" gorm:"index"`
}

func (User) TableName() string {
	return "users"
}

type Device struct {
	ID           uint       `json:"id" gorm:"primaryKey"`
	UserID       uint       `json:"user_id" gorm:"uniqueIndex:uk_user_device;not null"`
	DeviceID     string     `json:"device_id" gorm:"uniqueIndex:uk_user_device;size:64;not null"`
	DeviceName   string     `json:"device_name" gorm:"size:128"`
	DeviceType   string     `json:"device_type" gorm:"size:20"`
	LastLoginAt  *time.Time `json:"last_login_at"`
	LastActiveAt *time.Time `json:"last_active_at"`
	CreatedAt    time.Time  `json:"created_at"`
}

func (Device) TableName() string {
	return "devices"
}

type Pet struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	UserID    uint           `json:"user_id" gorm:"index;not null"`
	Name      string         `json:"name" gorm:"size:64;not null"`
	Type      string         `json:"type" gorm:"size:32"`
	Breed     string         `json:"breed" gorm:"size:64"`
	Birthday  *time.Time     `json:"birthday"`
	Gender    string         `json:"gender" gorm:"size:10"`
	Color     string         `json:"color" gorm:"size:32"`
	ChipNo    string         `json:"chip_no" gorm:"size:64"`
	AvatarURL string         `json:"avatar_url" gorm:"size:255"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

func (Pet) TableName() string {
	return "pets"
}

type HealthRecord struct {
	ID          string         `json:"id" gorm:"primaryKey;size:64"`
	UserID      uint           `json:"user_id" gorm:"index;not null"`
	PetID       uint           `json:"pet_id" gorm:"index;not null"`
	Type        string         `json:"type" gorm:"size:32;not null"`
	Title       string         `json:"title" gorm:"size:128"`
	Note        string         `json:"note" gorm:"type:text"`
	Date        time.Time      `json:"date"`
	NextDueDate *time.Time     `json:"next_due_date"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`
}

func (HealthRecord) TableName() string {
	return "health_records"
}

type Order struct {
	ID        string    `json:"id" gorm:"primaryKey;size:64"`
	UserID    uint      `json:"user_id" gorm:"index;not null"`
	Amount    int64     `json:"amount"`
	Provider  string    `json:"provider" gorm:"size:20"`
	Status    string    `json:"status" gorm:"size:20"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (Order) TableName() string {
	return "orders"
}

type SyncRecord struct {
	ID         uint       `json:"id" gorm:"primaryKey"`
	UserID     uint       `json:"user_id" gorm:"index;not null"`
	RecordType string     `json:"record_type" gorm:"size:20;not null"`
	RecordID   string     `json:"record_id" gorm:"size:64;not null"`
	Action     string     `json:"action" gorm:"size:20;not null"`
	Data       string     `json:"data" gorm:"type:json"`
	SyncedAt   time.Time  `json:"synced_at"`
}

func (SyncRecord) TableName() string {
	return "sync_records"
}

type SMSCode struct {
	ID        uint       `json:"id" gorm:"primaryKey"`
	Phone     string     `json:"phone" gorm:"index:idx_phone_purpose;size:20;not null"`
	Code      string     `json:"code" gorm:"size:6;not null"`
	Purpose   string     `json:"purpose" gorm:"index:idx_phone_purpose;size:20;default:login"`
	ExpiresAt time.Time  `json:"expires_at" gorm:"not null"`
	UsedAt    *time.Time `json:"used_at"`
	CreatedAt time.Time  `json:"created_at"`
}

func (SMSCode) TableName() string {
	return "sms_codes"
}

type LoginLog struct {
	ID         uint      `json:"id" gorm:"primaryKey"`
	UserID     uint      `json:"user_id" gorm:"index;not null"`
	DeviceID   string    `json:"device_id" gorm:"size:64"`
	DeviceName string    `json:"device_name" gorm:"size:128"`
	DeviceType string    `json:"device_type" gorm:"size:20"`
	IPAddress  string    `json:"ip_address" gorm:"size:45"`
	LoginType  string    `json:"login_type" gorm:"size:20;default:phone"`
	Status     string    `json:"status" gorm:"size:20;default:success"`
	CreatedAt  time.Time `json:"created_at"`
}

func (LoginLog) TableName() string {
	return "login_logs"
}

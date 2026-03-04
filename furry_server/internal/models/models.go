package models

import "time"

type User struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	Phone        string    `json:"phone" gorm:"uniqueIndex;size:20;not null"`
	PasswordHash string    `json:"password_hash"`
	IsPro        bool      `json:"is_pro"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type Pet struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"index;not null"`
	Name      string    `json:"name" gorm:"size:64;not null"`
	Breed     string    `json:"breed"`
	Birthday  *time.Time `json:"birthday"`
	Gender    string    `json:"gender"`
	Color     string    `json:"color"`
	ChipNo    string    `json:"chip_no"`
	AvatarURL string    `json:"avatar_url"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type HealthRecord struct {
	ID          string     `json:"id" gorm:"primaryKey;size:64"`
	UserID      uint       `json:"user_id" gorm:"index;not null"`
	PetID       uint       `json:"pet_id" gorm:"index;not null"`
	Type        string     `json:"type" gorm:"size:32;not null"`
	Title       string     `json:"title"`
	Note        string     `json:"note"`
	Date        time.Time  `json:"date"`
	NextDueDate *time.Time `json:"next_due_date"`
	UpdatedAt   time.Time  `json:"updated_at"`
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

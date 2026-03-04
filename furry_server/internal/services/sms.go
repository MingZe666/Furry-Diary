package services

import "fmt"

type SMSProvider interface {
	SendCode(phone string, code string) error
}

type MockSMSProvider struct{}

func (MockSMSProvider) SendCode(phone string, code string) error {
	fmt.Printf("send sms to %s with code %s\n", phone, code)
	return nil
}

package storage

import "ApsaraLive/pkg/models"

type StorageAPI interface {
	GetRoomList(pageSize int, pageNum int) ([]string, error)

	CreateRoom(r *models.RoomInfo) error

	GetRoom(id string) (*models.RoomInfo, error)

	UpdateRoom(id string, r *models.RoomInfo) error

	DeleteRoom(id string) error
}

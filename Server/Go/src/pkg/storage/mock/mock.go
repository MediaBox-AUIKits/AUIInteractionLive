package mock

import (
	"encoding/json"
	"log"

	"ApsaraLive/pkg/alicloud/im"
	"ApsaraLive/pkg/models"
)

type MockDb struct {
	imSvr *im.LiveIMService
}

func NewMockDb(imSvr *im.LiveIMService) *MockDb {
	mockDb := &MockDb{imSvr}
	mockDb.imSvr = imSvr
	return mockDb
}

func (m *MockDb) CreateRoom(r *models.RoomInfo) error {
	return m.UpdateRoom(r.ChatId, r)
}

func (m *MockDb) GetRoomList(pageSize int, pageNum int) ([]string, error) {
	ids, err := m.imSvr.ListMessageGroup(pageSize, pageNum)
	return ids, err
}

func (m *MockDb) GetRoom(id string) (*models.RoomInfo, error) {
	var r models.RoomInfo
	jsonStr, err := m.imSvr.GetMessageGroup(id)
	if err != nil {
		return nil, err
	}

	if jsonStr != "" {
		err = json.Unmarshal([]byte(jsonStr), &r)
		if err != nil {
			log.Println()
		}
	}

	return &r, err
}

func (m *MockDb) UpdateRoom(id string, r *models.RoomInfo) error {
	jsonBytes, err := json.Marshal(r)
	if err != nil {
		return err
	}

	return m.imSvr.UpdateMessageGroup(r.ChatId, string(jsonBytes))
}

func (m *MockDb) DeleteRoom(id string) error {

	return nil
}

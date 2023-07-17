package _default

import (
	"fmt"

	"ApsaraLive/pkg/models"
)

func (l *LiveRoomManager) UpdateMeetingInfo(id string, members []models.MeetingMember) (*models.MeetingInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}

	if record.Mode != models.LiveModeLink {
		return nil, fmt.Errorf("unsupported live mode: %v", record.Mode)
	}

	meetingInfo := &models.MeetingInfo{}
	err = meetingInfo.ParseJsonString(record.MeetingInfo)
	if err != nil {
		return nil, err
	}

	meetingInfo.Members = members
	record.MeetingInfo, err = meetingInfo.ToJsonString()
	if err != nil {
		return nil, err
	}

	err = l.sa.UpdateRoom(id, record)
	if err != nil {
		return nil, nil
	}

	return meetingInfo, nil
}

func (l *LiveRoomManager) GetMeetingInfo(id string) (*models.MeetingInfo, error) {
	record, err := l.sa.GetRoom(id)
	if err != nil {
		return nil, err
	}

	if record.Mode != models.LiveModeLink {
		return nil, fmt.Errorf("unsupported live mode: %v", record.Mode)
	}

	meetingInfo := &models.MeetingInfo{}
	err = meetingInfo.ParseJsonString(record.MeetingInfo)
	if err != nil {
		return nil, err
	}

	return meetingInfo, nil
}

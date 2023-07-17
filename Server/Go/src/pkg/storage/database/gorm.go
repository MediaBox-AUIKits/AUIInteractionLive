package database

import (
	"fmt"

	"ApsaraLive/pkg/models"
	"github.com/glebarez/sqlite"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

type GormDb struct {
	db *gorm.DB
}

func NewGormDb(driver string, dsn string) (*GormDb, error) {
	g := &GormDb{}
	var err error

	if driver == "sqlite3" {
		g.db, err = gorm.Open(sqlite.Open(dsn), &gorm.Config{})
	} else {
		g.db, err = gorm.Open(mysql.New(mysql.Config{
			DSN:                       dsn,   // DSN data source name
			DefaultStringSize:         256,   // string 类型字段的默认长度
			DisableDatetimePrecision:  true,  // 禁用 datetime 精度，MySQL 5.6 之前的数据库不支持
			DontSupportRenameIndex:    true,  // 重命名索引时采用删除并新建的方式，MySQL 5.7 之前的数据库和 MariaDB 不支持重命名索引
			DontSupportRenameColumn:   true,  // 用 `change` 重命名列，MySQL 8 之前的数据库和 MariaDB 不支持重命名列
			SkipInitializeWithVersion: false, // 根据当前 MySQL 版本自动配置
		}), &gorm.Config{})
	}

	if err != nil {
		return nil, err
	}

	err = g.db.AutoMigrate(&models.RoomInfo{})

	return g, err
}

func (g *GormDb) CreateRoom(r *models.RoomInfo) error {
	rst := g.db.Create(r)

	return rst.Error
}

func (g *GormDb) GetRoomList(pageSize int, pageNum int) ([]string, error) {
	offset := (pageNum - 1) * pageSize
	var rooms []models.RoomInfo
	if err := g.db.Order("created_at desc").Limit(pageSize).Offset(offset).Find(&rooms).Error; err != nil {
		return nil, fmt.Errorf("limit failed. %w", err)
	}
	var ids []string
	for _, item := range rooms {
		ids = append(ids, item.ID)
	}

	return ids, nil
}

func (g *GormDb) GetRoom(id string) (*models.RoomInfo, error) {
	var r models.RoomInfo
	rst := g.db.Where("id = ?", id).First(&r)
	if rst.Error != nil {

		return &r, fmt.Errorf("get record failed. %w", rst.Error)
	}

	return &r, nil
}

func (g *GormDb) UpdateRoom(id string, r *models.RoomInfo) error {
	rst := g.db.Where("id = ?", id).Updates(r)

	return rst.Error
}

func (g *GormDb) DeleteRoom(id string) error {
	return g.db.Delete(id).Error
}

// 上一场直播id储存在 localstorage 中的 key
export const LatestLiveidStorageKey = 'aliyun_interaction_latest_liveid';

// 直播间类型储存 localstorage 中的 key
export const LiveRoomTypeStorageKey = 'aui-liveroom-type';

// 旧IM sdk的 device_id不存在，会生成一个uuid存入localstorage，作为终端设备ID，唯一代表一个用户终端设备。
export const IMDeviceIdStorageKey = 'im-device-id';

// 当前项目并无真实用户系统，所以使用随机的默认头像
export const DefaultAvatars = [
  'https://img.alicdn.com/imgextra/i1/O1CN01chynzk1uKkiHiQIvE_!!6000000006019-2-tps-80-80.png',
  'https://img.alicdn.com/imgextra/i4/O1CN01kpUDlF1sEgEJMKHH8_!!6000000005735-2-tps-80-80.png',
  'https://img.alicdn.com/imgextra/i4/O1CN01ES6H0u21ObLta9mAF_!!6000000006975-2-tps-80-80.png',
  'https://img.alicdn.com/imgextra/i1/O1CN01KWVPkd1Q9omnAnzAL_!!6000000001934-2-tps-80-80.png',
  'https://img.alicdn.com/imgextra/i1/O1CN01P6zzLk1muv3zymjjD_!!6000000005015-2-tps-80-80.png',
  'https://img.alicdn.com/imgextra/i2/O1CN01ZDasLb1Ca0ogtITHO_!!6000000000096-2-tps-80-80.png',
];

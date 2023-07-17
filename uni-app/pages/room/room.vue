<template>
	<page-meta :root-font-size="fontSize+'px'"></page-meta>
	<view>
		<liveroom :joined-group-id="joinedGroupId" />
	</view>
</template>

<script>
	import { InteractionEngine } from  '@/utils/aliyun-interaction-sdk.mini.js';
	import rootFontSize from '@/mixins/rootFontSize.js';
	import { LatestLiveidStorageKey } from '@/utils/constants.js';
	import services from '@/utils/services.js';
	import { convertToCamel } from '@/utils/common.js';
	import Liveroom from '@/components/liveroom/liveroom.vue';
	
	export default {
		components: {
			Liveroom,
		},
		
		mixins: [rootFontSize],
		
		data() {
			return {
				interaction: null,
				fetching: false,
				liveId: '',
				joinedGroupId: '', // 已加入的消息组id
			};
		},
		
		created() {
			// 每次进入重新创建互动消息实例，并更新 globalData 中的数据
			const ins = InteractionEngine.create();
			getApp().globalData.interaction = ins;
			this.interaction = ins;
		},
		
		onLoad(query) {
			if (!query.liveId) {
				uni.redirectTo({
					url: '/pages/roomList/roomList',
				});
				return;
			}
			
			this.fetchRoomDetail(query.liveId);
		},
		
		// 自定义分享内容
		onShareAppMessage(res) {
			console.log('来源', res.from);
			return {
				title: 'AUI自定义分享标题',
				path: 'pages/index/index'
			}
		},
		
		onShow() {
			// #ifdef MP-ALIPAY
			my.hideBackHome();
			// #endif
		},
		
		onUnload() {
			this.$store.commit('liveroom/reset');
			this.interaction.logout();
		},
		
		methods: {
			fetchRoomDetail(roomId) {
				if (this.fetching) {
					return;
				}
				uni.showLoading({
					title: '直播间数据加载中...',
				});
				this.fetching = true;
				
				services
					.getRoomDetail(roomId)
					.then((res) => {
						const data = convertToCamel(res);
						console.log('detail-->', data);
						this.$store.commit('liveroom/updateInfo', data);
						// 缓存当前直播间id
						uni.setStorage({
							key: LatestLiveidStorageKey,
							data: roomId,
						});
						
						this.initInteraction(data.chatId);
					})
					.catch(() => {
						uni.showToast({
							title: '直播间加载失败',
							icon: 'error',
						});
					})
					.finally(() => {
						uni.hideLoading();
						this.fetching = false;
					});
			},
			
			async initInteraction(groupId) {
				try{
					// 获取token
					const token = await services.getToken();
					console.log(token);
					// im 服务认证
					await this.interaction.auth(token.access_token);
					// 加入房间
					const userData = services.getUserInfo();
					await this.interaction.joinGroup({
						groupId,
						userNick: userData.userName,
						userAvatar: '', // 随机取头像
						broadCastType: 2, // 广播所有人
						broadCastStatistics: true,
					});
					this.joinedGroupId = groupId;
					
					// 检查更新自己信息
					this.updateSelfInfo();
					// 更新直播统计数据
					this.updateGroupStatistics();
				}catch(e){
					console.log('加入消息组失败', e);
				}
			},
			
			updateSelfInfo() {
			    const userData = services.getUserInfo();
			    this.interaction.getGroupUserByIdList({
					groupId: this.joinedGroupId,
					userIdList: [userData.userId],
			    }).then((res) => {
					const info = ((res || {}).userList || [])[0];
					if (info) {
						const muteBy = info.muteBy || [];
						this.$store.commit('liveroom/updateInfo', {
							selfMuted: muteBy.includes('user'),
							groupMuted: muteBy.includes('group'),
						});
					}
			    });
			},
			
			updateGroupStatistics() {
			    this.interaction.getGroupStatistics({
					groupId: this.joinedGroupId,
				})
				.then((res) => {
					this.$store.commit('liveroom/updateMetrics', {
						pv: res.pv,
						uv: res.uv,
						likeCount: res.likeCount,
						onlineCount: res.onlineCount,
					});
				})
				.catch(() => {});
			},
		},
	}
</script>

<style lang="scss">

</style>

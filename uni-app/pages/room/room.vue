<template>
	<page-meta :root-font-size="fontSize+'px'"></page-meta>
	<view
		:style="{
			width: windowWidth,
			height: windowHeight,
		}"
	>
		<liveroom :joined-group-id="joinedGroupId" />
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { 
		ImEngine, 
		// ImLogLevel
	} from '@/utils/Interaction.js';
	import rootFontSize from '@/mixins/rootFontSize.js';
	import { 
		LatestLiveidStorageKey,
		CustomMessageTypes,
		InteractionMessageTypes,
		RoomStatus
	} from '@/utils/constants.js';
	import services from '@/utils/services.js';
	import { convertToCamel, throttle } from '@/utils/common.js';
	import Liveroom from '@/components/liveroom/liveroom.vue';
	
	export default {
		components: {
			Liveroom,
		},
		
		mixins: [rootFontSize],
		
		data() {
			return {
				fetching: false,
				liveId: '',
				joinedGroupId: '', // 已加入的消息组id
				windowHeight: '100%',
				windowWidth: '100%',
			};
		},

		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
		},
		
		created() {
			// 每次进入重新创建互动消息实例，并更新 globalData 中的数据
			const res = uni.getSystemInfoSync();
			this.windowHeight = res.windowHeight + 'px';
			this.windowWidth = res.windowWidth + 'px';
			const engine = ImEngine.createEngine();
			getApp().globalData.interaction = engine;
			this.interaction = engine;
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
		
		async onUnload() {
			this.$store.commit('liveroom/reset');
			await this.interaction.logout();
			this.interaction.unInit();
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
				try {
					// 获取token， 用户为主播时，才有阿里云新版IM admin管理员权限
					const userInfo = services.getUserInfo();
					const role = this.roomInfo?.anchorId === userInfo.userId ? 
						'admin' : undefined;
					const { 
						aliyunIMV2: tokenConfig
					} = await services.getToken(['aliyun_new'], role);
					await this.interaction.init({
						deviceId: 'uniapp',    // 设备ID，可选传入
						appId: tokenConfig?.appId,     // 开通应用后可以在控制台上拷贝
						appSign: tokenConfig?.appSign, // 开通应用后可以在控制台上拷贝
						// logLevel: ImLogLevel.ERROR,  // 日志级别，调试时使用 ImLogLevel.DBUG
						// 指定引入的 wasm 的地址
						locateFile: (url) => {
							if (url.endsWith('.wasm')) {
								return '/static/mp-weixin/alivc-im.wasm.br';
							}
							return url;
						},
					});
					await this.interaction.login({
						user: {
							userId: userInfo?.userId,
							userExtension: JSON.stringify({
								userNick: userInfo?.userName,
								userAvatar: userInfo?.userAvatar,
							}),
						},
						userAuth: {
							nonce: tokenConfig?.auth.nonce,
							timestamp: tokenConfig?.auth.timestamp,
							role: tokenConfig?.auth.role,
							token: tokenConfig?.appToken,
						},
					});

					const groupInfo = 
						await this.interaction?.getGroupManager()?.joinGroup(groupId);
					const { statistics, muteStatus } = groupInfo;
					this.$store.commit('liveroom/updateInfo', {
						groupMuted: muteStatus?.muteAll,
						imReady: true,
					});
					this.$store.commit('liveroom/updateMetrics', {
						pv: statistics?.pv,
						onlineCount: statistics?.onlineCount,
					});

					this.listenInteraction();
					this.joinedGroupId = groupId;
				} catch (e) {
					console.log('加入消息组失败', e);
					uni.showToast({
						title: '加入消息组失败',
						icon: 'error',
					});
				}
			},

			async listenInteraction() {
				const messageManager = this.interaction?.getMessageManager();
				messageManager?.on("recvc2cmessage", (eventData) => {
					this.handleReceivedMessage(eventData || {});
				});
				messageManager?.on("recvgroupmessage", (eventData) => {
					this.handleReceivedMessage(eventData || {});
				});
				
				this.handleUserJoined = throttle(this.handleUserJoined, 1500);
			},

			handleReceivedMessage(eventData) {
				const { type, data: _data, messageId, sender = {} } = eventData || {};
				console.log('收到消息了', eventData);
				let data = _data && JSON.parse(_data || '{}');
				const nickName = sender.userNick ?? sender.userId;

				switch (type){
					case CustomMessageTypes.LiveStart:
						// 直播开始
						this.$store.commit('liveroom/updateInfo', {
							status: RoomStatus.started,
						});
						break;
					case CustomMessageTypes.LiveStop:
						// 直播结束
						this.$store.commit('liveroom/updateInfo', {
							status: RoomStatus.ended,
						});
						break;
					default:
						break;
				}
			},
		},
	}
</script>

<style lang="scss">
</style>

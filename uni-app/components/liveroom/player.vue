<template>
	<view class="player-wrap">
		<view v-if="!isPlayback && !isLiving" class="liveroom-status-text">
			<view>{{ statusText }}</view>
			<view
				v-if="allowPlayback"
				class="player-playback"
				@click="playback"
			>
				观看回放
			</view>
		</view>
		
		<video
			v-if="vodUrl"
			id="vodVideo"
			:src="vodUrl"
			:autoplay="true"
			:show-fullscreen-btn="false"
			:show-center-play-btn="true"
			:play-btn-position="playBtnPosition"
			class="player-object"
			@controlstoggle="controlstoggle"
			@error="handleVideoError"
		></video>
		
		<live-player
			v-if="liveUrl"
			:src="liveUrl"
			autoplay
			class="player-object"
		></live-player>
		<!-- 使用 video 播 hls 模拟 live-player -->
		<!-- <video
			v-if="liveUrl"
			:src="liveUrl"
			autoplay
			:controls="false"
			class="player-object"
		></video> -->
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { replaceHttps } from '@/utils/common.js';
	import { RoomStatus, CustomMessageTypes, RoomModeMap } from '@/utils/constants.js';
	import { InteractionEventNames, InteractionMessageTypes } from  '@/utils/aliyun-interaction-sdk.mini.js';
	
	export default {
		name: "player",
		props: {
			isPlayback: {
				type: Boolean,
				default: false,
			},
		},
		data() {
			return {
				vodUrl: '', // 回看url
				liveUrl: '', // 直播url
				osName: '',
			};
		},
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
			pullUrlInfo() {
				let ret = {}
				if (this.roomInfo.mode === RoomModeMap.normal) {
					ret = this.roomInfo.pullUrlInfo || {};
				} else if (this.roomInfo.mode === RoomModeMap.rtc) {
					// 连麦模式得用 linkInfo 下的拉流地址
					ret = this.roomInfo.linkInfo.cdnPullInfo || {};
				}
				return ret;
			},
			isLiving() {
				return this.roomInfo.status === RoomStatus.started;
			},
			statusText() {
				const map = {
					'-1': '正在进入直播间',
					0: '直播尚未开始~',
					2: '直播已结束~',
				};
				return map[this.roomInfo.status] || '';
			},
			allowPlayback() {
				const status = this.roomInfo.status;
				const vodInfo = this.roomInfo.vodInfo;
				if (
					status === RoomStatus.ended
					&& vodInfo
					&& vodInfo.status === 1
					&& vodInfo.playlist[0]
					&& vodInfo.playlist[0].playUrl
				) {
					return true;
				}
				return false;
			},
			playBtnPosition() {
				return ['windows', 'macos'].includes(this.osName) ? 'bottom' : 'center';
			}
		},
		created() {
			this.interaction = getApp().globalData.interaction;
			this.interaction.on(InteractionEventNames.Message, (eventData) => {
			    this.handleReceivedMessage(eventData || {});
			});
		},
		mounted() {
			const _this = this;
			uni.getSystemInfo({
				success(res) {
					_this.osName = res.osName;
				}
			});
		},
		watch: {
			isLiving(bool) {
				if (bool === true) {
					this.liveUrl = this.pullUrlInfo.rtmpUrl;
					// 若用 video 播 hls 格式来模拟时，打开下方代码，注释上一条代码，并对应操作 template 里的代码
					// this.liveUrl = this.pullUrlInfo.hlsOriaacUrl || this.pullUrlInfo.hlsUrl;
				} else{
					this.liveUrl = '';
				}
			}
		},
		methods: {
			playback() {
				const vodInfo = this.roomInfo.vodInfo;
				if (!vodInfo || this.isPlayback) {
					return;
				}
				this.$emit('update-is-playback', true);
				this.vodUrl = vodInfo.playlist[0].playUrl;
			},
			controlstoggle(event) {
				// pc 平台微信小程序 video 元素控制条出现的条件与移动端不一致
				// 移动端是点击 video 元素出现控制条，几秒后自动隐藏
				// 但 pc 是鼠标进入video元素即 mouseenter 就显示，mouseleave 就消失
				// 所以 pc 上鼠标移入叠在视频上的其他控件时就会触发 controlstoggle hidden ，带动其他控件也消失
				// 一旦其他控件消失，鼠标又进入了 video 元素，有触发 controlstoggle visible，其他控件也跟着展示
				// 从而就一直在闪，要彻底解决只能自定义控制条
				// 所以本期 pc 平台不做沉浸式播放
				if (['windows', 'macos'].includes(this.osName)) {
					return;
				}
				this.$emit('controlstoggle', event.detail.show);
			},
			handleVideoError(err) {
				console.log(err);
			},
			// 互动消息处理
			handleReceivedMessage(eventData) {
				const { type, data, messageId, senderId, senderInfo = {} } = eventData || {};
				const nickName = senderInfo.userNick || senderId;
				
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
			}
		},
	};
</script>

<style lang="scss">
	@import 'player.scss';
</style>
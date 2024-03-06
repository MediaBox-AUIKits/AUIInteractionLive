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
		
		<!-- #ifdef MP-WEIXIN -->
		<wx-player
			:is-playback="isPlayback"
			:is-living="isLiving"
			:vod-info="vodInfo"
			:pull-url-info="pullUrlInfo"
			@controlstoggle="controlsToggle"
		/>
		<!-- #endif -->
		
		<!-- #ifdef H5 -->
		<h5-player
			:is-playback="isPlayback"
			:is-living="isLiving"
			:vod-info="vodInfo"
			:pull-url-info="pullUrlInfo"
			@controlstoggle="controlsToggle"
		/>
		<!-- #endif -->
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { RoomStatus, RoomModeMap } from '@/utils/constants.js';
	import WxPlayer from './wxPlayer.vue';
	import H5Player from './h5Player/index.vue';
	
	export default {
		name: "player",
		components: {
			WxPlayer,
			H5Player,
		},
		props: {
			isPlayback: {
				type: Boolean,
				default: false,
			},
		},
		data() {
			return {
				vodInfo: undefined, // 回看数据
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
		},
		methods: {
			playback() {
				const vodInfo = this.roomInfo.vodInfo;
				if (!vodInfo || this.isPlayback) {
					return;
				}
				// 当前例子直播回看使用第一个播放地址，可根据您业务调整
				this.vodInfo = vodInfo.playlist[0];
				this.$emit('update-is-playback', true);
			},
			controlsToggle(bool) {
				this.$emit('controlstoggle', bool);
			},
		},
	};
</script>

<style lang="scss">
	@import 'player.scss';
</style>
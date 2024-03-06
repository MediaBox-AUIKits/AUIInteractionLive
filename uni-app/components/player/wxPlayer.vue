<template>
	<!-- 小程序 player 组件 -->
	<view class="player-object">
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
	export default {
		name: 'wxPlayer',
		props: {
			isPlayback: {
				type: Boolean,
				default: false,
			},
			isLiving: {
				type: Boolean,
				default: false,
			},
			pullUrlInfo: {
				type: Object,
				default: () => ({
					rtmpUrl: '',
					rtmpOriaacUrl: '',
					hlsOriaacUrl: '',
					hlsUrl: '',
				}),
			},
			vodInfo: {
				type: Object,
				default: () => ({
					playUrl: '',
					format: '',
				}),
			},
		},
		data() {
			return {
				liveUrl: '', // 直播url
				osName: '',
			};
		},
		computed: {
			playBtnPosition() {
				return ['windows', 'macos'].includes(this.osName) ? 'bottom' : 'center';
			},
			vodUrl() {
				return this.vodInfo ? this.vodInfo.playUrl : '';
			},
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
		}
	}
</script>

<style>
	.player-object {
		width: 100%;
		height: 100%;
	}
</style>
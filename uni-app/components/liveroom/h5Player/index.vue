<template>
	<view :class="['player-object', {'prism-ErrorMessage-hidden': errorDisplayVisible}]" id="h5player">
	</view>
</template>

<script>
	import { H5Player } from './H5Player';
	import { replaceHttps } from '@/utils/common.js';

	export default {
		name: 'H5Player',
		
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
					hlsOriaacUrl: '',
					hlsUrl: '',
					rtsUrl: '',
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
				player: new H5Player(),
				errorDisplayVisible: true,
			}
		},
		
		mounted() {
			//
		},
		
		beforeDestroy() {
			this.player.destroy();
		},
		watch: {
			isLiving(bool) {
				if (bool === true) {
					this.playLive();
				} else{
					this.player.destroy();
				}
			},
			isPlayback(bool) {
				if (bool) {
					this.playBack();
				}
			},
		},
		methods: {
			playLive() {
				const { hlsOriaacUrl, hlsUrl, rtsUrl } = this.pullUrlInfo;
				let rtsFallbackSource = hlsOriaacUrl || hlsUrl;
				let source = rtsUrl || rtsFallbackSource;
				if (window.location.protocol === 'https:' && (new URL(rtsFallbackSource)).protocol === 'http:') {
					rtsFallbackSource = replaceHttps(rtsFallbackSource) || '';
					source = replaceHttps(source) || '';
				}
				const controlBarVisibility = 'never';
				
				this.player.play({
					source,
					rtsFallbackSource,
					controlBarVisibility,
				});
				
				this.listenPlayerEvents();
				
				// 若未开播就进去直播间，等到开播后如果加载 hls 流，很大可能流内容未准备好，就会加载失败
				// 虽然 H5Player.ts中有自动重新加载的逻辑，但不想这时展示错误提示
				// 所以先通过 css 隐藏，10 秒后若还是有错误提示就展示
				setTimeout(() => {
					this.errorDisplayVisible = false;
				}, 10000);
			},
			
			playBack() {
				let source = this.vodInfo.playUrl || '';
				if (window.location.protocol === 'https:' && (new URL(source)).protocol === 'http:') {
				    source = replaceHttps(source);
				}
				
				this.player.playback({
					source,
					format: this.vodInfo.format,
				});
				
				this.listenPlayerEvents();
			},
			
			listenPlayerEvents() {
				this.player.on('pause', () => {
					// ios 中退出全屏会自动暂停，但这时不会出现居中的播放 ICON，所以主动调一次暂停，触发展示
					this.player.pause();
				});
				this.player.on('error', (err) => {
				    console.log(err);
				});
				this.player.on('hideBar', () => {
				    this.$emit('controlstoggle', false);
				});
				this.player.on('showBar', () => {
					this.$emit('controlstoggle', true);
				});
			}
		},
	}
</script>

<style lang="scss">
	.player-object {
		width: 100%;
		height: 100%;
		/deep/ {
			.prism-progress .prism-progress-played {
				background-color: #FF5722;
			}
			.prism-progress .prism-progress-cursor {
			    display: block !important; // 移动端很难触发hover事件，所以强制都展示
			    background-image: none;
			    background-color: #fff;
			    border-radius: 50%;
				width: 12px;
				height: 12px;
			    top: -3px !important;
			
			    img {
					display: none;
			    }
			}
			.prism-loading .circle {
			    border-color: rgba(255,87,34,.2) rgba(255,87,34,.5) rgba(255,87,34,.7) rgba(255,87,34,.1);
			}
			.prism-error-operation .prism-button {
				font-size: 12px;
			}
		}
	}
	.prism-ErrorMessage-hidden {
		/deep/ .prism-ErrorMessage {
		    display: none !important;
		}
	}
</style>
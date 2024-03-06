<template>
	<view :class="['player-object', {'prism-ErrorMessage-hidden': errorDisplayVisible}]">
		<view id="h5player"></view>
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
					flvOriaacUrl: '',
					flvUrl: '',
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
				errorDisplayVisible: true,
			}
		},
		
		created() {
			this.player = new H5Player();
		},
		
		mounted() {
			if (uni && uni.getSystemInfoSync) {
				this.isIOS = uni.getSystemInfoSync().platform === 'ios';
			} else{
				this.isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
			}
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
			// 获取直播流地址
			getLiveSource(excludeFlv = false, excludeRts = false) {
				// hlsOriaacUrl 为模板转码流，请参考 https://help.aliyun.com/document_detail/2402111.html?spm=a2c4g.2401427.0.0.47b377b9UomvbA#section-h5o-tza-bo3  配置模板
				// 若非开播小助手推流，可以删掉 hlsOriaacUrl 的逻辑
				// 若是开播小助手推流，不配置转码，观看端直播流将会无声音
				const { hlsOriaacUrl, hlsUrl, flvOriaacUrl, flvUrl, rtsUrl } = this.pullUrlInfo;
				// 因为目前 ios 设备不支持 FLV 因此若是 ios 直接使用 HLS
				let rtsFallbackSource = hlsOriaacUrl || hlsUrl;
				if (!this.isIOS && !excludeFlv) {
					rtsFallbackSource = flvOriaacUrl || flvUrl;
				}
				let source = '';
				if (excludeRts) {
					source = rtsFallbackSource;
					rtsFallbackSource = '';
				} else {
					source = rtsUrl || rtsFallbackSource;
				}
				if (window.location.protocol === 'https:' && (new URL(rtsFallbackSource)).protocol === 'http:') {
					rtsFallbackSource = replaceHttps(rtsFallbackSource) || '';
					source = replaceHttps(source) || '';
				}
				return { source, rtsFallbackSource };
			},
			
			playLive(excludeFlv = false) {
				const { source, rtsFallbackSource } = this.getLiveSource(excludeFlv);
				const controlBarVisibility = 'never';
				
				this.player.play({
					source,
					rtsFallbackSource,
					controlBarVisibility,
					useFlvPlugOnMobile: !excludeFlv,
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
			
			hanldePlayerError(e) {
				if (
					e &&
					e.paramData &&
					e.paramData.error_code === 4011 &&
					typeof e.paramData.error_msg === 'string' &&
					e.paramData.error_msg.indexOf('format:flv')
				) {
					console.log('4011 err ->', e);
					// 若错误码是 4011 且尝试播放 HLS
					if (this.isLiving) {
						// 目前只处理直播模式，因为点播返回一般都是 m3u8，不需要判断
						this.player.destroy();
						this.playLive(true);
					}
				}
			},
			
			listenPlayerEvents() {
				this.player.on('ready', () => {
					const dom = document.querySelector('#h5player video');
					if (dom) {
						dom.classList.add('custom-video');
					}
				});
				this.player.on('pause', () => {
					// ios 中退出全屏会自动暂停，但这时不会出现居中的播放 ICON，所以主动调一次暂停，触发展示
					this.player.pause();
				});
				this.player.on('error', this.hanldePlayerError);
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

<style lang="scss" scoped>
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
			.custom-video {
				/* 修改video元素的样式，若想撑满整个区域可以使用 cover */
				object-fit: contain;
			}
		}
	}
	.prism-ErrorMessage-hidden {
		/deep/ .prism-ErrorMessage {
		    display: none !important;
		}
	}
</style>
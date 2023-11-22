<template>
	<view class="room-item-wrap">
		<view
			class="room-item"
			:style="backgroundStyle"
			@click="gotoLiveroom"
		>
			<view class="room-item-top">
				<view :class="['room-item-top-icon', statusIcon]"></view>
				<view class="room-item-top-data">
					{{ pvText }} 观看
				</view>
			</view>
			<view class="room-item-bottom">
				<view class="room-item-title">{{ info.title }}</view>
				<view class="room-item-id">{{ extensionObj.userNick || info.anchor_id }}</view>
			</view>
		</view>
	</view>
</template>

<script>
	import { RoomStatusMap } from '@/utils/constants.js';
	export default {
		props: {
			info: {
				type: Object,
				default: function() {
					return {}
				}
			},
		},
		
		computed: {
			pvText() {
				const pv = (this.info.metrics && this.info.metrics.pv) || 0;
				if (pv > 10000) {
				  // 若需要国际化，这里得区分地域，比如 14000 国外格式化为 14K
				  return (pv / 10000).toFixed(1) + 'w';
				}
				return pv;
			},
			extensionObj() {
				let ret = {};
				if (this.info.extends) {
				  try {
					ret = JSON.parse(this.info.extends);
				  } catch (error) {
					console.log('info.extends 解析失败！', error);
				  }
				}
				return ret;
			},
			statusIcon() {
				if (this.info.status === RoomStatusMap.Stopped) {
					return 'auiicon-Playback';
				}
				return 'auiicon-Live';
			},
			backgroundStyle() {
				if (!this.info.coverUrl) {
					return '';
				}
				return `background-image: url('${this.info.coverUrl}')`;
			}
		},
		
		methods: {
			gotoLiveroom() {
				if (this.info && this.info.id) {
					uni.redirectTo({
						url: `/pages/room/room?liveId=${this.info.id}`,
					});
				}
			},
		},
	};
</script>

<style lang="scss">
	@import './roomItem.scss';
</style>
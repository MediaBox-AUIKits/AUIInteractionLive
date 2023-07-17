<template>
	<view
		class="banner-wrap"
		:style="{
			display: visible ? 'block' : 'none',
			top: bannerTop + 'px',
		}"
	>
		<view
			class="info-row"
			:style="{ paddingRight: '80px' }"
		>
			<view class="close-btn" @click="gotoRoomList">
				<view class="auiicon-LeftOutline"></view>
			</view>
			<view class="info-block">
				<view
					class="info-avatar"
					:style="{ backgroundImage: 'url(' + avatar +')' }"
				>
				</view>
				<view class="info-title-wrap">
					<view class="info-title">
						{{ roomInfo.title || '' }}
					</view>
					<view class="info-name">
						{{ extendsInfo.userNick || roomInfo.anchorId || '' }}
					</view>
				</view>
				<view class="info-follow-btn" @click="follow">
					关注
				</view>
			</view>
		</view>
		<view class="info-row">
			<view class="info-notice" @click="toggleNotice">
				<view class="info-notice-header">
					公告
					<view
						class="auiicon-LeftOutline info-notice-arrow"
						:style="{ transform: 'rotate(' + (noticeVisible ? '' : '-') + '90deg)' }"
					></view>
				</view>
				<view v-if="noticeVisible" class="info-notice-content">
					{{ roomInfo.notice || '暂无公告' }}
				</view>
			</view>
			<view class="info-audience">
				{{ pvText }}
			</view>
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex' 
	export default {
		name:"banner",
		
		props: {
			visible: {
				type: Boolean,
				default: true,
			},
		},
		
		data() {
			return {
				bannerTop: 40,
				noticeVisible: false,
			};
		},
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
				extendsInfo: 'liveroom/extendsInfo',
			}),
			avatar() {
				return this.extendsInfo.userAvatar || 'https://img.alicdn.com/imgextra/i4/O1CN01BQZKz41EGtPZp3U5P_!!6000000000325-2-tps-1160-1108.png';
			},
			pvText() {
				const metrics = this.roomInfo.metrics || {};
				const pv = metrics.pv || 0;
				if (pv >= 10000) {
					const num = pv / 10000;
					return `${num.toFixed(1)}W`;
				}
				return pv;
			},
		},
		
		created() {
			// #ifdef MP
			this.getMenuPosition();
			// #endif
		},
		
		methods: {
			getMenuPosition() {
				const res = uni.getMenuButtonBoundingClientRect();
				this.bannerTop = res.top;
			},
			
			gotoRoomList() {
				uni.redirectTo({
					url: '/pages/roomList/roomList',
				});
			},
			
			toggleNotice() {
				this.noticeVisible = !this.noticeVisible;
			},
			
			follow() {
				// 需要您自行实现
				uni.showToast({
					title: '关注逻辑需要您自行实现',
					icon: 'none',
				});
			},
		},
	}
</script>

<style lang="scss">
	@import 'banner.scss';
</style>
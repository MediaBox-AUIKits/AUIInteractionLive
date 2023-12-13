<template>
	<page-meta :root-font-size="fontSize+'px'"></page-meta>
	<view class="room-list-page">
		<view
			class="room-list-header"
			:style="[headerStyles]"
		>
			<view class="room-list-header-content">
				<view class="auiicon-LeftOutline room-list-header-back" @click="goBack"></view>
				直播间列表
			</view>
		</view>
		<scroll-view
			class="scroll-list"
			:style="[scrollListStyles]"
			:refresher-enabled="true"
			:scroll-y="true"
			:refresher-threshold="100"
			:refresher-triggered="triggered"
			@refresherrefresh="onRefresh"
		>
			<view class="room-list-content">
				<room-item
					v-for="item in roomList"
					:key="item.id"
					:info="item"
				/>
			</view>
		</scroll-view>
		<view v-if="lastLiveid" class="room-list-last" @click="gotoLastLive">
			上场直播
			<view class="auiicon-LeftOutline"></view>
		</view>
		<view v-if="emptyVisible" class="room-list-empty">
			暂无直播
		</view>
	</view>
</template>

<script>
	import rootFontSize from '@/mixins/rootFontSize.js';
	import RoomItem from './roomItem.vue';
	import services from '@/utils/services.js';
	import { LatestLiveidStorageKey } from '@/utils/constants.js';
	export default {
		components: {
			RoomItem,
		},
		
		mixins: [rootFontSize],
		
		data() {
			return {
				triggered: false,
				fetching: false,
				roomList: [],
				headerPaddingTop: 0,
				headerHeight: 40, // 注意：和 css 中的高度保持一致
				lastLiveid: '',
			};
		},
		
		onLoad() {
			// #ifdef MP-WEIXIN
			this.getMenuPosition();
			// #endif
			// #ifdef MP-ALIPAY
			this.handleAlipay();
			// #endif
			
			// 获取上场直播id
			uni.getStorage({
				key: LatestLiveidStorageKey,
				success: (res) => {
					if (res.data) {
						this.lastLiveid = res.data;
					}
				},
			});
			
			// 获取直播间列表
			this.fetchRoomList();
		},
		
		onShow() {
			// #ifdef MP-ALIPAY
			my.hideBackHome();
			// #endif
		},
		
		computed: {
			emptyVisible() {
				return this.roomList.length === 0 && !this.fetching;
			},
			headerStyles() {
				const styles = {
					lineHeight: `${this.headerHeight}px`,
					height: `${this.headerHeight}px`,
				};
				if (this.headerPaddingTop) {
					styles.paddingTop = `${this.headerPaddingTop}px`;
				}
				return styles;
			},
			scrollListStyles() {
				return {
					height: `calc(100% - ${this.headerHeight}px)`,
				};
			},
		},
		
		methods: {
			getMenuPosition() {
				const res = uni.getMenuButtonBoundingClientRect();
				this.headerPaddingTop = res.top - 4;
				this.headerHeight = res.bottom - res.top + 8; // 增加4px，优化体验
			},
			
			handleAlipay() {
				const _this = this;
				uni.getSystemInfo({
					success(res) {
						_this.headerHeight = res.statusBarHeight + res.titleBarHeight - 8;
					}
				});
			},
			
			goBack() {
				uni.navigateTo({
					url: '/pages/index/index',
				});
			},
			
			gotoLastLive() {
				if (this.lastLiveid) {
					uni.redirectTo({
						url: `/pages/room/room?liveId=${this.lastLiveid}`,
					});
				}
			},
			
			fetchRoomList() {
				if (this.fetching) {
					return;
				}
				uni.showLoading({
					title: '直播间列表加载中'
				});
				this.fetching = true;
				services
					.getRoomList(1, 20)
					.then((res) => {
						console.log('list-->', res);
						if (Array.isArray(res)) {
							this.roomList = res;
						}
					})
					.catch((err) => {
						console.log('err->', err);
						uni.showToast({
							title: '获取列表失败',
							icon: 'error',
						});
					})
					.finally(() => {
						this.triggered = false;
						this.fetching = false;
						uni.hideLoading();
					});
			},
			
			onRefresh() {
				this.triggered = true;
				this.fetchRoomList();
			},
		}
	}
</script>

<style lang="scss">
@import './roomList.scss';
</style>

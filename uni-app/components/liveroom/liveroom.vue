<template>
	<view class="liveroom-wrap">
		<player
			:is-playback="isPlayback"
			@update-is-playback="updateIsPlayback"
			@controlstoggle="controlstoggle"
		/>
		<banner :visible="pluginVisible" />
		<chat-box
			:visible="pluginVisible"
			:is-playback="isPlayback"
			:joined-group-id="joinedGroupId"
		/>
	</view>
</template>

<script>
	import Banner from './banner.vue';
	import ChatBox from './chatBox.vue';
	import Player from './player.vue';
	
	export default {
		name:"liveroom",
		
		components: {
			Banner,
			ChatBox,
			Player,
		},
		
		props: {
			joinedGroupId: {
				type: String,
				default: '',
			},
		},
		
		data() {
			return {
				isPlayback: false,
				// 点播情况下是否显示控制条，不显示时其他组件也不显示，要沉浸式播放
				// 默认是 true
				pluginVisible: true,
			};
		},
		
		methods: {
			updateIsPlayback(bool) {
				this.isPlayback = bool;
			},
			controlstoggle(bool) {
				this.pluginVisible = bool;
			},
		},
	}
</script>

<style lang="scss">
@import 'base.scss';
.liveroom-wrap {
	position: relative;
	width: 100vw;
	height: 100vh;
	color: $info-text-color;
	background-image: $room-background;
}
</style>
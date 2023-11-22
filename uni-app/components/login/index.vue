<template>
	<view class="login-page">
		<view class="login-form">
			<image class="logo" src="https://img.alicdn.com/imgextra/i1/O1CN01i8XGei1UJflU9uYSW_!!6000000002497-2-tps-96-64.png"></image>
			<view class="login-title">阿里云互动直播</view>
			<view class="nick-block">
				<input
					v-model="nickName"
					@focus="() => {inputFocus = true}"
					@blur="() => {inputFocus = false}"
				/>
				<view :class="['nick-tip', { focus: !!nickName || inputFocus }]">昵称（请输入英文字母、数字）</view>
			</view>
			
			<view class="login-btn">
				<primary-button
					:disabled="!nickName"
					:loading="logging"
					@click="login"
				>
					进入
				</primary-button>
			</view>
		</view>
	</view>
</template>

<script>
	import PrimaryButton from '@/components/primaryButton/index.vue';
	import services from '@/utils/services.js';
	
	export default {
		components: {
			PrimaryButton,
		},
		
		data() {
			return {
				nickName: '',
				inputFocus: false,
				logging: false,
			};
		},
		
		methods: {
			login() {
				const userName = this.nickName.trim();
				if (this.logging) {
					return;
				}
				if (!/^[a-zA-Z0-9]+$/.test(userName)) {
					uni.showModal({
						content: '昵称只支持英文字母、数字',
						showCancel: false,
						confirmText: '确定',
						confirmColor: '#FF5722',
					});
					return;
				}
				
				this.logging = true;
				
				services
					.login(userName, userName)
					.then((res) => {
						// 登录成功跳转
						uni.redirectTo({
							url: '/pages/roomList/roomList',
						});
					})
					.catch((err) => {
						console.log('err->', err);
						uni.showToast({
							title: '登录失败',
							icon: 'error',
						});
					})
					.finally(() => {
						this.logging = false;
					});
			},
		}
	};
</script>

<style lang="scss" scoped>
	@import "./index.scss";
</style>
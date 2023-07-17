<template>
	<view class="like-anime-container">
		<view
			v-for="(item) in bubbles"
			:key="item.id"
			:class="['bubble', `bg${item.num}`, `anime-${item.num}`]"
		></view>
	</view>
</template>

<script>
	import { randomNum } from '@/utils/common.js';
	
	export default {
		data() {
			return {
				count: 0,
				bubbles: [],
			};
		},
		methods: {
			add() {
				this.count += 1;
				const item = {
					id: this.count,
					num: randomNum(6, 1),
				};
				this.bubbles.push(item);
				
				setTimeout(() => {
					const i = this.bubbles.indexOf(item);
					if (i !== -1) {
						this.bubbles.splice(i, 1);
					}
				}, 1500);
			},
		},
	};
</script>

<style lang="scss">
	@import './likeAnime.scss';
</style>
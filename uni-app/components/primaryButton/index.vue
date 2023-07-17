<template>
	<button
		:class="[
			'primary-btn',
			{
				disabled,
				loading,
			}
		]"
		:loading="loading"
		@click="handleClick"
	>
		<slot></slot>
	</button>
</template>

<script>
	export default {
		props: {
			disabled: {
				type: Boolean,
				default: false,
			},
			loading: {
				type: Boolean,
				default: false,
			}
		},
		
		methods: {
			handleClick() {
				if (this.disabled || this.loading) {
					return;
				}
				this.$emit('click');
			}
		}
	};
</script>

<style lang="scss">
	@import "./index.scss";
</style>
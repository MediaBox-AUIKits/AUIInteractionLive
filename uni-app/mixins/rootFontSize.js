export default {
	data() {
		return {
			fontSize: 50,
		};
	},
	
	onLoad() {
		const updateBodyFontSize = (screenWidth) => {
			let value = Math.floor(screenWidth / 15);
			value = Math.floor(value / 5) * 5 + 25;
			value = Math.min(value, 75);
			this.fontSize = value;
		};
		
		// #ifdef MP-WEIXIN
		uni.onWindowResize((result) => {
			updateBodyFontSize(result.size.windowWidth);
		});
		// #endif
		
		uni.getSystemInfo({
			success(res) {
				updateBodyFontSize(res.screenWidth);
			}
		})
	}
};

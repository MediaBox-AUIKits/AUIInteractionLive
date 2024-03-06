<script>
	import { ImEngine } from  '@/utils/Interaction.js';
	export default {
		globalData: {
			interaction: ImEngine.createEngine(),
		},
		
		onLaunch() {
			console.log('onLaunch');
		}
	}
</script>

<style>
	/*每个页面公共css */
	view, :after, :before {
	  box-sizing: border-box;
	}
	
	@font-face {
	  font-family: 'auiicon';  /* Project id 3750272 */
	  src: url('//at.alicdn.com/t/a/font_3750272_qpp9tanvo3.woff2?t=1676206289283') format('woff2'),
	       url('//at.alicdn.com/t/a/font_3750272_qpp9tanvo3.woff?t=1676206289283') format('woff'),
	       url('//at.alicdn.com/t/a/font_3750272_qpp9tanvo3.ttf?t=1676206289283') format('truetype');
	}
	
	[class^='auiicon-'],
	[class*=' auiicon-'] {
		/* use !important to prevent issues with browser extensions that change fonts */
		font-family: 'auiicon' !important;
		speak: none;
		display: inline-block;
		vertical-align: middle;
		font-style: normal;
		font-weight: normal;
		font-variant: normal;
		text-transform: none;
		line-height: 1;
		/* Better Font Rendering =========== */
		-webkit-font-smoothing: antialiased;
		-moz-osx-font-smoothing: grayscale;
	}
	
	.auiicon-Playback:before {
	  content: "\e629";
	}
	
	.auiicon-Heart:before {
	  content: "\e62a";
	}
	
	.auiicon-Live:before {
	  content: "\e628";
	}
	
	.auiicon-LeftOutline:before {
	  content: "\e627";
	}
	
	.auiicon-Close:before {
	  content: "\e625";
	}
	
	.auiicon-Share:before {
	  content: "\e62b";
	}
</style>

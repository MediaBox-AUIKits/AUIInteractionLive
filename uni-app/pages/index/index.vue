<template>
	<page-meta :root-font-size="fontSize+'px'"></page-meta>
	<login></login>
</template>

<script>
	import Login from '@/components/login/index.vue';
	import rootFontSize from '@/mixins/rootFontSize.js';
	
	export default {
		components: {
			Login,
		},
		
		mixins: [rootFontSize],
		
		methods: {

		}
	}
</script>

<style>
</style>

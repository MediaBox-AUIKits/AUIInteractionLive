import Vue from 'vue';
import Vuex from 'vuex';
import liveroom from './modules/liveroom.js';

Vue.use(Vuex);

const store  = new Vuex.Store({
	modules: {
		liveroom,
	},
});

export default store;

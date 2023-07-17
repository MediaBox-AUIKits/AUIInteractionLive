const defaultState = {
	info: {
		status: -1, // 代表未获取到数据
	},
};

export default {
	namespaced: true,
	
	state: {
		info: {
			status: -1, // 代表未获取到数据
		},
	},
	
	getters: {
		info: (state) => {
			return state.info;
		},
		extendsInfo: (state) => {
			const str = state.info.extends || '{}';
			try{
				const res = JSON.parse(str);
				return res;
			}catch(e){
				//TODO handle the exception
				return {};
			}
		},
	},
	
	mutations: {
		reset(state) {
			state.info = {
				status: -1, // 代表未获取到数据
			};
		},
		updateInfo(state, info) {
			if (info) {
				state.info = {
					...state.info,
					...info,
				};
			}
		},
		updateMetrics(state, metrics) {
			if (metrics) {
				const info = {
					...state.info,
					metrics,
				};
				state.info = info;
			}
		},
	},
};

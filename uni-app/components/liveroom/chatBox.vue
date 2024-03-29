<template>
	<view
		class="chat-box"
		:style="{
			display: visible ? 'block' : 'none',
			bottom: isPlayback ? '50px' : '35px',
		}"
	>
		<scroll-view
			v-if="allowChat"
			class="chat-list"
			:show-scrollbar="false"
			:scroll-y="true"
			:enable-flex="true"
			:scroll-into-view="scrollIntoViewId"
		>
			<view class="chat-item chat-item-notice">
				欢迎大家来到直播间！直播间内严禁出现违法违规、低俗色情、吸烟酗酒等内容，若有违规行为请及时举报。
			</view>
			<view
				v-for="(item) in commentList"
				:id="item.messageId"
				:key="item.messageId"
				class="chat-item"
			>
				<view
					class="chat-item-name"
					:style="{ color: getNameColor(item.nickName) }"
				>
					{{ item.nickName }}:
				</view>
				<view class="chat-item-content">{{ item.content }}</view>
			</view>
		</scroll-view>
		<view class="operations-wrap">
			<input
				:class="['chat-input', { 'fixed': inputFixedBottom > 0 }]"
				:style="{
					visibility: allowChat ? 'visible' : 'hidden',
					bottom: `${inputFixedBottom}px`,
				}"
				placeholder-class="chat-input-placeholder"
				:placeholder="chatPlaceholder"
				:disabled="chatInputDisbale"
				v-model="text"
				confirm-type="send"
				:adjust-position="false"
				@confirm="handleConfirm"
				@focus="handleFocus"
				@blur="handleBlur"
			/>
			
			<!-- 手动调起分享，处理逻辑在 pages/room.vue onShareAppMessage 中 -->
			<button
				class="operation-btn-wrap share-btn"
				<!-- #ifdef MP-WEIXIN -->
				open-type="share"
				<!-- #endif -->
				<!-- #ifdef H5 -->
				@click="handleShare"
				<!-- #endif -->
			>
				<view class="operation-btn auiicon-Share"></view>
			</button>
			<view class="operation-btn-wrap" @click="handleClickLike">
				<view class="operation-btn auiicon-Heart"></view>
				<like-anime ref="animeRef" />
			</view>
		</view>
		
		<view v-if="allowChat" class="bullet-list">
			<view
				v-for="item in bullets"
				:key="item.id"
				class="bullet-item"
			>
				{{ item.text }}
			</view>
		</view>
	</view>
</template>

<script>
	import { mapGetters } from 'vuex';
	import { 
		CustomMessageTypes, 
		MaxMessageCount,
		InteractionMessageTypes
	} from '@/utils/constants.js';
	import services from '@/utils/services.js';
	import { getNameColor, throttle } from '@/utils/common.js';
	import LikeAnime from '../likeAnime/likeAnime.vue';
	
	export default {
		name: 'chatBox',
		
		components: {
			LikeAnime,
		},
		
		props: {
			visible: {
				type: Boolean,
				default: true,
			},
			isPlayback: {
				type: Boolean,
				default: false,
			},
			joinedGroupId: {
				type: String,
				default: '',
			},
		},
		
		data() {
			return {
				text: '',
				sending: false,
				commentList: [],
				likeCount: 0,
				bullets: [],
				inputFixedBottom: 0, // 绝对定位时的值
				scrollIntoViewId: '', // 聊天列表自动定位滚动到的id
				muteAllStatus: undefined,
				muteUserStatus: undefined,
			};
		},

		watch: {
			imReady(val) {
				if (val) {
					this.listenInteraction();
					console.log('chatbox imReady listenInteraction');
				}
			}
		},
		
		computed: {
			...mapGetters({
				roomInfo: 'liveroom/info',
			}),
			allowChat() {
				const status = this.roomInfo.status;
				return status === 0 || status === 1;
			},
			chatPlaceholder() {
				if (this.roomInfo.groupMuted) {
					return '全员禁言中';
				}
				if (!this.allowChat) {
					return ' '; // 真机模拟时发现不展示输入框
				}
				return '和主播说点什么';
			},
			chatInputDisbale() {
				return !this.allowChat || this.sending || !!this.roomInfo.groupMuted;
			},
			imReady() {
				return this.roomInfo.imReady;
			}
		},
		
		methods: {
			handleFocus(evt) {
				if (evt.detail.height > 35) {
					this.inputFixedBottom = evt.detail.height;
				}
			},
			handleBlur() {
				this.inputFixedBottom = 0;
			},
			// 发送消息
			handleConfirm(evt) {
				const content = this.text?.trim();
				if(
					!content ||
					!this.joinedGroupId ||
					this.sending ||
					this.roomInfo.groupMuted
				) {
					return;
				}
				// console.log(this.joinedGroupId, content);
				const options = {
				    groupId: this.joinedGroupId,
				    type: 10001,
				    data: JSON.stringify({ content }),
				};
				this.interaction
					?.getMessageManager()
					?.sendGroupMessage(options)
					.then(() => {
						// console.log('发送成功');
						this.text = '';
					})
					.catch((err) => {
						console.log('发送失败', err);
					})
					.finally(() => {
						this.sending = false;
					});
			},

			async listenInteraction() {
				this.interaction = getApp().globalData.interaction;

				const userInfo = services.getUserInfo();
				const groupManager = this.interaction?.getGroupManager();
				groupManager?.on('memberchange', (groupId, memberCount, joinUsers, leaveUsers) => {
					joinUsers.length > 0 && joinUsers.forEach(user => {
						this.handleReceivedMessage({
							type: InteractionMessageTypes.PaaSUserJoin,
							data: JSON.stringify({
								user,
							}),
							groupId,
							messageId: '',
							sender: user,
						});
					});

					leaveUsers.length > 0 && leaveUsers.forEach(user => {
						this.handleReceivedMessage({
							type: InteractionMessageTypes.PaaSUserLeave,
							data: JSON.stringify({
								user,
							}),
							groupId,
							messageId: '',
							sender: user,
						});
					});
				});
				groupManager?.on('mutechange', (groupId, status) => {
					let type;
					const newMuteUserStatus = status.muteUserList.includes(
						userInfo?.userId
					);
					if (status.muteAll !== this.muteAllStatus) {
						type = status.muteAll
							? InteractionMessageTypes.PaaSMuteGroup
							: InteractionMessageTypes.PaaSCancelMuteGroup;
						this.muteAllStatus = status.muteAll;
						this.handleReceivedMessage({
							type,
							data: JSON.stringify({
								status,
							}),
							groupId,
							messageId: '',
							sender: {
								userId: 'send from V2 IM sdk',
								userNick: '',
								userAvatar: '',
							},
						});
					}
					if (newMuteUserStatus !== this.muteUserStatus) {
						type = newMuteUserStatus
							? InteractionMessageTypes.PaaSMuteUser
							: InteractionMessageTypes.PaaSCancelMuteUser;
						this.muteUserStatus = newMuteUserStatus;
						this.handleReceivedMessage({
							type,
							data: JSON.stringify({
								status,
							}),
							groupId,
							messageId: '',
							sender: {
								userId: 'send from V2 IM sdk',
								userNick: '',
								userAvatar: '',
							},
						});
					}
				});

				const messageManager = this.interaction?.getMessageManager();
				messageManager?.on("recvc2cmessage", (eventData) => {
					this.handleReceivedMessage(eventData || {});
				});
				messageManager?.on("recvgroupmessage", (eventData) => {
					this.handleReceivedMessage(eventData || {});
				});

				this.handleUserJoined = throttle(this.handleUserJoined, 1500);
			},

			// 处理接收到的信息
			handleReceivedMessage(eventData) {
				const { type, data: _data, messageId, sender = {} } = eventData || {};
				console.log('收到消息了', eventData);
				let data = _data && JSON.parse(_data || '{}');
				const nickName = sender.userNick ?? sender.userId;

				switch (type){
					case InteractionMessageTypes.PaaSUserJoin:
					    // 用户加入聊天组，更新直播间统计数据
					    this.handleUserJoined(nickName, data, messageId);
					    break;
					case InteractionMessageTypes.PaaSLikeInfo:
					    // 用户点赞数据，目前页面未使用
					    break;
					case CustomMessageTypes.Comment:
						// 接收到评论消息
						if (data && data.content) {
							this.addMessageItem(data.content, nickName, messageId);
						}
						break;
					case InteractionMessageTypes.PaaSMuteGroup:
						this.text = '';
						this.$store.commit('liveroom/updateInfo', { groupMuted: true });
						this.showToast('主播已开启全员禁言');
						break;
					case InteractionMessageTypes.PaaSCancelMuteGroup:
						this.$store.commit('liveroom/updateInfo', { groupMuted: false });
						this.showToast('主播已解除全员禁言');
						break;
					case InteractionMessageTypes.PaaSMuteUser:
						this.handleMuteUser(true, data);
						break;
					case InteractionMessageTypes.PaaSCancelMuteUser:
						this.handleMuteUser(false, data);
						break;
					case CustomMessageTypes.NoticeUpdate:
						// banner 组件中的公告内容更新
						if (typeof data.notice === 'string') {
							this.$store.commit('liveroom/updateInfo', { notice: data.notice });
							this.showToast('公告已更新');
						}
						break;
					default:
						break;
				}
			},

			handleUserJoined(nickName, data, messageId) {
				this.interaction
					.getGroupManager()
					?.queryGroup(this.joinedGroupId)
					.then(res => {
						this.$store.commit('liveroom/updateMetrics', {
							pv: res?.statistics?.pv,
							onlineCount: res?.statistics?.onlineCount,
						});
					});

				this.addBulletItem(nickName, messageId);
			},
			// 用于显示会消失的的气泡消息，如 入会 相关
			addBulletItem(nickName, messageId) {
				const item = {
					id: messageId,
					text: `${nickName} 进入了直播间`,
				};
				this.bullets.push(item);
				setTimeout(() => {
					const i = this.bullets.indexOf(item);
					if (i !== -1) {
						this.bullets.splice(i, 1);
					}
				}, 1500);
			},
			// 添加评论
			addMessageItem(content, nickName, messageId) {
				const mid = `m_${messageId}`;
				const messageItem = { messageId: mid, content, nickName };
				this.commentList.push(messageItem);
				if(this.commentList.length > MaxMessageCount) {
					this.commentList.shift();
				}
				// 需要加延时 H5 才生效
				setTimeout(() => {
					this.scrollIntoViewId = mid;
				}, 10);
			},
			// 处理禁言
			handleMuteUser(isMuted, userInfo) {
				// 暂不支持个人禁言
			},
			showToast(text) {
				uni.showToast({
					title: text,
					icon: 'none',
				});
			},
			getNameColor(name) {
				return getNameColor(name);
			},
			handleClickLike() {
				this.showToast('点赞请自行实现');
			},
			handleShare() {
				this.showToast('分享请自行实现');
			},
		},
	};
</script>

<style lang="scss" scoped>
	@import './chatBox.scss';
</style>
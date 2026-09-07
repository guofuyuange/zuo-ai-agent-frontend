<template>
  <div class="chat-container">
    <!-- 聊天记录区域 -->
    <div class="chat-messages" ref="messagesContainer">
      <div v-for="(msg, index) in messages" :key="index" class="message-wrapper" :class="{ 'user': msg.isUser, 'ai': !msg.isUser }">
        <!-- AI消息 -->
        <div v-if="!msg.isUser" 
             class="message ai-message" 
             :class="[msg.type, 'fade-in-up']">
          <div class="avatar ai-avatar">
            <AiAvatarFallback :type="aiType" />
          </div>
          <div class="message-content-wrapper">
            <div class="message-bubble">
              <div class="message-content">
                {{ msg.content }}
                <span v-if="connectionStatus === 'connecting' && index === messages.length - 1" class="typing-indicator">
                  <span class="dot"></span>
                  <span class="dot"></span>
                  <span class="dot"></span>
                </span>
              </div>
            </div>
            <div class="message-time">{{ formatTime(msg.time) }}</div>
          </div>
        </div>
        
        <!-- 用户消息 -->
        <div v-else class="message user-message" :class="[msg.type, 'fade-in-up']">
          <div class="message-content-wrapper">
            <div class="message-bubble">
              <div class="message-content">{{ msg.content }}</div>
            </div>
            <div class="message-time">{{ formatTime(msg.time) }}</div>
          </div>
          <div class="avatar user-avatar">
            <div class="avatar-placeholder">我</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 输入区域 -->
    <div class="chat-input-container">
      <div class="chat-input-wrapper">
        <div class="chat-input">
          <div class="input-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
            </svg>
          </div>
          <textarea 
            v-model="inputMessage" 
            @keydown.enter.prevent="handleEnter"
            @input="autoResize"
            placeholder="输入消息..." 
            class="input-box"
            :disabled="connectionStatus === 'connecting'"
            ref="textareaRef"
            rows="1"
          ></textarea>
          <button 
            @click="sendMessage" 
            class="send-button"
            :disabled="connectionStatus === 'connecting' || !inputMessage.trim()"
            :class="{ 'active': inputMessage.trim() }"
          >
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <line x1="22" y1="2" x2="11" y2="13"></line>
              <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
            </svg>
          </button>
        </div>
        <div class="input-hint">按 Enter 发送，Shift + Enter 换行</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, nextTick, watch, computed } from 'vue'
import AiAvatarFallback from './AiAvatarFallback.vue'

const props = defineProps({
  messages: {
    type: Array,
    default: () => []
  },
  connectionStatus: {
    type: String,
    default: 'disconnected'
  },
  aiType: {
    type: String,
    default: 'default'
  }
})

const emit = defineEmits(['send-message'])

const inputMessage = ref('')
const messagesContainer = ref(null)
const textareaRef = ref(null)

// 根据AI类型选择不同头像
const aiAvatar = computed(() => {
  return props.aiType === 'love' 
    ? '/ai-love-avatar.png'
    : '/ai-super-avatar.png'
})

// 发送消息
const sendMessage = () => {
  if (!inputMessage.value.trim()) return
  
  emit('send-message', inputMessage.value)
  inputMessage.value = ''
  
  // 重置输入框高度
  nextTick(() => {
    if (textareaRef.value) {
      textareaRef.value.style.height = 'auto'
    }
  })
}

// 处理回车键
const handleEnter = (e) => {
  if (e.shiftKey) {
    // Shift + Enter 换行，不阻止默认行为
    return
  }
  // 普通 Enter 发送消息
  sendMessage()
}

// 自动调整输入框高度
const autoResize = () => {
  const textarea = textareaRef.value
  if (!textarea) return
  
  textarea.style.height = 'auto'
  const newHeight = Math.min(textarea.scrollHeight, 120)
  textarea.style.height = newHeight + 'px'
}

// 格式化时间
const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })
}

// 自动滚动到底部
const scrollToBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTo({
      top: messagesContainer.value.scrollHeight,
      behavior: 'smooth'
    })
  }
}

// 监听消息变化与内容变化，自动滚动
watch(() => props.messages.length, () => {
  scrollToBottom()
})

watch(() => props.messages.map(m => m.content).join(''), () => {
  scrollToBottom()
})
</script>

<style scoped>
.chat-container {
  display: flex;
  flex-direction: column;
  height: 70vh;
  min-height: 600px;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4e8ec 100%);
  border-radius: 16px;
  overflow: hidden;
  position: relative;
  box-shadow: 
    0 10px 40px rgba(0, 0, 0, 0.1),
    0 0 0 1px rgba(255, 255, 255, 0.5) inset;
}

/* 聊天记录区域 */
.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  padding-bottom: 100px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

/* 滚动条样式 */
.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: transparent;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: rgba(0, 0, 0, 0.15);
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: rgba(0, 0, 0, 0.25);
}

/* 消息包装器 */
.message-wrapper {
  display: flex;
  width: 100%;
  animation: fadeInUp 0.3s ease-out;
}

.message-wrapper.user {
  justify-content: flex-end;
}

.message-wrapper.ai {
  justify-content: flex-start;
}

/* 消息主体 */
.message {
  display: flex;
  align-items: flex-start;
  max-width: 80%;
  gap: 10px;
}

.user-message {
  /* 用户消息：气泡在左，头像在右（靠右对齐） */
  justify-content: flex-end;
}

/* 头像 */
.avatar {
  width: 38px;
  height: 38px;
  border-radius: 50%;
  overflow: hidden;
  flex-shrink: 0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.ai-avatar {
  border: 2px solid rgba(255, 255, 255, 0.8);
}

.user-avatar {
  border: 2px solid #007bff;
}

.avatar-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #007bff, #0056b3);
  color: white;
  font-weight: bold;
  font-size: 14px;
}

/* 消息内容包装器 */
.message-content-wrapper {
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: flex-start;
}

.user-message .message-content-wrapper {
  align-items: flex-end;
}

/* 消息气泡 */
.message-bubble {
  padding: 12px 16px;
  border-radius: 18px;
  position: relative;
  word-wrap: break-word;
  max-width: 100%;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.message-bubble:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
}

/* AI消息气泡 */
.ai-message .message-bubble {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  color: #2c3e50;
  border-bottom-left-radius: 4px;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

/* 用户消息气泡 */
.user-message .message-bubble {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  color: white;
  border-bottom-right-radius: 4px;
}

/* 消息内容 */
.message-content {
  font-size: 15px;
  line-height: 1.6;
  white-space: pre-wrap;
  word-break: break-word;
  text-align: left;
}

/* 时间戳 */
.message-time {
  font-size: 11px;
  color: #999;
  padding: 0 4px;
}

.user-message .message-time {
  text-align: right;
}

/* 打字机指示器 */
.typing-indicator {
  display: inline-flex;
  align-items: center;
  gap: 3px;
  margin-left: 6px;
  vertical-align: middle;
}

.typing-indicator .dot {
  width: 6px;
  height: 6px;
  background-color: #007bff;
  border-radius: 50%;
  animation: typingBounce 1.4s infinite ease-in-out both;
}

.typing-indicator .dot:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator .dot:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes typingBounce {
  0%, 80%, 100% {
    transform: scale(0.6);
    opacity: 0.4;
  }
  40% {
    transform: scale(1);
    opacity: 1;
  }
}

/* 输入区域 */
.chat-input-container {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  z-index: 100;
  padding: 12px 16px 8px;
}

.chat-input-wrapper {
  max-width: 900px;
  margin: 0 auto;
}

.chat-input {
  display: flex;
  align-items: flex-end;
  gap: 10px;
  background: #f0f2f5;
  border-radius: 24px;
  padding: 8px 8px 8px 16px;
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.chat-input:focus-within {
  background: #ffffff;
  border-color: #007bff;
  box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.1);
}

/* 输入框图标 */
.input-icon {
  width: 20px;
  height: 20px;
  color: #999;
  flex-shrink: 0;
  margin-bottom: 8px;
}

/* 输入框 */
.input-box {
  flex: 1;
  border: none;
  background: transparent;
  font-size: 15px;
  line-height: 1.5;
  resize: none;
  outline: none;
  min-height: 20px;
  max-height: 120px;
  padding: 6px 0;
  font-family: inherit;
  color: #333;
}

.input-box::placeholder {
  color: #aaa;
}

.input-box:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 发送按钮 */
.send-button {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  border: none;
  background: #e0e0e0;
  color: #999;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s ease;
  flex-shrink: 0;
  margin-bottom: 2px;
}

.send-button svg {
  width: 18px;
  height: 18px;
}

.send-button:hover:not(:disabled) {
  background: #007bff;
  color: white;
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
}

.send-button.active {
  background: #007bff;
  color: white;
}

.send-button:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

/* 输入提示 */
.input-hint {
  text-align: center;
  font-size: 11px;
  color: #bbb;
  margin-top: 6px;
  letter-spacing: 0.5px;
}

/* 动画 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in-up {
  animation: fadeInUp 0.3s ease-out;
}

/* 连续消息样式 */
.message-wrapper.ai + .message-wrapper.ai {
  margin-top: 2px;
}

.message-wrapper.ai + .message-wrapper.ai .avatar {
  visibility: hidden;
}

.message-wrapper.ai + .message-wrapper.ai .message-bubble {
  border-top-left-radius: 10px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .chat-container {
    border-radius: 0;
    height: 100vh;
    min-height: auto;
  }
  
  .message {
    max-width: 85%;
  }
  
  .message-content {
    font-size: 14px;
  }
  
  .chat-messages {
    padding: 12px;
  }
  
  .chat-input {
    padding: 6px 6px 6px 12px;
  }
  
  .input-hint {
    display: none;
  }
}

@media (max-width: 480px) {
  .avatar {
    width: 32px;
    height: 32px;
  }
  
  .message-bubble {
    padding: 10px 14px;
  }
  
  .message-content {
    font-size: 14px;
  }
  
  .chat-input-container {
    padding: 8px 12px 4px;
  }
}
</style>
<template>
  <div class="app-container">
    <div class="chat-layout glass-panel">
      <div class="chat-header">
        <div class="header-content">
          <el-icon :size="24" color="var(--color-primary)"><ChatDotRound /></el-icon>
          <div class="title-area">
            <h2>AI 植物顾问</h2>
            <p>您的私人植物专家，随时解答养护难题 <el-tag size="small" type="info" v-if="aiConfig.model">{{ aiConfig.provider }}</el-tag></p>
          </div>
        </div>
        <div class="header-actions">
          <el-button type="primary" link @click="showSettings = true">
            <el-icon :size="20"><Setting /></el-icon>
            设置 AI 模型
          </el-button>
        </div>
      </div>
      
      <div class="chat-messages" ref="messagesContainer">
        <div 
          v-for="(msg, index) in messages" 
          :key="index" 
          class="message-wrapper"
          :class="{ 'user-message': msg.role === 'user', 'ai-message': msg.role === 'ai' }"
        >
          <div class="avatar">
            <el-avatar v-if="msg.role === 'ai'" :icon="Service" class="ai-avatar" />
            <el-avatar v-else :icon="UserFilled" class="user-avatar" />
          </div>
          <div class="message-content glass-panel">
            <p v-html="formatMessage(msg.content)"></p>
            <span class="time">{{ msg.time }}</span>
          </div>
        </div>
        
        <div v-if="loading" class="message-wrapper ai-message">
           <el-avatar :icon="Service" class="ai-avatar" />
           <div class="message-content glass-panel typing-indicator">
             <span></span><span></span><span></span>
           </div>
        </div>
      </div>
      
      <div class="chat-input-area">
        <el-input
          v-model="inputMessage"
          type="textarea"
          :rows="3"
          placeholder="请输入您的问题，例如：发财树叶子变黄了怎么办？"
          @keydown.enter.ctrl="sendMessage"
          resize="none"
          class="custom-textarea"
        />
        <div class="input-actions">
           <span class="tip">按 Ctrl + Enter 发送</span>
           <el-button type="primary" @click="sendMessage" :loading="loading" round>
             发送 <el-icon class="el-icon--right"><Position /></el-icon>
           </el-button>
        </div>
      </div>
    </div>

    <!-- AI Settings Dialog -->
    <el-dialog v-model="showSettings" title="AI 模型配置" width="500px">
      <el-form :model="aiConfig" label-width="100px">
        <el-form-item label="服务商">
          <el-select v-model="aiConfig.provider" placeholder="请选择服务商" @change="onProviderChange">
            <el-option label="DeepSeek" value="deepseek" />
            <el-option label="OpenAI (ChatGPT)" value="openai" />
            <el-option label="Google Gemini" value="gemini" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="模型名称">
          <el-input v-model="aiConfig.model" placeholder="例如: deepseek-chat, gpt-3.5-turbo" />
        </el-form-item>
        
        <el-form-item label="API Key">
          <el-input 
            v-model="aiConfig.apiKey" 
            placeholder="请输入您的 API Key" 
            type="password" 
            show-password 
          />
        </el-form-item>
        
        <el-form-item label="接口地址" v-if="aiConfig.provider !== 'gemini'">
          <el-input v-model="aiConfig.baseUrl" placeholder="例如: https://api.deepseek.com" />
          <div style="font-size: 12px; color: #909399; margin-top: 5px;">
            如果你使用代理，请填入代理地址。
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="showSettings = false">取消</el-button>
          <el-button type="primary" @click="saveSettings">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, nextTick, onMounted, reactive } from 'vue'
import { ChatDotRound, Position, Service, UserFilled, Setting } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { generateAIResponse } from '@/utils/ai-service'

const messagesContainer = ref(null)
const inputMessage = ref('')
const loading = ref(false)
const showSettings = ref(false)

const aiConfig = reactive({
  provider: 'deepseek',
  model: 'deepseek-chat',
  apiKey: '',
  baseUrl: 'https://api.deepseek.com'
})

const messages = ref([
  {
    role: 'ai',
    content: '你好！我是 Greenly 的 AI 植物顾问。我可以帮你识别植物问题、提供养护建议或解答关于植物的任何疑问。请问有什么可以帮你的吗？',
    time: getCurrentTime()
  }
])

function getCurrentTime() {
  const now = new Date()
  return `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`
}

const sendMessage = async () => {
  if (!inputMessage.value.trim()) return
  
  const userMsg = inputMessage.value.trim()
  messages.value.push({
    role: 'user',
    content: userMsg,
    time: getCurrentTime()
  })
  
  inputMessage.value = ''
  scrollToBottom()
  
  loading.value = true
  
  // Real API Call with streaming
  try {
    const aiMessageIndex = messages.value.length
    messages.value.push({
      role: 'ai',
      content: '',
      time: getCurrentTime()
    })
    
    await generateAIResponse(
      aiConfig.provider,
      aiConfig.baseUrl,
      aiConfig.apiKey,
      aiConfig.model,
      messages.value.slice(0, aiMessageIndex), // Pass history
      (chunkText) => {
        // Stream update
        messages.value[aiMessageIndex].content = chunkText
        scrollToBottom()
      }
    )
  } catch (error) {
    ElMessage.error(error.message)
    // Remove the empty message if it failed
    if (messages.value[messages.value.length - 1].content === '') {
       messages.value.pop()
    }
  } finally {
    loading.value = false
  }
}

const onProviderChange = (val) => {
  if (val === 'deepseek') {
    aiConfig.baseUrl = 'https://api.deepseek.com'
    aiConfig.model = 'deepseek-chat'
  } else if (val === 'openai') {
    aiConfig.baseUrl = 'https://api.openai.com/v1'
    aiConfig.model = 'gpt-3.5-turbo'
  } else if (val === 'gemini') {
    aiConfig.baseUrl = ''
    aiConfig.model = 'gemini-1.5-flash'
  }
}

const saveSettings = () => {
  if (!aiConfig.apiKey) {
    ElMessage.warning('请输入 API Key')
    return
  }
  localStorage.setItem('greenly_ai_config', JSON.stringify(aiConfig))
  ElMessage.success('设置已保存')
  showSettings.value = false
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

const formatMessage = (text) => {
  if (!text) return ''
  // 简单的换行和 Markdown 粗体处理
  let formatted = text.replace(/\n/g, '<br>')
  formatted = formatted.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
  return formatted
}

onMounted(() => {
  const savedConfig = localStorage.getItem('greenly_ai_config')
  if (savedConfig) {
    Object.assign(aiConfig, JSON.parse(savedConfig))
  }
  scrollToBottom()
})
</script>

<style scoped lang="scss">
.app-container {
  /* Adjust height to fit within layout without scrolling main body */
  /* Main layout usually has padding. We want chat to fill available space. */
  height: calc(100vh - 120px) !important; 
  display: flex;
  flex-direction: column;
}

.chat-layout {
  flex: 1;
  display: flex;
  flex-direction: column;
  background-color: rgba(255, 255, 255, 0.6);
  border-radius: var(--border-radius-base);
  overflow: hidden;
  margin-bottom: 24px;
  border: 1px solid rgba(255,255,255,0.5);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.05);
}

.chat-header {
  padding: 16px 24px;
  background: rgba(255, 255, 255, 0.85); // slightly more opaque
  border-bottom: 1px solid rgba(0,0,0,0.05);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  .header-content {
    display: flex;
    align-items: center;
    gap: 16px;
    
    .title-area {
      h2 {
        margin: 0;
        font-size: 18px;
        color: var(--color-text-main);
        font-weight: 600;
      }
      p {
        margin: 4px 0 0;
        font-size: 13px;
        color: var(--color-text-secondary);
        display: flex;
        align-items: center;
        gap: 8px;
      }
    }
  }
}

.chat-messages {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 24px;
  background-color: rgba(255,255,255,0.3); // Slight tint
  
  /* Scrollbar styling */
  &::-webkit-scrollbar {
    width: 6px;
  }
  &::-webkit-scrollbar-thumb {
    background-color: rgba(0,0,0,0.1);
    border-radius: 3px;
  }
}

.message-wrapper {
  display: flex;
  gap: 12px;
  max-width: 80%;
  
  &.user-message {
    align-self: flex-end;
    flex-direction: row-reverse;
    
    .message-content {
      background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
      color: white;
      border-bottom-right-radius: 4px;
      
      .time {
        color: rgba(255,255,255,0.8);
        text-align: right;
      }
    }
  }
  
  &.ai-message {
    align-self: flex-start;
    
    .message-content {
      background: white;
      color: var(--color-text-main);
      border-bottom-left-radius: 4px;
      
      .time {
         text-align: left;
      }
    }
  }
  
  .avatar {
    margin-top: 4px;
    /* Ensure avatar doesn't shrink */
    flex-shrink: 0; 
  }
  
  .message-content {
    padding: 12px 16px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    position: relative;
    min-width: 60px;
    word-break: break-word; // Wrap long text
    
    p {
      margin: 0;
      line-height: 1.6;
      font-size: 15px;
    }
    
    .time {
      font-size: 11px;
      color: var(--color-text-secondary);
      margin-top: 4px;
      display: block;
    }
  }
}

.chat-input-area {
  padding: 16px 24px;
  background: white;
  border-top: 1px solid rgba(0,0,0,0.05);
  
  .custom-textarea {
    :deep(.el-textarea__inner) {
      border: none;
      background-color: #f5f7fa;
      border-radius: 12px;
      padding: 12px;
      font-family: inherit;
      resize: none; // Disable resize handle
      box-shadow: none; // Remove default active shadow if wanted
      
      &:focus {
        background-color: white;
        box-shadow: 0 0 0 1px var(--color-primary) inset;
      }
    }
  }
  
  .input-actions {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    margin-top: 12px;
    gap: 16px;
    
    .tip {
      font-size: 12px;
      color: var(--color-text-secondary);
    }
  }
}

.ai-avatar {
  background-color: var(--color-primary-light-9);
  color: var(--color-primary);
}

.user-avatar {
  background-color: #f0f2f5;
  color: #909399;
}

.typing-indicator {
  display: flex !important;
  gap: 4px;
  padding: 16px !important;
  align-items: center;
  min-height: 20px;
  
  span {
    width: 6px;
    height: 6px;
    background-color: var(--color-text-secondary);
    border-radius: 50%;
    animation: bounce 1.4s infinite ease-in-out both;
    display: inline-block;
    
    &:nth-child(1) { animation-delay: -0.32s; }
    &:nth-child(2) { animation-delay: -0.16s; }
  }
}

@keyframes bounce {
  0%, 80%, 100% { transform: scale(0); }
  40% { transform: scale(1); }
}
</style>

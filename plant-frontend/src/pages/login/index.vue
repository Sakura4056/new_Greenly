<template>
  <div class="login-container">
    <div class="login-content">
      <el-card class="login-card glass-panel">
        <template #header>
          <div class="login-header">
            <div class="logo-circle">
              <el-icon :size="32" color="white"><opportunity /></el-icon>
            </div>
            <h2 class="app-title text-gradient">Greenly</h2>
            <p class="app-subtitle">植物养护管理系统</p>
          </div>
        </template>
        
        <el-form :model="loginForm" :rules="rules" ref="loginFormRef" label-position="top" size="large">
          <el-form-item label="账号" prop="username">
            <el-input 
              v-model="loginForm.username" 
              placeholder="请输入用户名" 
              prefix-icon="User" 
              class="modern-input"
            />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input 
              v-model="loginForm.password" 
              type="password" 
              placeholder="请输入密码" 
              prefix-icon="Lock" 
              show-password 
              class="modern-input"
            />
          </el-form-item>
          
          <el-form-item style="margin-top: 32px">
            <el-button type="primary" :loading="loading" class="login-btn" @click="handleLogin" round>
              登 录
            </el-button>
          </el-form-item>
          
          <div class="login-footer">
            <span class="text-secondary">还没有账号？</span>
            <router-link to="/register" class="link-primary">立即注册</router-link>
          </div>
        </el-form>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import request from '@/api/request'
import { User, Lock, Opportunity } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = () => {
  loginFormRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const res = await request.post('/user/login', loginForm)
        userStore.setLoginInfo(res)
        
        const redirect = route.query.redirect || '/'
        router.push(redirect)
      } catch (error) {
        // Error handled in interceptor
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style scoped lang="scss">
.login-container {
  height: 100vh;
  width: 100vw;
  display: flex;
  justify-content: center;
  align-items: center;
  background-image: url('@/assets/images/login_bg.png'); /* Ensure this path matches the artifact or use a CSS gradient fallback */
  background-size: cover;
  background-position: center;
  position: relative;
  
  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: linear-gradient(135deg, rgba(46, 204, 113, 0.2) 0%, rgba(39, 174, 96, 0.4) 100%);
    backdrop-filter: blur(2px);
  }
}

.login-content {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 420px;
  padding: 20px;
}

.login-card {
  border: none;
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15);
  border-radius: 20px;
  overflow: hidden;
  
  :deep(.el-card__header) {
    border-bottom: none;
    padding-bottom: 0;
  }
  
  :deep(.el-card__body) {
    padding: 30px 40px 40px;
  }
}

.login-header {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 10px;
  
  .logo-circle {
    width: 56px;
    height: 56px;
    background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 16px;
    box-shadow: 0 4px 12px rgba(46, 204, 113, 0.3);
  }
  
  .app-title {
    margin: 0;
    font-size: 28px;
    font-weight: 800;
    letter-spacing: 0.5px;
  }
  
  .app-subtitle {
    margin: 8px 0 0;
    font-size: 14px;
    color: var(--color-text-secondary);
    font-weight: 500;
  }
}

.modern-input {
  :deep(.el-input__wrapper) {
    box-shadow: none;
    background-color: #f5f7fa;
    border-radius: 8px;
    transition: all 0.3s;
    padding: 8px 15px;
    
    &.is-focus {
      background-color: #fff;
      box-shadow: 0 0 0 2px var(--color-primary-light-5) inset;
    }
    
    &:hover:not(.is-focus) {
      background-color: #eef1f6;
    }
  }
}

.login-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 2px;
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  border: none;
  box-shadow: 0 4px 14px rgba(46, 204, 113, 0.4);
  transition: all 0.3s;
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(46, 204, 113, 0.6);
  }
  
  &:active {
    transform: translateY(0);
  }
}

.login-footer {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  
  .text-secondary {
    color: var(--color-text-secondary);
  }
  
  .link-primary {
    color: var(--color-primary);
    text-decoration: none;
    font-weight: 600;
    margin-left: 5px;
    
    &:hover {
      text-decoration: underline;
    }
  }
}
</style>

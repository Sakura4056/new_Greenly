<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>提醒推送配置</span>
        </div>
      </template>

      <el-form :model="form" label-width="120px" style="max-width: 500px">
        <el-form-item label="接收邮箱">
          <el-input v-model="form.email" placeholder="接收通知的邮箱" />
        </el-form-item>
        <el-form-item label="接收手机">
          <el-input v-model="form.phone" placeholder="接收通知的手机号" />
        </el-form-item>

        <el-form-item label="推送渠道">
          <el-checkbox v-model="form.channels.popup">网页弹窗</el-checkbox>
          <el-checkbox v-model="form.channels.email">邮件通知</el-checkbox>
        </el-form-item>

        <el-form-item label="打扰模式">
          <el-switch v-model="form.doNotDisturb" active-text="免打扰 (22:00-08:00)" />
        </el-form-item>

        <el-form-item label="每日汇总时间">
          <el-time-select
            v-model="form.summaryTime"
            start="00:00"
            step="01:00"
            end="23:00"
            placeholder="选择发送时间"
          />
          <span style="margin-left: 10px; color: #888; font-size: 12px;">每日将在此时发送邮件汇总提醒</span>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSave" :loading="loading">保存配置</el-button>
          <el-button type="success" plain @click="handleTestEmail" :loading="testLoading" style="margin-left: 10px;">
            测试发送日报邮件
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { updateConfig, getConfig } from '@/api/reminder' // Use API module
import request from '@/api/request'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()
const loading = ref(false)
const testLoading = ref(false)

const form = reactive({
  email: '',
  phone: '', // Keep phone in UI but maybe disable/hide if SMS is gone? User authorized removing SMS function.
  // Actually backend still has `phone` field in ReminderConfig entity, just SMS service removed.
  // But for UI clarity, I should probably hide "SMS Channel" checkbox.
  channels: {
    popup: true,
    email: false
    // sms removed
  },
  doNotDisturb: false,
  summaryTime: '09:00'
})

const handleSave = async () => {
  loading.value = true
  try {
    const payload = {
      email: form.email,
      phone: form.phone,
      popupEnabled: form.channels.popup ? 1 : 0,
      bellEnabled: 1, // Defaulting bell to 1 or add UI for it? 
      // Current UI has "channels.email/sms/popup". 
      // Backend has `popupEnabled` and `bellEnabled`. 
      // Let's map `channels.popup` to `popupEnabled`.
      // And maybe add `channels.bell`? Or just ignore bell for now.
      // Let's assume `popup` covers on-site notifications.
      sceneConfig: JSON.stringify({ 
        doNotDisturb: form.doNotDisturb, 
        emailEnabled: form.channels.email,
        summaryTime: form.summaryTime
      }) // Store DnD and email settings in sceneConfig JSON
    }

    await updateConfig(payload)
    ElMessage.success('配置已更新')
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const handleTestEmail = async () => {
  testLoading.value = true
  try {
    await request({
      url: '/reminder/test-email',
      method: 'post'
    })
    ElMessage.success('测试邮件触发指令已发送！(需后台存在今天到期的养护计划才会发送邮件)')
  } catch (e) {
    console.error(e)
    ElMessage.error('触发失败，可能是后台未重启或未配置。')
  } finally {
    testLoading.value = false
  }
}

onMounted(async () => {
  try {
    const res = await getConfig()
    // request.js interceptor directly returns data of the Result object
    // so `res` IS the ReminderConfig object, not `{ code, data }`
    if (res && res.id !== undefined) {
      form.email = res.email || ''
      form.phone = res.phone || ''
      form.channels.popup = res.popupEnabled === 1
      
      if (res.sceneConfig && res.sceneConfig !== '{}') {
        try {
          const sc = JSON.parse(res.sceneConfig)
          form.doNotDisturb = !!sc.doNotDisturb
          form.channels.email = !!sc.emailEnabled
          if (sc.summaryTime) {
            form.summaryTime = sc.summaryTime
          }
        } catch (e) {
          console.error('Failed to parse sceneConfig', e)
        }
      }
    } else if (userStore.userInfo && userStore.userInfo.email) {
      form.email = userStore.userInfo.email
    }
  } catch (e) {
    console.error('Failed to fetch config', e)
    if (userStore.userInfo && userStore.userInfo.email) {
      form.email = userStore.userInfo.email
    }
  }
})
</script>

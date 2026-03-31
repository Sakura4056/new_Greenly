<template>
  <div class="app-container">
    <!-- Weather Widget Section -->
    <div class="weather-section mb-6">
      <el-card shadow="never" class="weather-card glass-panel">
        <div class="weather-container">
          <div class="weather-main">
            <div class="weather-icon-wrapper">
              <el-icon :size="48" class="weather-icon-dynamic">
                <Sunny v-if="weather.weather && weather.weather.includes('晴')" />
                <Cloudy v-else-if="weather.weather && weather.weather.includes('云')" />
                <Pouring v-else-if="weather.weather && weather.weather.includes('雨')" />
                <PartlyCloudy v-else />
              </el-icon>
            </div>
            <div class="weather-info">
              <div class="location-row">
                <el-icon><Location /></el-icon>
                <span 
                  v-if="!isEditingCity" 
                  @click="isEditingCity = true" 
                  class="city-name" 
                  title="点击切换城市"
                >{{ weather.city || '定位中...' }}</span>
                <el-input 
                  v-else 
                  v-model="inputCity" 
                  placeholder="输入城市" 
                  size="small" 
                  class="city-input"
                  @blur="handleCitySubmit" 
                  @keyup.enter="handleCitySubmit" 
                  ref="cityInputRef" 
                />
              </div>
              <div class="temp-row" v-if="weather.weather">
                <span class="temp">{{ weather.temperature }}°</span>
                <span class="cond">{{ weather.weather }}</span>
              </div>
              <div class="meta-row" v-if="weather.weather">
                <span class="meta-item">湿度 {{ weather.humidity }}%</span>
                <span class="meta-divider">|</span>
                <span class="meta-item">更新 {{ formatTimeSimple(weather.reportTime) }}</span>
              </div>
              <div v-else class="loading-text">{{ weatherStatus }}</div>
            </div>
          </div>
          
          <div class="weather-tips-wrapper">
            <div class="tip-card">
              <el-icon class="tip-icon"><ChatDotRound /></el-icon>
              <p class="tip-text">{{ weatherTip }}</p>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- Stats Cards -->
    <el-row :gutter="24" class="mb-6">
      <el-col :xs="24" :sm="8">
        <div class="stat-card card-hover plant-stats">
          <div class="stat-icon bg-success-light">
            <el-icon color="var(--color-success)"><Pear /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ stats.plantCount || 0 }}</span>
            <span class="stat-label">我的植物</span>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="8">
        <div class="stat-card card-hover task-stats">
          <div class="stat-icon bg-warning-light">
            <el-icon color="var(--color-warning)"><List /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ stats.pendingTaskCount || 0 }}</span>
            <span class="stat-label">待办任务</span>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="8">
        <div class="stat-card card-hover reminder-stats">
          <div class="stat-icon bg-danger-light">
            <el-icon color="var(--color-danger)"><Bell /></el-icon>
          </div>
          <div class="stat-info">
            <span class="stat-value">{{ stats.todayReminderCount || 0 }}</span>
            <span class="stat-label">今日提醒</span>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- Content Row -->
    <el-row :gutter="24">
      <!-- Quick Actions -->
      <el-col :xs="24" :lg="16" class="mb-4">
        <el-card shadow="never" class="action-card card-hover">
          <template #header>
            <div class="card-header">
              <h3>快捷操作</h3>
              <el-tag type="info" size="small" effect="plain">常用功能</el-tag>
            </div>
          </template>
          <div class="quick-actions-grid">
            <div class="action-item" @click="$router.push('/care/schedule-add')">
              <div class="action-icon-circle bg-primary-gradient">
                <el-icon color="#fff"><Plus /></el-icon>
              </div>
              <span>新建计划</span>
            </div>
            <div class="action-item" @click="$router.push('/photo/upload')">
              <div class="action-icon-circle bg-success-gradient">
                <el-icon color="#fff"><Upload /></el-icon>
              </div>
              <span>上传照片</span>
            </div>
            <div class="action-item" @click="$router.push('/plant/official')">
              <div class="action-icon-circle bg-info-gradient">
                <el-icon color="#fff"><Search /></el-icon>
              </div>
              <span>查询百科</span>
            </div>
            <div class="action-item" @click="$router.push('/care/statistic')">
              <div class="action-icon-circle bg-warning-gradient">
                <el-icon color="#fff"><DataLine /></el-icon>
              </div>
              <span>查看统计</span>
            </div>
          </div>
        </el-card>
      </el-col>

      <!-- Recent Tasks -->
      <el-col :xs="24" :lg="8">
        <el-card shadow="never" class="task-list-card card-hover">
          <template #header>
            <div class="card-header">
              <h3>最近未完成</h3>
              <el-button link type="primary" @click="$router.push('/care/schedule-list')">全部</el-button>
            </div>
          </template>
          
          <div v-if="recentTasks.length > 0" class="task-list">
            <div v-for="task in recentTasks" :key="task.id" class="task-item">
              <div class="task-status-line"></div>
              <div class="task-content">
                <div class="task-title">{{ task.taskName }}</div>
                <div class="task-time">{{ formatTime(task.dueTime) }}</div>
              </div>
              <el-tag size="small" type="warning" effect="light">待办</el-tag>
            </div>
          </div>
          <div v-else class="empty-state">
            <span class="empty-text">太棒了，没有未完成任务！</span>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive, nextTick, watch, computed, onUnmounted } from 'vue'
import { getOfficialPlantList } from '@/api/plant'
import { getScheduleList } from '@/api/care'
import { getUnread } from '@/api/reminder'
import { 
  Pear, List, Bell, Plus, Upload, Search, DataLine, Location, 
  Sunny, Cloudy, Pouring, PartlyCloudy, ChatDotRound 
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const userStore = useUserStore()

// --- Data ---
const stats = reactive({
  plantCount: 0,
  pendingTaskCount: 0,
  todayReminderCount: 0
})
const recentTasks = ref([])
const isLoading = ref(false)
const lastFetchTime = ref(0)
const CACHE_DURATION = 5 * 60 * 1000 // 5 minutes cache

// Weather Data
const AMAP_KEY = import.meta.env.VITE_AMAP_KEY || ''
const weather = reactive({
  city: '',
  adcode: '',
  weather: '',
  temperature: '',
  humidity: '',
  reportTime: ''
})
const weatherStatus = ref('正在获取位置...')
const isEditingCity = ref(false)
const inputCity = ref('')
const cityInputRef = ref(null)
const weatherCache = ref(null)
const weatherCacheTime = ref(0)
const WEATHER_CACHE_DURATION = 15 * 60 * 1000 // 15 minutes cache

// --- Computed Properties ---
const weatherTip = computed(() => {
  if (!weather.weather) return '今天也要记得照顾好植物哦~'
  if (weather.weather.includes('雨')) return '今天下雨，户外植物记得避雨，室内注意空气流通。'
  if (weather.weather.includes('晴') || weather.weather.includes('多云')) return '天气不错，适合给植物晒晒太阳！'
  if (weather.weather.includes('雪')) return '下雪啦，注意给植物保暖。'
  if (weather.weather.includes('阴')) return '阴天光照不足，喜阳植物可能没精神。'
  return '根据天气调整植物养护计划吧！'
})

// --- Methods ---

const formatTime = (arr) => {
  if (Array.isArray(arr)) return `${arr[1]}-${arr[2]} ${arr[3]}:${String(arr[4]).padStart(2, '0')}`
  return arr
}

const formatTimeSimple = (timeStr) => {
  if(!timeStr) return ''
  // Only show HH:mm if it's a date string, or just return as is
  return timeStr.split(' ')[1] || timeStr
}

const fetchDashboardData = async () => {
  const now = Date.now()
  // Only fetch if last fetch was more than CACHE_DURATION ago
  if (now - lastFetchTime.value < CACHE_DURATION) {
    return
  }

  isLoading.value = true
  try {
    const [plantRes, scheduleRes, reminderRes] = await Promise.all([
      getOfficialPlantList({ pageNum: 1, pageSize: 1000 }),
      getScheduleList({ userId: userStore.userId, status: 0, pageSize: 4 }),
      getUnread(userStore.userId)
    ])

    if (plantRes && plantRes.records) {
      stats.plantCount = plantRes.records.length
    }

    if (scheduleRes && scheduleRes.records) {
      stats.pendingTaskCount = scheduleRes.total
      recentTasks.value = scheduleRes.records
    }

    if (reminderRes) {
      stats.todayReminderCount = reminderRes.totalUnread
    }

    lastFetchTime.value = now
  } catch (e) {
    console.error(e)
    ElMessage.error('获取数据失败，请稍后重试')
  } finally {
    isLoading.value = false
  }
}

// Weather Logic
const loadWeather = async (cityCode = null) => {
  if (!AMAP_KEY) {
    weatherStatus.value = '请配置 Key'
    return
  }

  const now = Date.now()
  // Check if we have valid cached weather data
  if (!cityCode && weatherCache.value && now - weatherCacheTime.value < WEATHER_CACHE_DURATION) {
    Object.assign(weather, weatherCache.value)
    weatherStatus.value = ''
    return
  }

  // 1. If no cityCode, IP Locate
  if (!cityCode) {
    try {
      const ipRes = await fetch(`https://restapi.amap.com/v3/ip?key=${AMAP_KEY}`)
      const ipData = await ipRes.json()
      if (ipData.status === '1') {
        cityCode = ipData.adcode
        weather.city = ipData.city
      } else {
        weatherStatus.value = '定位失败'
        return
      }
    } catch (e) {
      weatherStatus.value = '定位异常'
      return
    }
  }

  // 2. Get Weather
  if (cityCode) {
    try {
      const wRes = await fetch(`https://restapi.amap.com/v3/weather/weatherInfo?key=${AMAP_KEY}&city=${cityCode}`)
      const wData = await wRes.json()
      if (wData.status === '1' && wData.lives && wData.lives.length > 0) {
        const live = wData.lives[0]
        const weatherData = {
          city: live.city,
          adcode: cityCode,
          weather: live.weather,
          temperature: live.temperature,
          humidity: live.humidity,
          reportTime: live.reporttime
        }
        Object.assign(weather, weatherData)
        weatherCache.value = weatherData
        weatherCacheTime.value = now
        weatherStatus.value = ''
      } else {
        weatherStatus.value = '无数据'
      }
    } catch (e) {
      weatherStatus.value = '获取失败'
    }
  }
}

const handleCitySubmit = async () => {
  if (!inputCity.value) {
    isEditingCity.value = false
    return
  }

  try {
    const geoRes = await fetch(`https://restapi.amap.com/v3/geocode/geo?address=${inputCity.value}&key=${AMAP_KEY}`)
    const geoData = await geoRes.json()
    if (geoData.status === '1' && geoData.geocodes && geoData.geocodes.length > 0) {
      const adcode = geoData.geocodes[0].adcode
      await loadWeather(adcode)
      isEditingCity.value = false
    } else {
      ElMessage.warning('找不到该城市')
    }
  } catch (e) {
    ElMessage.error('网络错误')
  }
}

// Auto-refresh data
let refreshInterval = null

const startAutoRefresh = () => {
  // Refresh data every 5 minutes
  refreshInterval = setInterval(() => {
    fetchDashboardData()
    loadWeather()
  }, 5 * 60 * 1000)
}

const stopAutoRefresh = () => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
    refreshInterval = null
  }
}

watch(isEditingCity, (val) => {
  if (val) {
    inputCity.value = weather.city
    nextTick(() => {
      cityInputRef.value?.focus()
    })
  }
})

onMounted(() => {
  fetchDashboardData()
  loadWeather()
  startAutoRefresh()
})

onUnmounted(() => {
  stopAutoRefresh()
})
</script>

<style scoped lang="scss">
.mb-6 { margin-bottom: 24px; }
.mb-4 { margin-bottom: 16px; }

/* Stats Cards */
.stat-card {
  background: white;
  border-radius: var(--border-radius-base);
  padding: 24px;
  display: flex;
  align-items: center;
  gap: 20px;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
  cursor: default;
  
  .stat-icon {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    
    &.bg-success-light { background-color: var(--el-color-success-light-9); }
    &.bg-warning-light { background-color: var(--el-color-warning-light-9); }
    &.bg-danger-light { background-color: var(--el-color-danger-light-9); }
  }
  
  .stat-info {
    display: flex;
    flex-direction: column;
    
    .stat-value {
      font-size: 32px;
      font-weight: 700;
      color: var(--color-text-main);
      line-height: 1.2;
    }
    
    .stat-label {
      font-size: 14px;
      color: var(--color-text-secondary);
      margin-top: 4px;
    }
  }
}

/* Weather Card */
.weather-card {
  border: none;
  background: linear-gradient(120deg, var(--color-primary-light-9) 0%, #fff 100%);
  position: relative;
  overflow: hidden;
  
  &::after {
    content: '';
    position: absolute;
    right: -20px;
    top: -20px;
    width: 200px;
    height: 200px;
    background: radial-gradient(circle, var(--color-primary-light-7) 0%, transparent 70%);
    opacity: 0.5;
    border-radius: 50%;
  }
}

.weather-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  z-index: 2;
  flex-wrap: wrap;
  gap: 20px;
}

.weather-main {
  display: flex;
  align-items: center;
  gap: 24px;
  
  .weather-icon-dynamic {
    color: var(--color-warning);
    animation: float 3s ease-in-out infinite;
  }
  
  .weather-info {
    display: flex;
    flex-direction: column;
    
    .location-row {
      display: flex;
      align-items: center;
      gap: 4px;
      font-size: 16px;
      color: var(--color-text-secondary);
      
      .city-name {
        cursor: pointer;
        border-bottom: 1px dashed transparent;
        transition: all 0.3s;
        
        &:hover {
          color: var(--color-primary);
          border-bottom-color: var(--color-primary);
        }
      }
      
      .city-input {
        width: 120px;
      }
    }
    
    .temp-row {
      display: flex;
      align-items: baseline;
      gap: 12px;
      margin-top: 4px;
      
      .temp {
        font-size: 42px;
        font-weight: 700;
        color: var(--color-text-main);
        line-height: 1;
      }
      
      .cond {
        font-size: 20px;
        color: var(--color-text-secondary);
      }
    }
    
    .meta-row {
      margin-top: 8px;
      font-size: 13px;
      color: var(--color-text-secondary);
      
      .meta-divider {
        margin: 0 8px;
        opacity: 0.5;
      }
    }
  }
}

.weather-tips-wrapper {
  flex: 1;
  min-width: 260px;
  display: flex;
  justify-content: flex-end;
  
  .tip-card {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(4px);
    padding: 12px 20px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    gap: 12px;
    max-width: 100%;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
    
    .tip-icon {
      color: var(--color-primary);
      font-size: 20px;
    }
    
    .tip-text {
      margin: 0;
      font-size: 14px;
      color: var(--color-text-main);
    }
  }
}

@keyframes float {
  0% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
  100% { transform: translateY(0); }
}

/* Quick Actions */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  
  h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: var(--color-text-main);
  }
}

.quick-actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 20px;
  padding: 10px 0;
  
  .action-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    cursor: pointer;
    transition: all 0.3s;
    
    &:hover {
      transform: translateY(-2px);
      
      .action-icon-circle {
        box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        transform: scale(1.05);
      }
      
      span {
        color: var(--color-primary);
      }
    }
    
    .action-icon-circle {
      width: 56px;
      height: 56px;
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      transition: all 0.3s;
      
      &.bg-primary-gradient { background: linear-gradient(135deg, #2ecc71 0%, #27ae60 100%); }
      &.bg-success-gradient { background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); }
      &.bg-info-gradient { background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%); }
      &.bg-warning-gradient { background: linear-gradient(135deg, #f1c40f 0%, #f39c12 100%); }
    }
    
    span {
      font-size: 14px;
      color: var(--color-text-main);
      font-weight: 500;
      transition: color 0.3s;
    }
  }
}

/* Task List */
.task-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.task-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px;
  background-color: var(--color-background);
  border-radius: 10px;
  position: relative;
  overflow: hidden;
  transition: all 0.3s;
  
  &:hover {
    background-color: #ebf5f0;
  }
  
  .task-status-line {
    position: absolute;
    left: 0;
    top: 0;
    bottom: 0;
    width: 4px;
    background-color: var(--color-warning);
  }
  
  .task-content {
    margin-left: 10px;
    
    .task-title {
      font-size: 14px;
      font-weight: 500;
      color: var(--color-text-main);
      margin-bottom: 4px;
    }
    
    .task-time {
      font-size: 12px;
      color: var(--color-text-secondary);
    }
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  
  .empty-text {
    color: var(--color-text-secondary);
    font-size: 14px;
  }
}
</style>

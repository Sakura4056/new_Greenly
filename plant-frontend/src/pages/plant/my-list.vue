<template>
  <div class="my-plant-container">
    <div class="page-header">
      <h2 class="page-title">我的植物库</h2>
      <el-button type="primary" class="add-btn" @click="goAdd">
        <el-icon><Plus /></el-icon> <span>添加植物</span>
      </el-button>
    </div>

    <!-- Filter Bar -->
    <el-card class="filter-card" shadow="never">
      <div class="filter-bar">
        <el-input 
          v-model="queryParams.keyword" 
          placeholder="搜索昵称或品种..." 
          class="filter-item search-input"
          clearable
          @keyup.enter="handleSearch"
        >
          <template #prefix><el-icon><Search /></el-icon></template>
        </el-input>
        
        <el-select 
          v-model="queryParams.status" 
          placeholder="全部状态" 
          class="filter-item"
          clearable
          @change="handleSearch"
        >
          <el-option label="健康" value="HEALTHY" />
          <el-option label="生病" value="SICK" />
          <el-option label="阵亡" value="DEAD" />
          <el-option label="已送人" value="GIFTED" />
        </el-select>

        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          class="filter-item date-picker"
          @change="handleSearch"
        />

        <el-button @click="resetQuery" class="reset-btn">重置</el-button>
      </div>
    </el-card>

    <!-- Content Grid -->
    <div v-loading="loading" class="content-area">
      <transition-group name="list" tag="div" class="plant-grid">
        <div 
          v-for="plant in plantList" 
          :key="plant.id" 
          class="plant-card-wrapper"
        >
          <el-card class="plant-card" shadow="hover" :body-style="{ padding: '0px' }" @click="goDetail(plant.id)">
            <div class="card-image-wrapper">
              <el-image 
                :src="getCoverUrl(plant)"
                class="plant-image"
                fit="cover"
              >
                <template #error>
                  <div class="image-placeholder">
                    <el-icon><Picture /></el-icon>
                  </div>
                </template>
              </el-image>
              <div class="status-badge" :class="plant.status.toLowerCase()">
                {{ getStatusText(plant.status) }}
              </div>
            </div>
            
            <div class="card-content">
              <h3 class="plant-name">{{ plant.nickname }}</h3>
              <div class="plant-meta">
                <div class="meta-item"><el-icon><Location /></el-icon> {{ plant.location || '未设置位置' }}</div>
                <div class="meta-item"><el-icon><Calendar /></el-icon> {{ plant.acquiredDate ? plant.acquiredDate : '未知时间' }} 入手</div>
              </div>
            </div>
          </el-card>
        </div>
      </transition-group>
      
      <!-- Empty State -->
      <el-empty v-if="!loading && plantList.length === 0" description="没有找到植物呢，马上添加一株吧！" />
    </div>

    <!-- Pagination -->
    <div class="pagination-wrapper" v-if="total > 0">
      <el-pagination
        v-model:current-page="queryParams.current"
        v-model:page-size="queryParams.size"
        :total="total"
        background
        layout="prev, pager, next"
        @current-change="loadData"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Search, Plus, Location, Calendar, Picture } from '@element-plus/icons-vue'
import { getMyPlantList } from '@/api/my-plant'
import { DEFAULT_PLANT_IMAGE, normalizeImageUrl } from '@/utils/image'

const router = useRouter()
const route = useRoute()

const loading = ref(false)
const plantList = ref([])
const total = ref(0)
const defaultCover = DEFAULT_PLANT_IMAGE

const queryParams = ref({
  current: 1,
  size: 12,
  keyword: route.query.keyword || '',
  status: '',
  startDate: '',
  endDate: ''
})

const dateRange = ref([])

onMounted(() => {
  loadData()
})

watch(() => route.query.keyword, (newVal) => {
  if (newVal !== undefined) {
    queryParams.value.keyword = newVal
    handleSearch()
  }
})

const loadData = async () => {
  loading.value = true
  try {
    if (dateRange.value && dateRange.value.length === 2) {
      queryParams.value.startDate = dateRange.value[0]
      queryParams.value.endDate = dateRange.value[1]
    } else {
      queryParams.value.startDate = ''
      queryParams.value.endDate = ''
    }
    const res = await getMyPlantList(queryParams.value)
    console.log('My plant list response:', res)
    if (res && res.records) {
      plantList.value = res.records || []
      total.value = res.total || 0
    }
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  queryParams.value.current = 1
  loadData()
}

const resetQuery = () => {
  queryParams.value.keyword = ''
  queryParams.value.status = ''
  dateRange.value = []
  handleSearch()
}

const getStatusText = (status) => {
  const map = {
    HEALTHY: '健康',
    SICK: '生病',
    DEAD: '阵亡',
    GIFTED: '送人'
  }
  return map[status] || status
}

const getCoverUrl = (plant) => normalizeImageUrl(plant?.coverUrl, defaultCover)

const goAdd = () => {
  router.push('/plant/my-add')
}

const goDetail = (id) => {
  router.push(`/plant/my-detail/${id}`)
}
</script>

<style scoped>
.my-plant-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin: 0;
  letter-spacing: -0.5px;
}

.add-btn {
  border-radius: 20px;
  padding: 10px 24px;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(var(--el-color-primary-rgb), 0.3);
  transition: all 0.3s ease;
}

.add-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(var(--el-color-primary-rgb), 0.4);
}

.filter-card {
  margin-bottom: 24px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255,255,255,0.4);
}

.filter-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  align-items: center;
}

.filter-item {
  width: 200px;
}

.date-picker {
  width: 260px !important;
}

.reset-btn {
  border-radius: 8px;
}

.plant-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 24px;
}

.plant-card-wrapper {
  cursor: pointer;
}

.plant-card {
  border-radius: 16px;
  overflow: hidden;
  transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
  border: none;
  background: white;
  box-shadow: 0 8px 24px rgba(149, 157, 165, 0.1);
}

.plant-card:hover {
  transform: translateY(-8px) scale(1.02);
  box-shadow: 0 16px 32px rgba(149, 157, 165, 0.15);
}

.card-image-wrapper {
  position: relative;
  height: 200px;
  overflow: hidden;
}

.plant-image {
  width: 100%;
  height: 100%;
  transition: transform 0.5s ease;
}

.plant-card:hover .plant-image {
  transform: scale(1.08);
}

.image-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--el-fill-color-light);
  color: var(--el-text-color-placeholder);
  font-size: 32px;
}

.status-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  color: white;
  backdrop-filter: blur(4px);
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.status-badge.healthy { background: rgba(103, 194, 58, 0.85); }
.status-badge.sick { background: rgba(230, 162, 60, 0.85); }
.status-badge.dead { background: rgba(245, 108, 108, 0.85); }
.status-badge.gifted { background: rgba(144, 147, 153, 0.85); }

.card-content {
  padding: 20px;
}

.plant-name {
  margin: 0 0 12px 0;
  font-size: 18px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.plant-meta {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: var(--el-text-color-regular);
}

.meta-item .el-icon {
  color: var(--el-color-primary);
}

.pagination-wrapper {
  margin-top: 32px;
  display: flex;
  justify-content: center;
}

/* List Transitions */
.list-enter-active,
.list-leave-active {
  transition: all 0.5s ease;
}
.list-enter-from,
.list-leave-to {
  opacity: 0;
  transform: translateY(30px);
}
</style>

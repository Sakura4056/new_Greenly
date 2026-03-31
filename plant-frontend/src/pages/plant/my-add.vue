<template>
  <div class="my-plant-add-container">
    <el-card class="form-card" shadow="hover">
      <template #header>
        <div class="header-container">
          <el-button link @click="goBack" class="back-btn">
            <el-icon><Back /></el-icon> 返回
          </el-button>
          <span class="title">{{ isEdit ? '编辑我的植物' : '添加我的植物' }}</span>
        </div>
      </template>

      <el-form 
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        class="plant-form"
        @submit.prevent
      >
        <el-row :gutter="40">
          <el-col :span="16">
            <el-form-item label="植物昵称" prop="nickname">
              <el-input v-model="form.nickname" placeholder="给植物起个名字吧，比如：胖橘多肉" />
            </el-form-item>

            <el-form-item label="关联官方图鉴" prop="officialId">
              <el-select 
                v-model="form.officialId" 
                filterable 
                remote 
                reserve-keyword 
                placeholder="搜索官方植物库 (可选)" 
                :remote-method="searchOfficialPlants" 
                :loading="searchLoading"
                clearable
              >
                <el-option 
                  v-for="item in officialPlants" 
                  :key="item.id" 
                  :label="item.name" 
                  :value="item.id" 
                />
              </el-select>
            </el-form-item>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="摆放位置" prop="location">
                  <el-select v-model="form.location" placeholder="选择位置" allow-create filterable class="full-width">
                    <el-option label="主阳台" value="主阳台" />
                    <el-option label="次卧" value="次卧" />
                    <el-option label="客厅" value="客厅" />
                    <el-option label="办公桌" value="办公桌" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="植物来源" prop="source">
                  <el-select v-model="form.source" placeholder="选择来源" allow-create filterable class="full-width">
                    <el-option label="线上购买" value="购买" />
                    <el-option label="花市" value="花市" />
                    <el-option label="赠送" value="赠送" />
                    <el-option label="扦插繁殖" value="扦插" />
                    <el-option label="野外带回" value="野外" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="入住日期" prop="acquiredDate">
                  <el-date-picker 
                    v-model="form.acquiredDate" 
                    type="date" 
                    placeholder="选个好日子" 
                    value-format="YYYY-MM-DD" 
                    class="full-width"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="当前状态" prop="status">
                  <el-select v-model="form.status" placeholder="状态" class="full-width">
                    <el-option label="健康" value="HEALTHY" />
                    <el-option label="生病" value="SICK" />
                    <el-option label="阵亡" value="DEAD" />
                    <el-option label="送人" value="GIFTED" />
                  </el-select>
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item label="备注说明" prop="notes">
              <el-input 
                v-model="form.notes" 
                type="textarea" 
                :rows="4" 
                placeholder="记录它的特殊喜好、养护经验等..." 
              />
            </el-form-item>
          </el-col>

          <el-col :span="8">
            <div class="cover-uploader-wrapper">
              <div class="uploader-label">植物封面图</div>
              <el-upload
                class="cover-uploader"
                action="/api/photo/upload"
                :show-file-list="false"
                :headers="headers"
                :on-success="handleUploadSuccess"
                :before-upload="beforeUpload"
              >
                <img v-if="form.coverUrl" :src="form.coverUrl" class="cover-preview" />
                <div v-else class="upload-trigger">
                  <el-icon class="upload-icon"><Plus /></el-icon>
                  <span class="upload-text">点击上传封面</span>
                </div>
              </el-upload>
              <div class="cover-tip">建议尺寸 800x800，支持 jpg/png 格式</div>
            </div>
          </el-col>
        </el-row>

        <div class="form-actions">
          <el-button @click="goBack" class="cancel-btn">取消</el-button>
          <el-button type="primary" :loading="submitLoading" class="submit-btn" @click="submitForm">
            <el-icon><Check /></el-icon> <span>保存信息</span>
          </el-button>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Back, Plus, Check } from '@element-plus/icons-vue'
import { getMyPlantById, addMyPlant, updateMyPlant } from '@/api/my-plant'
import { getOfficialPlantList } from '@/api/plant'

const router = useRouter()
const route = useRoute()

const formRef = ref(null)
const submitLoading = ref(false)
const isEdit = ref(false)

const form = reactive({
  id: '',
  nickname: '',
  officialId: null,
  location: '',
  source: '',
  acquiredDate: '',
  status: 'HEALTHY',
  coverUrl: '',
  notes: ''
})

const rules = {
  nickname: [
    { required: true, message: '请输入植物昵称', trigger: 'blur' },
    { min: 1, max: 100, message: '长度在 1 到 100 个字符', trigger: 'blur' }
  ]
}

const headers = ref({
  Authorization: 'Bearer ' + localStorage.getItem('token') || ''
})

const searchLoading = ref(false)
const officialPlants = ref([])

onMounted(() => {
  const id = route.query.id || route.params.id
  if (id) {
    isEdit.value = true
    form.id = id
    loadPlantData(id)
  }
})

const loadPlantData = async (id) => {
  try {
    const res = await getMyPlantById(id)
    if (res.data) {
      Object.assign(form, res.data)
      if (form.officialId) {
        // Just for display, mock a simple option if not loaded
        officialPlants.value = [{ id: form.officialId, name: '已关联官方植物' }]
      }
    }
  } catch (err) {
    ElMessage.error('加载植物数据失败')
  }
}

const searchOfficialPlants = async (query) => {
  if (query) {
    searchLoading.value = true
    try {
      const res = await getOfficialPlantList({ keyword: query, size: 20 })
      officialPlants.value = res.data.records || []
    } catch (e) {
      console.error(e)
    } finally {
      searchLoading.value = false
    }
  } else {
    officialPlants.value = []
  }
}

const handleUploadSuccess = (res) => {
  if (res.code === 200) {
    form.coverUrl = res.data.url
    ElMessage.success('封面上传成功')
  } else {
    ElMessage.error(res.message || '上传失败')
  }
}

const beforeUpload = (file) => {
  const isImage = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/webp'
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isImage) ElMessage.error('上传图片只能是 JPG/PNG/WEBP 格式!')
  if (!isLt5M) ElMessage.error('上传图片大小不能超过 5MB!')
  
  return isImage && isLt5M
}

const submitForm = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        if (isEdit.value) {
          await updateMyPlant(form.id, form)
          ElMessage.success('更新成功')
        } else {
          await addMyPlant(form)
          ElMessage.success('添加成功')
        }
        router.back()
      } catch (err) {
        ElMessage.error('保存失败')
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const goBack = () => {
  router.back()
}
</script>

<style scoped>
.my-plant-add-container {
  padding: 32px;
  max-width: 1000px;
  margin: 0 auto;
}

.form-card {
  border-radius: 16px;
  border: none;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  box-shadow: 0 12px 36px rgba(110, 136, 110, 0.1);
  overflow: hidden;
}

.header-container {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-btn {
  font-size: 14px;
  color: var(--el-text-color-regular);
}

.back-btn:hover {
  color: var(--el-color-primary);
}

.title {
  font-size: 20px;
  font-weight: bold;
  color: var(--el-text-color-primary);
}

.plant-form {
  padding: 24px 0;
}

.full-width {
  width: 100%;
}

.cover-uploader-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 20px;
}

.uploader-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-regular);
  margin-bottom: 16px;
  width: 100%;
}

.cover-uploader {
  width: 100%;
  aspect-ratio: 1;
  border: 2px dashed var(--el-border-color);
  border-radius: 12px;
  cursor: pointer;
  position: relative;
  overflow: hidden;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  background-color: var(--el-fill-color-lighter);
}

.cover-uploader:hover {
  border-color: var(--el-color-primary);
  background-color: var(--el-color-primary-light-9);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(var(--el-color-primary-rgb), 0.1);
}

.cover-preview {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: cover;
}

.upload-trigger {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: var(--el-text-color-secondary);
}

.upload-icon {
  font-size: 32px;
  margin-bottom: 8px;
  color: var(--el-color-primary-light-3);
  transition: transform 0.3s ease;
}

.cover-uploader:hover .upload-icon {
  transform: scale(1.1);
  color: var(--el-color-primary);
}

.upload-text {
  font-size: 13px;
}

.cover-tip {
  margin-top: 12px;
  font-size: 12px;
  color: var(--el-text-color-placeholder);
  text-align: center;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-top: 40px;
  padding-top: 24px;
  border-top: 1px solid var(--el-border-color-lighter);
}

.submit-btn {
  padding: 10px 32px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(var(--el-color-primary-rgb), 0.3);
  transition: all 0.3s;
}

.submit-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 16px rgba(var(--el-color-primary-rgb), 0.4);
}

.cancel-btn {
  padding: 10px 24px;
  border-radius: 8px;
}
</style>

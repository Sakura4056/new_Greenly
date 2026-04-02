import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import router from '@/router'

const service = axios.create({
    baseURL: import.meta.env.VITE_API_BASE_URL,
    timeout: 10000,
    headers: {
        'Content-Type': 'application/json'
    }
})

// Request Interceptor
service.interceptors.request.use(
    config => {
        const userStore = useUserStore()
        const token = userStore.token
        console.log('Request token:', token)
        if (token) {
            config.headers.Authorization = `Bearer ${token}`
        }
        return config
    },
    error => Promise.reject(error)
)

// Response Interceptor
service.interceptors.response.use(
    response => {
        const res = response.data
        const backendMessage = res.msg || res.message || 'Error'

        if (res.code !== 200) {
            ElMessage({
                message: backendMessage,
                type: 'error',
                duration: 5 * 1000
            })

            const error = new Error(backendMessage)
            error.response = {
                status: res.code,
                data: res
            }
            return Promise.reject(error)
        }

        const payload = res.data
        if (payload !== null && typeof payload === 'object' && !Object.prototype.hasOwnProperty.call(payload, 'data')) {
            Object.defineProperty(payload, 'data', {
                value: payload,
                enumerable: false,
                configurable: true
            })
        }

        return payload
    },
    error => {
        console.error('err' + error)

        const backendMessage = error.response?.data?.msg || error.response?.data?.message
        let message = backendMessage || error.message

        if (error.response) {
            const status = error.response.status
            switch (status) {
                case 401: {
                    message = backendMessage || '未登录或 Token 过期，请重新登录'
                    const userStore = useUserStore()
                    userStore.logout()
                    router.push(`/login?redirect=${router.currentRoute.value.fullPath}`)
                    break
                }
                case 403:
                    message = backendMessage || '拒绝访问：您没有权限执行此操作'
                    break
                case 404:
                    message = backendMessage || '请求的资源不存在'
                    break
                case 500:
                    message = backendMessage || '服务器内部错误'
                    break
                default:
                    message = backendMessage || `连接错误 ${status}`
            }
        }

        ElMessage({
            message,
            type: 'error',
            duration: 5 * 1000
        })
        return Promise.reject(error)
    }
)

export default service

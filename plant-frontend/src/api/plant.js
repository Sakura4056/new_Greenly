import request from './request'

// Get official plant list
export function getOfficialPlantList(params) {
    return request({
        url: '/plant/official/query',
        method: 'get',
        params
    })
}

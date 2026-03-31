package com.plant.backend.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.plant.backend.dto.CareScheduleDTO;
import com.plant.backend.entity.CareSchedule;
import com.plant.backend.exception.BusinessException;
import com.plant.backend.mapper.CareScheduleMapper;
import com.plant.backend.service.CareScheduleService;
import com.plant.backend.util.ResultCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import org.apache.commons.lang3.StringUtils;

@Service
@RequiredArgsConstructor
public class CareScheduleServiceImpl extends com.baomidou.mybatisplus.extension.service.impl.ServiceImpl<CareScheduleMapper, CareSchedule> implements CareScheduleService {

    private final CareScheduleMapper careScheduleMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CareSchedule add(CareScheduleDTO.AddRequest request) {
        CareSchedule schedule = new CareSchedule();
        schedule.setUserId(request.getUserId());
        schedule.setPlantId(request.getPlantId());
        schedule.setPlantSource(request.getPlantSource());

        String plantName = request.getPlantName();
        String taskName = request.getTaskName();
        if (plantName != null && !taskName.startsWith(plantName)) {
            schedule.setTaskName(plantName + " " + taskName);
        } else {
            schedule.setTaskName(taskName);
        }
        schedule.setDueTime(request.getDueTime());
        schedule.setRecurrenceType(request.getRecurrenceType());
        schedule.setRecurrenceInterval(request.getRecurrenceInterval());
        schedule.setReminderConfig(request.getReminderConfig());
        schedule.setStatus(0);
        schedule.setCreateTime(LocalDateTime.now());

        careScheduleMapper.insert(schedule);
        return schedule;
    }

    @Override
    public CareSchedule updateSchedule(CareScheduleDTO.UpdateRequest request, Long userId) {
        CareSchedule schedule = careScheduleMapper.selectById(request.getId());
        if (schedule == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "计划不存在");
        }
        if (!schedule.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }
        if (schedule.getStatus() != 0) {
            throw new BusinessException(ResultCode.BUSINESS_ERROR.getCode(), "已完成或逾期的计划不可修改");
        }

        if (request.getTaskName() != null)
            schedule.setTaskName(request.getTaskName());
        if (request.getDueTime() != null)
            schedule.setDueTime(request.getDueTime());
        if (request.getRecurrenceType() != null)
            schedule.setRecurrenceType(request.getRecurrenceType());
        if (request.getRecurrenceInterval() != null)
            schedule.setRecurrenceInterval(request.getRecurrenceInterval());
        if (request.getReminderConfig() != null)
            schedule.setReminderConfig(request.getReminderConfig());

        careScheduleMapper.updateById(schedule);
        return schedule;
    }

    @Override
    public void deleteSchedule(Long scheduleId, Long userId) {
        CareSchedule schedule = careScheduleMapper.selectById(scheduleId);
        if (schedule == null) {
            throw new BusinessException(ResultCode.NOT_FOUND.getCode(), "计划不存在");
        }
        if (!schedule.getUserId().equals(userId)) {
            throw new BusinessException(ResultCode.FORBIDDEN);
        }
        careScheduleMapper.deleteById(scheduleId);
    }

    @Override
    public Page<CareSchedule> query(CareScheduleDTO.Query query, Long currentUserId, String currentRole) {
        if (!"ADMIN".equals(currentRole)) {
            if (query.getUserId() != null && !query.getUserId().equals(currentUserId)) {
                throw new BusinessException(ResultCode.FORBIDDEN);
            }
            query.setUserId(currentUserId);
        }

        if (query.getUserId() != null) {
            markOverdue(query.getUserId());
        }

        Page<CareSchedule> page = new Page<>(query.getPageNum(), query.getPageSize());
        LambdaQueryWrapper<CareSchedule> wrapper = new LambdaQueryWrapper<>();
        if (query.getUserId() != null)
            wrapper.eq(CareSchedule::getUserId, query.getUserId());
        if (query.getPlantId() != null)
            wrapper.eq(CareSchedule::getPlantId, query.getPlantId());
        if (query.getStatus() != null)
            wrapper.eq(CareSchedule::getStatus, query.getStatus());
            
        if (StringUtils.isNotBlank(query.getKeyword()))
            wrapper.like(CareSchedule::getTaskName, query.getKeyword());
        if (query.getStartDate() != null)
            wrapper.ge(CareSchedule::getDueTime, query.getStartDate().atStartOfDay());
        if (query.getEndDate() != null)
            wrapper.le(CareSchedule::getDueTime, query.getEndDate().atTime(23, 59, 59));

        return careScheduleMapper.selectPage(page, wrapper);
    }

    private void markOverdue(Long userId) {
        LambdaUpdateWrapper<CareSchedule> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(CareSchedule::getUserId, userId)
                .eq(CareSchedule::getStatus, 0)
                .lt(CareSchedule::getDueTime, LocalDateTime.now())
                .set(CareSchedule::getStatus, 2);
        careScheduleMapper.update(null, wrapper);
    }
}

package com.plant.backend.task;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.plant.backend.entity.CareSchedule;

import com.plant.backend.entity.ReminderConfig;
import com.plant.backend.mapper.CareScheduleMapper;
import com.plant.backend.mapper.ReminderConfigMapper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.plant.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class CareTask {

    private final CareScheduleMapper careScheduleMapper;
    private final NotificationService notificationService;
    private final ReminderConfigMapper reminderConfigMapper;

    // 每小时执行一次: 0 0 * * * ?
    @Scheduled(cron = "0 0 * * * ?")
    public void scanDueSchedules() {
        scanDueSchedules(false);
    }

    public void scanDueSchedules(boolean isManualTest) {
        log.info("正在扫描到期的养护计划（每日汇总）... 手动测试: {}", isManualTest);

        // 查找截止时间 <= 今天结束 (23:59:59) 且未完成的任务
        LocalDateTime todayEnd = LocalDateTime.now().withHour(23).withMinute(59).withSecond(59);

        LambdaQueryWrapper<CareSchedule> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CareSchedule::getStatus, 0)
                .le(CareSchedule::getDueTime, todayEnd);

        List<CareSchedule> dueList = careScheduleMapper.selectList(wrapper);

        if (dueList.isEmpty()) {
            return;
        }

        // 按用户分组
        java.util.Map<Long, List<CareSchedule>> userMap = dueList.stream()
                .collect(java.util.stream.Collectors.groupingBy(CareSchedule::getUserId));

        int currentHour = LocalDateTime.now().getHour();
        ObjectMapper mapper = new ObjectMapper();

        // 遍历每个用户发送汇总
        userMap.forEach((userId, schedules) -> {
            // 检查用户的配置
            LambdaQueryWrapper<ReminderConfig> configWrapper = new LambdaQueryWrapper<>();
            configWrapper.eq(ReminderConfig::getUserId, userId);
            ReminderConfig config = reminderConfigMapper.selectOne(configWrapper);

            int targetHour = 9; // 默认早上9点

            if (config != null && config.getSceneConfig() != null) {
                try {
                    JsonNode node = mapper.readTree(config.getSceneConfig());
                    if (node.has("summaryTime")) {
                        String timeStr = node.get("summaryTime").asText(); // e.g. "09:00"
                        if (timeStr != null && timeStr.length() >= 2) {
                            targetHour = Integer.parseInt(timeStr.substring(0, 2));
                        }
                    }
                } catch (Exception e) {
                    log.warn("Failed to parse summaryTime for user {}", userId, e);
                }
            }

            // 如果当前小时等于目标小时，或是手动触发的测试，则发送
            if (currentHour == targetHour || isManualTest) {
                notificationService.sendCareReminderSummary(userId, schedules);
            }
        });
    }
}

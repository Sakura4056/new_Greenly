-- =================================================================
-- 植物护理管理系统的 MySQL 完整数据库脚本
-- 包括：创建数据库、所有表结构、初始数据
-- =================================================================

-- 1. 创建数据库
DROP DATABASE IF EXISTS db_plant_official;
CREATE DATABASE db_plant_official CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE db_plant_official;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 2. 创建表结构

-- ----------------------------
-- 用户表结构
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`
(
    `user_id`     bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `username`    varchar(50)  NOT NULL COMMENT '用户名',
    `password`    varchar(100) NOT NULL COMMENT '加密密码',
    `email`       varchar(100) DEFAULT NULL COMMENT '邮箱',
    `phone`       varchar(20)  DEFAULT NULL COMMENT '手机号',
    `role`        varchar(20)  DEFAULT 'USER' COMMENT '角色：USER/ADMIN',
    `deleted`     tinyint(2)   DEFAULT 0 COMMENT '逻辑删除：0 正常，1 删除',
    `create_time` datetime     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户表';

-- ----------------------------
-- 官方植物库表结构
-- ----------------------------
DROP TABLE IF EXISTS `official_plant`;
CREATE TABLE `official_plant`
(
    `id`          bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `name`        varchar(100) NOT NULL COMMENT '名称',
    `genus`       varchar(100) DEFAULT NULL COMMENT '属',
    `species`     varchar(100) DEFAULT NULL COMMENT '种',
    `description` text COMMENT '描述',
    `create_time` datetime     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_name` (`name`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='官方植物库';

-- ----------------------------
-- 个人植物库表结构
-- ----------------------------
DROP TABLE IF EXISTS `my_plant`;
CREATE TABLE `my_plant` (
    `id`            bigint(20)   NOT NULL AUTO_INCREMENT,
    `user_id`       bigint(20)   NOT NULL COMMENT '用户ID',
    `official_id`   bigint(20)   DEFAULT NULL COMMENT '关联官方植物ID（可为空）',
    `nickname`      varchar(100) NOT NULL COMMENT '昵称',
    `location`      varchar(50)  DEFAULT NULL COMMENT '位置：阳台/客厅/卧室/办公桌',
    `source`        varchar(50)  DEFAULT NULL COMMENT '来源：购买/赠送/扦插/野外',
    `acquired_date` date         DEFAULT NULL COMMENT '获取日期',
    `status`        varchar(20)  DEFAULT 'HEALTHY' COMMENT 'HEALTHY/SICK/DEAD/GIFTED',
    `cover_url`     varchar(255) DEFAULT NULL COMMENT '封面图URL',
    `notes`         text         COMMENT '备注',
    `deleted`       tinyint(2)   DEFAULT 0,
    `create_time`   datetime     DEFAULT CURRENT_TIMESTAMP,
    `update_time`   datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='我的植物';

-- ----------------------------
-- 养护计划表结构
-- ----------------------------
DROP TABLE IF EXISTS `care_schedule`;
CREATE TABLE `care_schedule`
(
    `id`              bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id`         bigint(20)   NOT NULL COMMENT '用户 ID',
    `plant_id`        bigint(20)   NOT NULL COMMENT '植物 ID',
    `plant_source`    varchar(20)  NOT NULL COMMENT '来源：OFFICIAL/LOCAL',
    `task_name`       varchar(100) NOT NULL COMMENT '任务名称',
    `due_time`        datetime     NOT NULL COMMENT '截止时间',
    `status`          tinyint(2) DEFAULT 0 COMMENT '0:未完成，1:已完成，2:逾期',
    `recurrence_type` varchar(20) DEFAULT 'NONE' COMMENT '重复类型：NONE/DAY/MONTH/YEAR',
    `recurrence_interval` int(11) DEFAULT 0 COMMENT '重复间隔',
    `reminder_config` text COMMENT '提醒配置 JSON',
    `create_time`     datetime   DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`     datetime   DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_status` (`user_id`, `status`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='养护计划表';

-- ----------------------------
-- 养护记录表结构
-- ----------------------------
DROP TABLE IF EXISTS `care_record`;
CREATE TABLE `care_record`
(
    `id`           bigint(20)  NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id`      bigint(20)  NOT NULL COMMENT '用户 ID',
    `plant_id`     bigint(20)  NOT NULL COMMENT '植物 ID',
    `plant_source` varchar(20) NOT NULL COMMENT '植物来源',
    `schedule_id`  bigint(20)   DEFAULT NULL COMMENT '关联计划 ID',
    `record_time`  datetime    NOT NULL COMMENT '记录时间',
    `operations`   text COMMENT '操作详情 JSON',
    `remarks`      varchar(255) DEFAULT NULL COMMENT '备注',
    `create_time`  datetime     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_time` (`user_id`, `record_time`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='养护记录表';

-- ----------------------------
-- 成长相册表结构
-- ----------------------------
DROP TABLE IF EXISTS `plant_photo`;
CREATE TABLE `plant_photo`
(
    `id`           bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id`      bigint(20)   NOT NULL COMMENT '用户 ID',
    `plant_id`     bigint(20)   NOT NULL COMMENT '植物 ID',
    `plant_source` varchar(20)  NOT NULL COMMENT '植物来源',
    `is_public`    tinyint(1)   DEFAULT 0 COMMENT '0:私有，1:公开',
    `remarks`      varchar(255) DEFAULT NULL COMMENT '备注',
    `url`          varchar(255) NOT NULL COMMENT '访问 URL',
    `file_path`    varchar(255) DEFAULT NULL COMMENT '物理路径',
    `capture_time` datetime     DEFAULT NULL COMMENT '拍摄时间',
    `create_time`  datetime     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_plant` (`user_id`, `plant_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='成长相册表';

-- ----------------------------
-- 提醒配置表结构
-- ----------------------------
DROP TABLE IF EXISTS `reminder_config`;
CREATE TABLE `reminder_config`
(
    `id`            bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id`       bigint(20) NOT NULL COMMENT '用户 ID',
    `email`         varchar(100) DEFAULT NULL COMMENT '通知邮箱',
    `phone`         varchar(20)  DEFAULT NULL COMMENT '通知手机',
    `popup_enabled` tinyint(1)   DEFAULT 1 COMMENT '弹窗提醒',
    `bell_enabled`  tinyint(1)   DEFAULT 1 COMMENT '铃声提醒',
    `scene_config`  text COMMENT '场景配置 JSON',
    `create_time`   datetime     DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`   datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user` (`user_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='提醒配置表';

-- ----------------------------
-- 提醒通知表结构
-- ----------------------------
DROP TABLE IF EXISTS `reminder`;
CREATE TABLE `reminder`
(
    `id`          bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `user_id`     bigint(20)   NOT NULL COMMENT '用户 ID',
    `scene`       varchar(50)  NOT NULL COMMENT '场景：careSchedule/plantAudit...',
    `business_id` bigint(20) DEFAULT NULL COMMENT '业务 ID',
    `title`       varchar(100) NOT NULL COMMENT '标题',
    `content`     text COMMENT '内容',
    `is_read`     tinyint(1) DEFAULT 0 COMMENT '0:未读，1:已读',
    `create_time` datetime   DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_read` (`user_id`, `is_read`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='提醒通知表';

-- 3. 插入初始数据

-- 插入管理员用户（密码：admin123）
INSERT INTO `sys_user` (`username`, `password`, `email`, `phone`, `role`) VALUES
('admin', '$2a$10$E5p8tQf7s6d5r4e3w2q1.uh0JZ3t2K1X9Y8W7V6U5T4S3R2Q1P0', 'admin@example.com', '13800138000', 'ADMIN'),
('user', '$2a$10$E5p8tQf7s6d5r4e3w2q1.uh0JZ3t2K1X9Y8W7V6U5T4S3R2Q1P0', 'user@example.com', '13900139000', 'USER');

-- 插入官方植物数据
INSERT INTO `official_plant` (`name`, `genus`, `species`, `description`) VALUES
('绿萝', '麒麟叶属', 'Epipremnum aureum', '绿萝是天南星科麒麟叶属的常绿藤本植物，具有净化空气的作用，适合室内栽培。'),
('多肉植物', '景天属', 'Sedum', '多肉植物是一类茎、叶或根能够贮存水分的植物，具有很强的耐旱性，适合懒人养护。'),
('吊兰', '吊兰属', 'Chlorophytum comosum', '吊兰是百合科吊兰属的多年生常绿草本植物，具有吸收甲醛的能力，是室内常见的观叶植物。'),
('发财树', '瓜栗属', 'Pachira aquatica', '发财树是木棉科瓜栗属的常绿乔木，象征着财富和好运，是常见的室内观赏植物。'),
('芦荟', '芦荟属', 'Aloe vera', '芦荟是百合科芦荟属的多年生草本植物，具有美容、药用价值，适合室内栽培。');

-- 插入个人植物数据
INSERT INTO `my_plant` (`user_id`, `official_id`, `nickname`, `location`, `source`, `acquired_date`, `status`, `cover_url`, `notes`) VALUES
(2, 1, '我的绿萝', '阳台', '购买', '2024-01-01', 'HEALTHY', 'https://example.com/photos/pothos.jpg', '长势良好，每周浇水一次'),
(2, 2, '多肉宝宝', '办公桌', '赠送', '2024-02-15', 'HEALTHY', 'https://example.com/photos/succulent.jpg', '喜欢阳光，耐旱'),
(2, 3, '吊兰君', '客厅', '购买', '2024-03-10', 'HEALTHY', 'https://example.com/photos/spider-plant.jpg', '净化空气效果好');

-- 插入养护计划数据
INSERT INTO `care_schedule` (`user_id`, `plant_id`, `plant_source`, `task_name`, `due_time`, `status`, `recurrence_type`, `recurrence_interval`, `reminder_config`) VALUES
(2, 1, 'LOCAL', '绿萝浇水', '2024-04-05 10:00:00', 0, 'WEEK', 1, '{"notifyBefore": 1, "channels": ["popup", "email"]}'),
(2, 2, 'LOCAL', '多肉植物晒太阳', '2024-04-06 09:00:00', 0, 'DAY', 1, '{"notifyBefore": 0, "channels": ["popup"]}'),
(2, 3, 'LOCAL', '吊兰施肥', '2024-04-10 14:00:00', 0, 'MONTH', 1, '{"notifyBefore": 2, "channels": ["popup", "email"]}');

-- 插入养护记录数据
INSERT INTO `care_record` (`user_id`, `plant_id`, `plant_source`, `schedule_id`, `record_time`, `operations`, `remarks`) VALUES
(2, 1, 'LOCAL', 1, '2024-03-29 10:30:00', '{"water": true, "fertilize": false, "prune": false}', '浇水500ml'),
(2, 2, 'LOCAL', NULL, '2024-03-30 15:00:00', '{"water": false, "fertilize": false, "prune": true}', '修剪了枯叶'),
(2, 3, 'LOCAL', NULL, '2024-04-01 14:30:00', '{"water": true, "fertilize": true, "prune": false}', '浇水并施肥');

-- 插入成长相册数据
INSERT INTO `plant_photo` (`user_id`, `plant_id`, `plant_source`, `is_public`, `remarks`, `url`, `file_path`, `capture_time`) VALUES
(2, 1, 'LOCAL', 0, '刚买的时候', 'https://example.com/photos/pothos-1.jpg', '/path/to/photos/pothos-1.jpg', '2024-01-01 12:00:00'),
(2, 1, 'LOCAL', 0, '一个月后', 'https://example.com/photos/pothos-2.jpg', '/path/to/photos/pothos-2.jpg', '2024-02-01 12:00:00'),
(2, 2, 'LOCAL', 1, '多肉特写', 'https://example.com/photos/succulent-1.jpg', '/path/to/photos/succulent-1.jpg', '2024-02-15 14:00:00');

-- 插入提醒配置数据
INSERT INTO `reminder_config` (`user_id`, `email`, `phone`, `popup_enabled`, `bell_enabled`, `scene_config`) VALUES
(1, 'admin@example.com', '13800138000', 1, 1, '{"careSchedule": {"enabled": true, "notifyBefore": 1}, "plantAudit": {"enabled": true}}'),
(2, 'user@example.com', '13900139000', 1, 1, '{"careSchedule": {"enabled": true, "notifyBefore": 1}, "plantAudit": {"enabled": true}}');

-- 插入提醒通知数据
INSERT INTO `reminder` (`user_id`, `scene`, `business_id`, `title`, `content`, `is_read`) VALUES
(2, 'careSchedule', 1, '养护提醒：绿萝浇水', '您的绿萝需要浇水了，请及时处理。', 0),
(2, 'careSchedule', 2, '养护提醒：多肉植物晒太阳', '今天适合让您的多肉植物晒太阳。', 0),
(2, 'system', NULL, '系统通知', '您的账户已成功注册，欢迎使用植物护理管理系统。', 1);

SET FOREIGN_KEY_CHECKS = 1;

-- 4. 数据库设置完成
SELECT '数据库设置完成' AS message;
-- ==============================================================
-- 植物护理管理系统 完整SQL
-- 数据库：db_plant
-- 密码统一：123456
-- ==============================================================

DROP DATABASE IF EXISTS db_plant;
CREATE DATABASE db_plant CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_plant;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `user_id`     bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `username`    varchar(50)  NOT NULL COMMENT '用户名',
    `password`    varchar(100) NOT NULL COMMENT '加密密码',
    `email`       varchar(100) DEFAULT NULL COMMENT '邮箱',
    `phone`       varchar(20)  DEFAULT NULL COMMENT '手机号',
    `role`        varchar(20)  DEFAULT 'USER' COMMENT 'USER/ADMIN',
    `deleted`     tinyint(2)   DEFAULT 0 COMMENT '0正常 1删除',
    `create_time` datetime     DEFAULT CURRENT_TIMESTAMP,
    `update_time` datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ----------------------------
-- 官方植物库
-- ----------------------------
DROP TABLE IF EXISTS `official_plant`;
CREATE TABLE `official_plant` (
    `id`          bigint(20)   NOT NULL AUTO_INCREMENT,
    `name`        varchar(100) NOT NULL COMMENT '植物名',
    `genus`       varchar(100) DEFAULT NULL COMMENT '属',
    `species`     varchar(100) DEFAULT NULL COMMENT '种',
    `description` text COMMENT '描述',
    `create_time` datetime     DEFAULT CURRENT_TIMESTAMP,
    `update_time` datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='官方植物库';

-- ----------------------------
-- 我的植物
-- ----------------------------
DROP TABLE IF EXISTS `my_plant`;
CREATE TABLE `my_plant` (
    `id`            bigint(20)   NOT NULL AUTO_INCREMENT,
    `user_id`       bigint(20)   NOT NULL,
    `official_id`   bigint(20)   DEFAULT NULL,
    `nickname`      varchar(100) NOT NULL,
    `location`      varchar(50)  DEFAULT NULL,
    `source`        varchar(50)  DEFAULT NULL,
    `acquired_date` date         DEFAULT NULL,
    `status`        varchar(20)  DEFAULT 'HEALTHY',
    `cover_url`     varchar(255) DEFAULT NULL,
    `notes`         text COMMENT '备注',
    `deleted`       tinyint(2)   DEFAULT 0,
    `create_time`   datetime     DEFAULT CURRENT_TIMESTAMP,
    `update_time`   datetime     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='我的植物';

-- ----------------------------
-- 养护计划
-- ----------------------------
DROP TABLE IF EXISTS `care_schedule`;
CREATE TABLE `care_schedule` (
    `id`                  bigint(20)   NOT NULL AUTO_INCREMENT,
    `user_id`             bigint(20)   NOT NULL,
    `plant_id`            bigint(20)   NOT NULL,
    `plant_source`        varchar(20)  NOT NULL,
    `task_name`           varchar(100) NOT NULL,
    `due_time`            datetime     NOT NULL,
    `status`              tinyint(2)   DEFAULT 0,
    `recurrence_type`     varchar(20)  DEFAULT 'NONE',
    `recurrence_interval` int(11)      DEFAULT 0,
    `reminder_config`     text,
    `create_time`         datetime DEFAULT CURRENT_TIMESTAMP,
    `update_time`         datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_status` (`user_id`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='养护计划表';

-- ----------------------------
-- 养护记录
-- ----------------------------
DROP TABLE IF EXISTS `care_record`;
CREATE TABLE `care_record` (
    `id`           bigint(20)  NOT NULL AUTO_INCREMENT,
    `user_id`      bigint(20)  NOT NULL,
    `plant_id`     bigint(20)  NOT NULL,
    `plant_source` varchar(20) NOT NULL,
    `schedule_id`  bigint(20)  DEFAULT NULL,
    `record_time`  datetime    NOT NULL,
    `operations`   text,
    `remarks`      varchar(255) DEFAULT NULL,
    `create_time`  datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_time` (`user_id`,`record_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='养护记录表';

-- ----------------------------
-- 成长相册（已修复：plant_id 允许为空）
-- ----------------------------
DROP TABLE IF EXISTS `plant_photo`;
CREATE TABLE `plant_photo` (
    `id`           bigint(20)   NOT NULL AUTO_INCREMENT,
    `user_id`      bigint(20)   NOT NULL,
    `plant_id`     bigint(20)   NULL COMMENT '植物ID（允许为空）',
    `plant_source` varchar(20)  NULL,
    `is_public`    tinyint(1)   DEFAULT 0,
    `remarks`      varchar(255) DEFAULT NULL,
    `url`          varchar(255) NOT NULL,
    `file_path`    varchar(255) DEFAULT NULL,
    `capture_time` datetime     DEFAULT NULL,
    `create_time`  datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_plant` (`user_id`,`plant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成长相册表';

-- ----------------------------
-- 提醒配置
-- ----------------------------
DROP TABLE IF EXISTS `reminder_config`;
CREATE TABLE `reminder_config` (
    `id`            bigint(20) NOT NULL AUTO_INCREMENT,
    `user_id`       bigint(20) NOT NULL,
    `email`         varchar(100) DEFAULT NULL,
    `phone`         varchar(20)  DEFAULT NULL,
    `popup_enabled` tinyint(1)   DEFAULT 1,
    `bell_enabled`  tinyint(1)   DEFAULT 1,
    `scene_config`  text,
    `create_time`   datetime DEFAULT CURRENT_TIMESTAMP,
    `update_time`   datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提醒配置表';

-- ----------------------------
-- 提醒通知
-- ----------------------------
DROP TABLE IF EXISTS `reminder`;
CREATE TABLE `reminder` (
    `id`          bigint(20)   NOT NULL AUTO_INCREMENT,
    `user_id`     bigint(20)   NOT NULL,
    `scene`       varchar(50)  NOT NULL,
    `business_id` bigint(20) DEFAULT NULL,
    `title`       varchar(100) NOT NULL,
    `content`     text,
    `is_read`     tinyint(1) DEFAULT 0,
    `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_read` (`user_id`,`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提醒通知表';

-- ==============================================================
-- 初始化数据
-- ==============================================================

INSERT INTO `sys_user` VALUES
(1,'admin','$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e','admin@plant.com','13800138000','ADMIN',0,NOW(),NULL),
(2,'user01','$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e','user01@qq.com','13900139001','USER',0,NOW(),NULL),
(3,'user02','$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e','user02@163.com','13900139002','USER',0,NOW(),NULL),
(4,'user03','$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e','user03@plant.com','13900139003','USER',0,NOW(),NULL),
(5,'user04','$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e','user04@sina.com','13900139004','USER',0,NOW(),NULL);

INSERT INTO `official_plant` VALUES
(1,'绿萝','麒麟叶属','绿萝','耐阴好养，适合室内摆放，能有效净化空气，是新手的首选。',NOW(),NULL),
(2,'多肉-观音莲','景天属','多肉植物','耐旱，少浇水，需要阳光充足的环境。叶片如莲花般排列。',NOW(),NULL),
(3,'吊兰','吊兰属','吊兰','著名的垂吊植物，适应性强，能吸收有害气体，适合悬挂观赏。',NOW(),NULL),
(4,'发财树','瓜栗属','发财树','寓意招财进宝，耐旱不喜积水，适合放在客厅或办公室。',NOW(),NULL),
(5,'富贵竹','龙血树属','富贵竹','水培土培均可，象征吉祥富贵，四季常绿，极其好养。',NOW(),NULL),
(6,'龟背竹','龟背竹属','龟背竹','网红绿植，叶片宽大有特点，非常适合现代家居风格的装饰。',NOW(),NULL),
(7,'虎皮兰','虎尾兰属','虎尾兰','空气净化小能手，释放氧气能力强，极其耐旱。',NOW(),NULL);

INSERT INTO `care_schedule` VALUES
(1,1,1,'OFFICIAL','绿萝浇水',DATE_ADD(NOW(),INTERVAL 1 DAY),0,'DAY',2,'{"advanceHours":2}',NOW(),NULL),
(2,2,2,'OFFICIAL','多肉光照',DATE_ADD(NOW(),INTERVAL 2 DAY),0,'WEEK',1,'{"advanceHours":1}',NOW(),NULL),
(3,3,3,'OFFICIAL','吊兰施薄肥',DATE_ADD(NOW(),INTERVAL 5 DAY),0,'MONTH',1,'{"advanceHours":24}',NOW(),NULL),
(4,4,4,'OFFICIAL','发财树松土',DATE_SUB(NOW(),INTERVAL 1 DAY),2,'MONTH',1,'{"advanceHours":12}',NOW(),NULL),
(5,5,5,'OFFICIAL','富贵竹换水',DATE_ADD(NOW(),INTERVAL 3 DAY),0,'WEEK',1,'{"advanceHours":2}',NOW(),NULL);

INSERT INTO `care_record` VALUES
(1,1,1,'OFFICIAL',1,DATE_SUB(NOW(),INTERVAL 1 DAY),'{"water":"200ml","clean":"擦拭叶片"}','绿萝长势喜人，土壤微湿。',NOW()),
(2,2,2,'OFFICIAL',2,DATE_SUB(NOW(),INTERVAL 3 DAY),'{"sunlight":"阳台直射光4小时"}','多肉颜色开始上色，状态不错。',NOW()),
(3,3,3,'OFFICIAL',NULL,DATE_SUB(NOW(),INTERVAL 5 DAY),'{"trim":"修剪枯叶"}','发现少量黄叶，及时修剪。',NOW()),
(4,4,4,'OFFICIAL',4,DATE_SUB(NOW(),INTERVAL 7 DAY),'{"water":"500ml","fertilizer":"缓释肥缓施"}','发财树主干正常，没有软腐迹象。',NOW()),
(5,5,5,'OFFICIAL',5,DATE_SUB(NOW(),INTERVAL 2 DAY),'{"changeWater":"全部换水, 并清洗容器"}','营养液滴加了3滴，水质清澈。',NOW());

INSERT INTO `plant_photo` VALUES
(1,1,1,'OFFICIAL',1,'买回来的第一天','/uploads/demo1.jpg','/var/data/uploads/demo1.jpg',DATE_SUB(NOW(),INTERVAL 30 DAY),NOW()),
(2,1,1,'OFFICIAL',1,'已经爬满整个架子了！','/uploads/demo2.jpg','/var/data/uploads/demo2.jpg',DATE_SUB(NOW(),INTERVAL 1 DAY),NOW()),
(3,2,2,'OFFICIAL',0,'刚换的新盆','/uploads/demo3.jpg','/var/data/uploads/demo3.jpg',DATE_SUB(NOW(),INTERVAL 5 DAY),NOW()),
(4,3,3,'OFFICIAL',1,'爆了好多小吊兰','/uploads/demo4.jpg','/var/data/uploads/demo4.jpg',DATE_SUB(NOW(),INTERVAL 2 DAY),NOW()),
(5,5,5,'OFFICIAL',1,'根系越来越发达了','/uploads/demo5.jpg','/var/data/uploads/demo5.jpg',DATE_SUB(NOW(),INTERVAL 10 DAY),NOW());

INSERT INTO `reminder_config` VALUES
(1,1,'admin@plant.com','13800138000',1,1,'{"careSchedule":true,"systemMessage":true}',NOW(),NULL),
(2,2,'user01@qq.com','13900139001',1,0,'{"careSchedule":true,"systemMessage":false}',NOW(),NULL),
(3,3,'user02@163.com','13900139002',1,1,'{"careSchedule":false,"systemMessage":true}',NOW(),NULL),
(4,4,'user03@plant.com','13900139003',0,1,'{}',NOW(),NULL),
(5,5,'user04@sina.com','13900139004',1,1,'{"careSchedule":true}',NOW(),NULL);

INSERT INTO `reminder` VALUES
(1,1,'careSchedule',1,'浇水提醒','您的【绿萝】距离计划浇水时间还有2小时',0,NOW()),
(2,2,'systemMessage',NULL,'系统维护通知','系统将于今晚24点进行例行维护',1,NOW()),
(3,4,'careSchedule',4,'任务逾期警告','您的【发财树】松土任务已经逾期1天，请尽快处理',0,NOW()),
(4,5,'careSchedule',5,'换水提醒','您的【富贵竹】计划在明天需要换水',0,NOW());

SET FOREIGN_KEY_CHECKS = 1;

SELECT '✅ 数据库初始化完成（已修复 plant_photo 非空错误）' AS result;
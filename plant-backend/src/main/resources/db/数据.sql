USE `db_plant_official`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 清空数据 (删除原有的未加密的旧数据)
-- ----------------------------
TRUNCATE TABLE `sys_user`;
TRUNCATE TABLE `official_plant`;
TRUNCATE TABLE `care_schedule`;
TRUNCATE TABLE `care_record`;
TRUNCATE TABLE `plant_photo`;
TRUNCATE TABLE `reminder_config`;
TRUNCATE TABLE `reminder`;

-- ----------------------------
-- 1. 用户表 sys_user
-- 注意：所有密码统一为 123456，此处已经过 BCrypt 加密
-- 加密哈希：$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e
-- ----------------------------
INSERT INTO `sys_user` (`user_id`, `username`, `password`, `email`, `phone`, `role`, `deleted`, `create_time`) VALUES
(1, 'admin', '$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e', 'admin@plant.com', '13800138000', 'ADMIN', 0, NOW()),
(2, 'user01', '$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e', 'user01@qq.com', '13900139001', 'USER', 0, NOW()),
(3, 'user02', '$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e', 'user02@163.com', '13900139002', 'USER', 0, NOW()),
(4, 'user03', '$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e', 'user03@plant.com', '13900139003', 'USER', 0, NOW()),
(5, 'user04', '$2a$10$HXFauhgTBax.svF7gjZfnOYEDLmJoTH0lvdRuiJcLkIRJllFrUc8e', 'user04@sina.com', '13900139004', 'USER', 0, NOW());

-- ----------------------------
-- 2. 官方植物库 official_plant
-- ----------------------------
INSERT INTO `official_plant` (`id`, `name`, `genus`, `species`, `description`, `create_time`) VALUES
(1, '绿萝', '麒麟叶属', '绿萝', '耐阴好养，适合室内摆放，能有效净化空气，是新手的首选。', NOW()),
(2, '多肉-观音莲', '景天属', '多肉植物', '耐旱，少浇水，需要阳光充足的环境。叶片如莲花般排列。', NOW()),
(3, '吊兰', '吊兰属', '吊兰', '著名的垂吊植物，适应性强，能吸收有害气体，适合悬挂观赏。', NOW()),
(4, '发财树', '瓜栗属', '发财树', '寓意招财进宝，耐旱不喜积水，适合放在客厅或办公室。', NOW()),
(5, '富贵竹', '龙血树属', '富贵竹', '水培土培均可，象征吉祥富贵，四季常绿，极其好养。', NOW()),
(6, '龟背竹', '龟背竹属', '龟背竹', '网红绿植，叶片宽大有特点，非常适合现代家居风格的装饰。', NOW()),
(7, '虎皮兰', '虎尾兰属', '虎尾兰', '空气净化小能手，释放氧气能力强，极其耐旱。', NOW());

-- ----------------------------
-- 3. 养护计划表 care_schedule
-- ----------------------------
INSERT INTO `care_schedule` (`id`, `user_id`, `plant_id`, `plant_source`, `task_name`, `due_time`, `status`, `recurrence_type`, `recurrence_interval`, `reminder_config`, `create_time`) VALUES
(1, 1, 1, 'OFFICIAL', '绿萝浇水', DATE_ADD(NOW(), INTERVAL 1 DAY), 0, 'DAY', 2, '{"advanceHours": 2}', NOW()),
(2, 2, 2, 'OFFICIAL', '多肉光照', DATE_ADD(NOW(), INTERVAL 2 DAY), 0, 'WEEK', 1, '{"advanceHours": 1}', NOW()),
(3, 3, 3, 'OFFICIAL', '吊兰施薄肥', DATE_ADD(NOW(), INTERVAL 5 DAY), 0, 'MONTH', 1, '{"advanceHours": 24}', NOW()),
(4, 4, 4, 'OFFICIAL', '发财树松土', DATE_SUB(NOW(), INTERVAL 1 DAY), 2, 'MONTH', 1, '{"advanceHours": 12}', NOW()),
(5, 5, 5, 'OFFICIAL', '富贵竹换水', DATE_ADD(NOW(), INTERVAL 3 DAY), 0, 'WEEK', 1, '{"advanceHours": 2}', NOW());

-- ----------------------------
-- 4. 养护记录表 care_record
-- ----------------------------
INSERT INTO `care_record` (`id`, `user_id`, `plant_id`, `plant_source`, `schedule_id`, `record_time`, `operations`, `remarks`, `create_time`) VALUES
(1, 1, 1, 'OFFICIAL', 1, DATE_SUB(NOW(), INTERVAL 1 DAY), '{"water":"200ml", "clean":"擦拭叶片"}', '绿萝长势喜人，土壤微湿。', NOW()),
(2, 2, 2, 'OFFICIAL', 2, DATE_SUB(NOW(), INTERVAL 3 DAY), '{"sunlight":"阳台直射光4小时"}', '多肉颜色开始上色，状态不错。', NOW()),
(3, 3, 3, 'OFFICIAL', NULL, DATE_SUB(NOW(), INTERVAL 5 DAY), '{"trim":"修剪枯叶"}', '发现少量黄叶，及时修剪。', NOW()),
(4, 4, 4, 'OFFICIAL', 4, DATE_SUB(NOW(), INTERVAL 7 DAY), '{"water":"500ml", "fertilizer":"缓释肥缓施"}', '发财树主干正常，没有软腐迹象。', NOW()),
(5, 5, 5, 'OFFICIAL', 5, DATE_SUB(NOW(), INTERVAL 2 DAY), '{"changeWater":"全部换水, 并清洗容器"}', '营养液滴加了3滴，水质清澈。', NOW());

-- ----------------------------
-- 5. 成长相册表 plant_photo
-- ----------------------------
INSERT INTO `plant_photo` (`id`, `user_id`, `plant_id`, `plant_source`, `is_public`, `remarks`, `url`, `file_path`, `capture_time`, `create_time`) VALUES
(1, 1, 1, 'OFFICIAL', 1, '买回来的第一天', '/uploads/demo1.jpg', '/var/data/uploads/demo1.jpg', DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),
(2, 1, 1, 'OFFICIAL', 1, '已经爬满整个架子了！', '/uploads/demo2.jpg', '/var/data/uploads/demo2.jpg', DATE_SUB(NOW(), INTERVAL 1 DAY), NOW()),
(3, 2, 2, 'OFFICIAL', 0, '刚换的新盆', '/uploads/demo3.jpg', '/var/data/uploads/demo3.jpg', DATE_SUB(NOW(), INTERVAL 5 DAY), NOW()),
(4, 3, 3, 'OFFICIAL', 1, '爆了好多小吊兰', '/uploads/demo4.jpg', '/var/data/uploads/demo4.jpg', DATE_SUB(NOW(), INTERVAL 2 DAY), NOW()),
(5, 5, 5, 'OFFICIAL', 1, '根系越来越发达了', '/uploads/demo5.jpg', '/var/data/uploads/demo5.jpg', DATE_SUB(NOW(), INTERVAL 10 DAY), NOW());

-- ----------------------------
-- 6. 提醒配置表 reminder_config
-- ----------------------------
INSERT INTO `reminder_config` (`id`, `user_id`, `email`, `phone`, `popup_enabled`, `bell_enabled`, `scene_config`, `create_time`) VALUES
(1, 1, 'admin@plant.com', '13800138000', 1, 1, '{"careSchedule": true, "systemMessage": true}', NOW()),
(2, 2, 'user01@qq.com', '13900139001', 1, 0, '{"careSchedule": true, "systemMessage": false}', NOW()),
(3, 3, 'user02@163.com', '13900139002', 1, 1, '{"careSchedule": false, "systemMessage": true}', NOW()),
(4, 4, 'user03@plant.com', '13900139003', 0, 1, '{}', NOW()),
(5, 5, 'user04@sina.com', '13900139004', 1, 1, '{"careSchedule": true}', NOW());

-- ----------------------------
-- 7. 提醒通知表 reminder
-- ----------------------------
INSERT INTO `reminder` (`id`, `user_id`, `scene`, `business_id`, `title`, `content`, `is_read`, `create_time`) VALUES
(1, 1, 'careSchedule', 1, '浇水提醒', '您的【绿萝】距离计划浇水时间还有2小时', 0, NOW()),
(2, 2, 'systemMessage', NULL, '系统维护通知', '系统将于今晚24点进行例行维护', 1, NOW()),
(3, 4, 'careSchedule', 4, '任务逾期警告', '您的【发财树】松土任务已经逾期1天，请尽快处理', 0, NOW()),
(4, 5, 'careSchedule', 5, '换水提醒', '您的【富贵竹】计划在明天需要换水', 0, NOW());

SET FOREIGN_KEY_CHECKS = 1;

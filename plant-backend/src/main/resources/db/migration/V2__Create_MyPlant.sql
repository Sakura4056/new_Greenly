-- 创建 my_plant 个人植物库表
CREATE TABLE IF NOT EXISTS `my_plant` (
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

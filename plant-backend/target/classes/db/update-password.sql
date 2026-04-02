-- =================================================================
-- 更新用户密码脚本
-- 用于修复无法登录的问题
-- =================================================================

USE db_plant_official;

-- 更新用户密码为正确的 BCrypt 哈希值
-- 明文密码：admin123
-- 生成方式：new BCryptPasswordEncoder().encode("admin123")
UPDATE sys_user SET password = '$2a$10$7JB720yubVSofvwd2FCBBOeFNX6cOnj9pb4F5K6sNp4q5bF9K4nqy' WHERE username = 'admin';
UPDATE sys_user SET password = '$2a$10$7JB720yubVSofvwd2FCBBOeFNX6cOnj9pb4F5K6sNp4q5bF9K4nqy' WHERE username = 'user';

-- 验证更新结果
SELECT username, password FROM sys_user WHERE username IN ('admin', 'user');

SELECT '密码更新完成' AS message;
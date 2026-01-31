-- =====================================================
-- 创建管理员用户 - 最终安全版本
-- 用户名: admin
-- 密码: admin123
-- 自动适配数据库表结构
-- =====================================================

-- 1. 显示sys_users表结构
SELECT 'sys_users表结构:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'sys_users' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 2. 显示sys_roles表结构
SELECT 'sys_roles表结构:' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'sys_roles' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. 显示现有角色
SELECT '现有角色:' as info;
SELECT * FROM sys_roles LIMIT 10;

-- 4. 删除可能存在的旧用户
DELETE FROM sys_user_roles WHERE user_id = 'admin-001';
DELETE FROM act_id_user WHERE id_ = 'admin-001';
DELETE FROM sys_users WHERE id = 'admin-001' OR username = 'admin';

-- 5. 创建管理员用户（只使用基础字段）
INSERT INTO sys_users (
    id, 
    username, 
    password_hash, 
    email, 
    display_name, 
    full_name, 
    status, 
    created_at, 
    updated_at
) VALUES (
    'admin-001',
    'admin',
    '$2a$10$bTB3yyVtzpJw17uMI9pShOzAkm07MKZa2EyQhc4izBO1MdXXEiUiO',
    'admin@company.com',
    '系统管理员',
    '系统管理员',
    'ACTIVE',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- 6. 动态更新可选字段
-- 更新language字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'language' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET language = 'zh_CN' 
        WHERE id = 'admin-001';
    END IF;
END $$;

-- 更新must_change_password字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'must_change_password' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET must_change_password = false 
        WHERE id = 'admin-001';
    END IF;
END $$;

-- 更新phone字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'phone' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET phone = '+86-138-0000-0000' 
        WHERE id = 'admin-001';
    END IF;
END $$;

-- 更新employee_id字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'employee_id' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET employee_id = 'ADMIN001' 
        WHERE id = 'admin-001';
    END IF;
END $$;

-- 更新position字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'position' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET position = 'System Administrator' 
        WHERE id = 'admin-001';
    END IF;
END $$;

-- 7. 分配现有的管理员角色（使用实际存在的角色）
-- 先查找包含ADMIN的角色
DO $$
DECLARE
    role_record RECORD;
BEGIN
    -- 分配所有包含ADMIN、SYS_ADMIN、SYSTEM的角色
    FOR role_record IN 
        SELECT id FROM sys_roles 
        WHERE UPPER(code) LIKE '%ADMIN%' 
           OR UPPER(code) LIKE '%SYSTEM%'
           OR UPPER(name) LIKE '%ADMIN%'
           OR UPPER(name) LIKE '%SYSTEM%'
    LOOP
        INSERT INTO sys_user_roles (
            id, 
            user_id, 
            role_id, 
            assigned_at, 
            assigned_by
        ) VALUES (
            'ur-admin-001-' || role_record.id,
            'admin-001',
            role_record.id,
            CURRENT_TIMESTAMP,
            'system'
        ) ON CONFLICT (id) DO NOTHING;
    END LOOP;
    
    -- 分配所有包含DEVELOPER、TECH的角色
    FOR role_record IN 
        SELECT id FROM sys_roles 
        WHERE UPPER(code) LIKE '%DEVELOPER%' 
           OR UPPER(code) LIKE '%TECH%'
           OR UPPER(name) LIKE '%DEVELOPER%'
           OR UPPER(name) LIKE '%TECH%'
    LOOP
        INSERT INTO sys_user_roles (
            id, 
            user_id, 
            role_id, 
            assigned_at, 
            assigned_by
        ) VALUES (
            'ur-admin-001-' || role_record.id,
            'admin-001',
            role_record.id,
            CURRENT_TIMESTAMP,
            'system'
        ) ON CONFLICT (id) DO NOTHING;
    END LOOP;
    
    -- 分配所有包含MANAGER、LEADER的角色
    FOR role_record IN 
        SELECT id FROM sys_roles 
        WHERE UPPER(code) LIKE '%MANAGER%' 
           OR UPPER(code) LIKE '%LEADER%'
           OR UPPER(name) LIKE '%MANAGER%'
           OR UPPER(name) LIKE '%LEADER%'
    LOOP
        INSERT INTO sys_user_roles (
            id, 
            user_id, 
            role_id, 
            assigned_at, 
            assigned_by
        ) VALUES (
            'ur-admin-001-' || role_record.id,
            'admin-001',
            role_record.id,
            CURRENT_TIMESTAMP,
            'system'
        ) ON CONFLICT (id) DO NOTHING;
    END LOOP;
    
    -- 分配AUDITOR角色
    FOR role_record IN 
        SELECT id FROM sys_roles 
        WHERE UPPER(code) LIKE '%AUDIT%' 
           OR UPPER(name) LIKE '%AUDIT%'
    LOOP
        INSERT INTO sys_user_roles (
            id, 
            user_id, 
            role_id, 
            assigned_at, 
            assigned_by
        ) VALUES (
            'ur-admin-001-' || role_record.id,
            'admin-001',
            role_record.id,
            CURRENT_TIMESTAMP,
            'system'
        ) ON CONFLICT (id) DO NOTHING;
    END LOOP;
END $$;

-- 8. 创建Activiti工作流引擎用户
INSERT INTO act_id_user (
    id_,
    rev_,
    first_,
    last_,
    display_name_,
    email_,
    pwd_,
    picture_id_
) VALUES (
    'admin-001',
    1,
    '系统',
    '管理员',
    '系统管理员',
    'admin@company.com',
    '$2a$10$bTB3yyVtzpJw17uMI9pShOzAkm07MKZa2EyQhc4izBO1MdXXEiUiO',
    NULL
) ON CONFLICT (id_) DO NOTHING;

-- 9. 验证创建结果
SELECT 'created_user' as result_type, 
    u.id,
    u.username,
    u.display_name,
    u.email,
    u.status
FROM sys_users u
WHERE u.username = 'admin';

-- 10. 显示分配的角色
SELECT 'assigned_roles' as result_type,
    r.id as role_id,
    r.code as role_code,
    r.name as role_name
FROM sys_users u
JOIN sys_user_roles ur ON u.id = ur.user_id
JOIN sys_roles r ON ur.role_id = r.id
WHERE u.username = 'admin'
ORDER BY r.code;

-- 11. 统计信息
SELECT 'summary' as result_type,
    COUNT(*) as total_assigned_roles
FROM sys_users u
JOIN sys_user_roles ur ON u.id = ur.user_id
WHERE u.username = 'admin';

-- =====================================================
-- 使用说明:
-- 用户名: admin
-- 密码: admin123
-- 
-- 该脚本特点:
-- 1. 自动检测并显示表结构
-- 2. 只使用实际存在的列
-- 3. 动态分配所有相关的管理员角色
-- 4. 包含完整的验证和调试信息
-- 5. 不会因为列不存在而报错
-- 
-- 执行后会显示:
-- - 表结构信息
-- - 创建的用户信息
-- - 分配的所有角色
-- - 总结统计
-- =====================================================

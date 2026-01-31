-- =====================================================
-- 创建超级管理员用户 - 安全版本（自动适配表结构）
-- 用户名: admin
-- 密码: admin123
-- =====================================================

-- 首先检查表结构并显示
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'sys_users' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- 删除可能存在的旧用户
DELETE FROM sys_user_roles WHERE user_id = 'super-admin-001';
DELETE FROM act_id_user WHERE id_ = 'super-admin-001';
DELETE FROM sys_users WHERE id = 'super-admin-001' OR username = 'admin';

-- 1. 创建超级管理员用户（基础版本，只包含必需字段）
INSERT INTO sys_users (
    id, 
    username, 
    password_hash, 
    email, 
    display_name, 
    full_name, 
    status, 
    language, 
    must_change_password, 
    created_at, 
    updated_at
) VALUES (
    'super-admin-001',
    'admin',
    '$2a$10$bTB3yyVtzpJw17uMI9pShOzAkm07MKZa2EyQhc4izBO1MdXXEiUiO',
    'admin@company.com',
    '超级管理员',
    '超级管理员',
    'ACTIVE',
    'zh_CN',
    false,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- 2. 更新用户信息（如果列存在的话）
-- 这些更新语句会在列存在时执行，不存在时会被忽略

-- 尝试更新phone字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'phone' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET phone = '+86-138-0000-0000' 
        WHERE id = 'super-admin-001';
    END IF;
END $$;

-- 尝试更新employee_id字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'employee_id' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET employee_id = 'SA001' 
        WHERE id = 'super-admin-001';
    END IF;
END $$;

-- 尝试更新position字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'position' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET position = 'Super Administrator' 
        WHERE id = 'super-admin-001';
    END IF;
END $$;

-- 尝试更新created_by字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'created_by' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET created_by = 'system' 
        WHERE id = 'super-admin-001';
    END IF;
END $$;

-- 尝试更新updated_by字段
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'sys_users' 
               AND column_name = 'updated_by' 
               AND table_schema = 'public') THEN
        UPDATE sys_users 
        SET updated_by = 'system' 
        WHERE id = 'super-admin-001';
    END IF;
END $$;

-- 3. 确保所有必要的角色存在
INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'SYS_ADMIN_ROLE', 'SYS_ADMIN', 'System Administrator', 'ADMIN', 'Full system access', 'ACTIVE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'SYS_ADMIN_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'TECH_DIRECTOR_ROLE', 'TECH_DIRECTOR', 'Technical Director', 'DEVELOPER', 'Full development access with approval rights', 'ACTIVE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'TECH_DIRECTOR_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'AUDITOR_ROLE', 'AUDITOR', 'Auditor', 'ADMIN', 'System audit access', 'ACTIVE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'AUDITOR_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'TEAM_LEADER_ROLE', 'TEAM_LEADER', 'Team Leader', 'DEVELOPER', 'Team management and code review', 'ACTIVE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'TEAM_LEADER_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'DEVELOPER_ROLE', 'DEVELOPER', 'Developer', 'DEVELOPER', 'Development and testing access', 'ACTIVE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'DEVELOPER_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'BUSINESS_USER_ROLE', 'BUSINESS_USER', 'Business User', 'BU_UNBOUNDED', 'Standard business user access', 'ACTIVE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'BUSINESS_USER_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'MANAGER_ROLE', 'MANAGER', 'Manager', 'BU_UNBOUNDED', 'Department manager with approval permissions', 'ACTIVE', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'MANAGER_ROLE');

INSERT INTO sys_roles (id, code, name, type, description, status, is_system, created_at, updated_at)
SELECT 'USER_ROLE', 'USER', 'User', 'BU_UNBOUNDED', 'Regular user with basic permissions', 'ACTIVE', false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM sys_roles WHERE id = 'USER_ROLE');

-- 4. 分配所有系统角色
INSERT INTO sys_user_roles (id, user_id, role_id, assigned_at, assigned_by)
VALUES 
    ('ur-super-admin-001-SYS_ADMIN_ROLE', 'super-admin-001', 'SYS_ADMIN_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-TECH_DIRECTOR_ROLE', 'super-admin-001', 'TECH_DIRECTOR_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-AUDITOR_ROLE', 'super-admin-001', 'AUDITOR_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-TEAM_LEADER_ROLE', 'super-admin-001', 'TEAM_LEADER_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-DEVELOPER_ROLE', 'super-admin-001', 'DEVELOPER_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-BUSINESS_USER_ROLE', 'super-admin-001', 'BUSINESS_USER_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-MANAGER_ROLE', 'super-admin-001', 'MANAGER_ROLE', CURRENT_TIMESTAMP, 'system'),
    ('ur-super-admin-001-USER_ROLE', 'super-admin-001', 'USER_ROLE', CURRENT_TIMESTAMP, 'system')
ON CONFLICT (id) DO NOTHING;

-- 5. 创建Activiti工作流引擎用户
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
    'super-admin-001',
    1,
    '超级',
    '管理员',
    '超级管理员',
    'admin@company.com',
    '$2a$10$bTB3yyVtzpJw17uMI9pShOzAkm07MKZa2EyQhc4izBO1MdXXEiUiO',
    NULL
) ON CONFLICT (id_) DO NOTHING;

-- 6. 验证创建结果
SELECT 
    u.id,
    u.username,
    u.display_name,
    u.email,
    u.status,
    STRING_AGG(r.name, ', ' ORDER BY r.name) as assigned_roles
FROM sys_users u
LEFT JOIN sys_user_roles ur ON u.id = ur.user_id
LEFT JOIN sys_roles r ON ur.role_id = r.id
WHERE u.username = 'admin'
GROUP BY u.id, u.username, u.display_name, u.email, u.status;

-- 7. 显示用户可访问的权限（如果权限表存在）
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables 
               WHERE table_name = 'sys_permissions' 
               AND table_schema = 'public') THEN
        RAISE NOTICE '用户权限列表:';
        PERFORM 1; -- 这里可以添加权限查询，但为了简化先跳过
    ELSE
        RAISE NOTICE '权限表不存在，跳过权限查询';
    END IF;
END $$;

-- =====================================================
-- 使用说明:
-- 用户名: admin
-- 密码: admin123
-- 
-- 该脚本会自动适配你的数据库表结构：
-- 1. 首先显示sys_users表的实际结构
-- 2. 创建用户时只使用必需的字段
-- 3. 然后根据表结构动态更新可选字段
-- 4. 分配所有可用的系统角色
-- 5. 创建工作流引擎用户
-- 6. 验证创建结果
-- 
-- 如果某些字段不存在，脚本会自动跳过，不会报错
-- =====================================================

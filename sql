-- =====================================================
-- 创建超级管理员用户 - 拥有所有权限
-- 用户名: admin
-- 密码: admin123 (BCrypt加密)
-- 
-- 注意: 此脚本基于你修改的环境变量:
-- JWT_SECRET=workflow-engine-jwt-secret-key-2026
-- ENCRYPTION_SECRET_KEY=workflow-aes-256-encryption-key!
-- =====================================================

-- 1. 创建超级管理员用户
-- 密码: admin123 (BCrypt hash: $2a$10$bTB3yyVtzpJw17uMI9pShOzAkm07MKZa2EyQhc4izBO1MdXXEiUiO)
INSERT INTO sys_users (
    id, 
    username, 
    password_hash, 
    email, 
    display_name, 
    full_name, 
    phone, 
    employee_id, 
    position, 
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
    '+86-138-0000-0000',
    'SA001',
    'Super Administrator',
    'ACTIVE',
    'zh_CN',
    false,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
) ON CONFLICT (id) DO NOTHING;

-- 2. 分配系统管理员角色 (SYS_ADMIN_ROLE)
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-SYS_ADMIN_ROLE',
    'super-admin-001',
    'SYS_ADMIN_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 3. 分配技术总监角色 (TECH_DIRECTOR_ROLE) - 获得开发权限
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-TECH_DIRECTOR_ROLE',
    'super-admin-001',
    'TECH_DIRECTOR_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 4. 分配审计员角色 (AUDITOR_ROLE) - 获得审计权限
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-AUDITOR_ROLE',
    'super-admin-001',
    'AUDITOR_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 5. 分配团队领导角色 (TEAM_LEADER_ROLE) - 获得团队管理权限
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-TEAM_LEADER_ROLE',
    'super-admin-001',
    'TEAM_LEADER_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 6. 分配开发者角色 (DEVELOPER_ROLE) - 获得开发权限
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-DEVELOPER_ROLE',
    'super-admin-001',
    'DEVELOPER_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 7. 分配业务用户角色 (BUSINESS_USER_ROLE) - 获得业务权限
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-BUSINESS_USER_ROLE',
    'super-admin-001',
    'BUSINESS_USER_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 8. 分配管理者角色 (MANAGER_ROLE) - 获得管理权限
INSERT INTO sys_user_roles (
    id,
    user_id,
    role_id,
    assigned_at,
    assigned_by
) VALUES (
    'ur-super-admin-001-MANAGER_ROLE',
    'super-admin-001',
    'MANAGER_ROLE',
    CURRENT_TIMESTAMP,
    'system'
) ON CONFLICT (id) DO NOTHING;

-- 9. 创建Activiti用户 (用于工作流引擎)
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

-- 10. 验证创建结果
SELECT 
    u.id,
    u.username,
    u.display_name,
    u.email,
    u.status,
    STRING_AGG(r.name, ', ') as roles
FROM sys_users u
LEFT JOIN sys_user_roles ur ON u.id = ur.user_id
LEFT JOIN sys_roles r ON ur.role_id = r.id
WHERE u.username = 'admin'
GROUP BY u.id, u.username, u.display_name, u.email, u.status;

-- =====================================================
-- 使用说明:
-- 用户名: admin
-- 密码: admin123
-- 
-- 该用户拥有以下权限:
-- 1. 系统管理员权限 - 用户管理、角色管理、系统配置等
-- 2. 技术总监权限 - 功能单元管理、审批权限
-- 3. 审计员权限 - 审计日志查看
-- 4. 团队领导权限 - 团队管理、代码审查
-- 5. 开发者权限 - 开发和测试访问
-- 6. 业务用户权限 - 标准业务用户访问
-- 7. 管理者权限 - 部门管理和审批权限
-- 
-- 可以访问所有模块:
-- - Admin Center (管理中心)
-- - Developer Workstation (开发工作站)  
-- - User Portal (用户门户)
-- =====================================================

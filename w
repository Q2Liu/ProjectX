-- 第1步：先查出该 function unit 的 ID（按 name 或 code 搜索）
SELECT id, name, code, status, version
FROM sys_function_units
WHERE name LIKE '%你的功能单元名称%'   -- 替换为实际名称
   OR code LIKE '%your_code%';



-- 第2步：删除 deploy 相关记录（按顺序，因为有外键）
-- ① 先删 approvals（依赖 deployments）
DELETE FROM sys_function_unit_approvals
WHERE deployment_id IN (
    SELECT id FROM sys_function_unit_deployments
    WHERE function_unit_id = '这里填你的function_unit_id'
);

-- ② 再删 deployments
DELETE FROM sys_function_unit_deployments
WHERE function_unit_id = '这里填你的function_unit_id';

-- ③ 重置 sys_function_units 的部署状态，让它可以重新部署
UPDATE sys_function_units
SET status = 'VALIDATED',
    process_deployed = false,
    process_deployment_count = 0
WHERE id = '这里填你的function_unit_id';

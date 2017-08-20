conn sys/oracle@orcl as sysdba
-- setup auditing the use of roles. roles we should
-- pay careful attention to are the three admin roles
-- used to install code and objects.
--
-- drop the policies before we create them
--
-- we need to disable the policies before
-- we can drop them
declare
  Policy_Does_not_exists exception;
  pragma Exception_Init(Policy_Does_not_exists, -46357);
begin
  execute immediate 'noaudit policy aud_admin_rol_pol';
  execute immediate 'noaudit policy aud_api_dml_pol';
  execute immediate 'noaudit policy policy aud_exec_code_pol';
  execute immediate 'drop audit policy aud_admin_rol_pol';
  execute immediate 'drop audit policy aud_api_dml_pol';
  execute immediate 'drop audit policy policy aud_exec_code_pol';
exception when Policy_Does_not_exists then null;
end;
/

--
create audit policy aud_admin_rol_pol roles hr_api_admin_role;

create audit policy aud_api_dml_pol roles hr_emp_select_role;

create audit policy aud_exec_code_pol actions all on hr_code.pkg_manage_emp;
create audit policy aud_exec_api_pol actions all on hr_api.pkg_emp_insert;
create audit policy aud_hr_employees actions all on hr.employees;

-- we have the policies, now we need to enable them
-- in this case we are going to audit both success
-- and failure.
audit policy aud_admin_rol_pol;
audit policy aud_api_dml_pol;
audit policy aud_exec_code_pol;
audit policy aud_exec_api_pol;
audit policy aud_hr_employees;

-- check that the audit policies exists
select policy_name,
audit_option,
condition_eval_opt
from sys.audit_unified_policies
where policy_name in (upper('aud_admin_rol_pol'),
upper('aud_api_dml_pol'));

-- check that the audit policies are enabled.
select policy_name,
enabled_opt,
user_name,
success,
failure
from sys.audit_unified_enabled_policies
where policy_name in (upper('aud_admin_rol_pol'),
upper('aud_api_dml_pol'));

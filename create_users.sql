-- this assumes you have the hr demo schema loaded.
-- 1.0 we are adding in hr_code schema and grants.
-- we are also making the hr_code_admin, allong with
-- the rest of the roles password protected.

-- clean up before we start.
declare
  procedure Drop_User(pUser in varchar2) is
    User_Doesnt_Exist exception;
    pragma Exception_Init(User_Doesnt_Exist, -01918);
  begin
    execute immediate 'drop user '||pUser||' cascade';
  exception when User_Doesnt_Exist then null;
  end Drop_User;
begin
  Drop_User('hr_decls');
  Drop_User('hr_api');
  Drop_User('hr_code');
  Drop_User('usr1');
end;
/

declare
  Role_Doesnt_Exist exception;
  pragma exception_init(Role_Doesnt_Exist, -01919);
begin
  execute immediate 'drop role hr_emp_select_role';
  execute immediate 'drop role hr_backup_role';
  execute immediate 'drop role hr_api_admin_role';
  execute immediate 'drop role hr_code_admin_role';
  execute immediate 'drop role hr_dept_select_role';
  execute immediate 'drop role exec_hr_emp_api_sel_role';
  execute immediate 'drop role hr_emp_insert_role';
  execute immediate 'drop role hr_decls_admin_role';
  execute immediate 'drop role exec_hr_emp_api_ins_role';
  execute immediate 'drop role exec_hr_dep_api_sel_role';
  execute immediate 'drop role hr_loc_select_role';
exception when Role_Doesnt_Exist then null;
when others then sys.dbms_output.put_line(sqlerrm);
end;
/
-- done cleaning up.

-- create all the users.
create user hr_decls identified by x;
create user usr1 identified by x;
create user hr_code identified by x;
create user hr_api identified by x; -- this is going to be my api schema that will have access to the hr objects.
-- create all the roles
create role hr_decls_admin_role identified by x;
-- role needed to create packages
create role hr_code_admin_role identified by x;
-- this will be my executing user.
-- the hr_emp_select_role will have select in hr.ermployees.
create role hr_emp_select_role;
-- the hr_backup_role has create any table privilege. I really don't
-- like that, but that is what the role needs to create a table in
-- a diffrent schema.
create role hr_backup_role;
-- the hr_api_admin_role has create procedure privilege.
-- 1.0 made api_admin_role password protected.
create role hr_api_admin_role identified by x;
create role hr_emp_insert_role;
create role hr_dept_select_role;
create role hr_loc_select_role;
-- create roles that are used to execute apis
create role exec_hr_emp_api_sel_role;
create role exec_hr_emp_api_ins_role;
create role exec_hr_dep_api_sel_role;

-- now do the grants.
grant
	select on hr.departments
to hr_decls_admin_role, hr_decls, hr_api;

grant 
	select on hr.locations
to hr_decls_admin_role, hr_decls, hr_api;

grant 
	select on hr.employees
to hr_decls_admin_role, hr_decls;

grant 
	create procedure
to hr_decls_admin_role;

grant 
	create session,
	hr_decls_admin_role
to hr_decls;

alter user hr_decls default role none;


grant
    create session
to usr1;
--

grant 
	create procedure 
to hr_code_admin_role;
grant
	create session,
	hr_code_admin_role 
to hr_code;
alter user hr_code default role none;


grant 
	insert on hr.employees
to hr_emp_insert_role, hr_api;

grant 
	select on hr.employees_seq
to hr_emp_insert_role, hr_api;

grant 
	select on hr.departments_seq
TO hr_dept_select_role;

grant
	select on hr.departments
to hr_dept_select_role;

grant 
	hr_dept_select_role
to hr_api with delegate option;

grant select
        on hr.EMPLOYEES_SEQ
to hr_emp_insert_role;

grant
	hr_emp_insert_role
to hr_api with delegate option;

--
-- the user usr1 will only need create session. after we've created
-- the package in the hr_api schema, we will grant execute on the
-- package to usr1.
-- the hr_api_admin_role will need the create procedure privilege.
-- this will be granted to hr_api.
grant
    create procedure
to hr_api_admin_role;
--
-- this will give the hr_emp_select role the privilege
-- it needs to execute.
grant
    select on hr.employees
to hr_emp_select_role;
--
-- this will be needed to compile the code in the api schema.
grant
    select
on hr.employees to hr_api;
--
grant 
	insert
on hr.employees to hr_api;
--
-- we are going to revoke create session after we are done.
grant
    create session
to hr_api;
--
-- the hr_bacup_role is used to demenstrate
-- using dynamic sql.
grant create any table to hr_backup_role;
--
-- hr_api needs the roles with delegate option (or admin option)
-- to be able to grant the role to a package.
grant
    hr_emp_select_role,
    hr_backup_role
to hr_api with delegate option;
--
grant
    hr_api_admin_role
to hr_api;
--
-- during normal operating, the hr_api schema does not
-- need any privileges.
alter user hr_api
    default role none;
	
-- now, api's are only accessed from the code 
-- schema that holds the business logic.
grant 
	exec_hr_emp_api_sel_role,
	exec_hr_dep_api_sel_role
to hr_code;

conn sys/oracle@orcl as sysdba
grant select on sys.v_$instance to hr_decls;
grant select on sys.v_$instance to hr_api;
grant select on sys.v_$instance to hr_code;

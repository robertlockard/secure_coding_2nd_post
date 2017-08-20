-- connect as hr_api
conn hr_api/x@orcl

-- do I need to set the role in order to grant it?
SET role hr_emp_select_role, hr_backup_role;
SET role  hr_api_admin_role identified by x;

create or replace package hr_api.pkg_emp_select
authid current_user AS
    PROCEDURE pGetPhone(pFname  IN      VARCHAR2,
                        pLname  IN      VARCHAR2,
                        pPhone      OUT VARCHAR2);

    PROCEDURE pBackupEmp;
	-- this version of fGetEmp can search based on
	-- last name and / or employee_id.
	FUNCTION fGetEmp(pLname IN VARCHAR2 DEFAULT NULL,
					 pEmpId IN VARCHAR2 DEFAULT NULL)
			RETURN hr_decls.decl.t_emps_t;
END;
/

-- we are going to grant the hr_emp_select_role
-- to pkg_emp_select
GRANT hr_emp_select_role, hr_backup_role to package pkg_emp_select;
-- now lets build the body. we are going to keep this very simple
-- in later versions, we'll add in passing records. but for now
-- we are not going to cloud this with more advanced subjects.
CREATE OR REPLACE PACKAGE BODY hr_api.pkg_emp_select AS

    PROCEDURE pGetPhone(pFname  IN      VARCHAR2,
                        pLname  IN      VARCHAR2,
                        pPhone      OUT VARCHAR2) IS
    BEGIN
        BEGIN
        SELECT phone_number
        INTO pPhone
        FROM hr.employees
        WHERE first_name = pFname
          AND last_name  = pLname;
		-- the exception handeler will be changing
		-- to include the errors handeler that will
		-- return to the user the primary key that
		-- points to the error. This way we will
		-- not be returning anything that is of 
		-- use to a potential blackhat. 
        EXCEPTION WHEN no_data_found then
            pPhone := 'xxx';
        WHEN too_many_rows THEN
            pPhone := 'yyy';
        WHEN others THEN
            -- we can add in the help desk error handler later, again this
            -- is just to demo granting roles to packages.
            sys.dbms_output.put_line('pGetPhone raised an exception ' || sqlerrm);
        END;
        --
    END pGetPhone;
	
	FUNCTION fGetEmp(pLname IN VARCHAR2 DEFAULT NULL,
					 pEmpId IN VARCHAR2 DEFAULT NULL)
			RETURN hr_decls.decl.t_emps_t IS
	t_Emps hr_decls.decl.t_emps_t;
	BEGIN
		SELECT *
		BULK COLLECT INTO t_Emps
		FROM hr.employees
		WHERE ((last_name = pLname) OR pLname IS NULL)
		  AND ((employee_id = pEmpId) OR pEmpId IS NULL);
		RETURN t_Emps;
	-- the exception handeler will be replaced with 
	-- the error logger that returns the primary key
	-- of the error raised.
	EXCEPTION WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20002, 'fGetEmp raised an exception ' || sqlerrm);
	END fGetEmp;
    --
    -- this is a very simple procedure, create a backup table using execute
    -- immediate. (dynamic sql) the only way this procedure is going to work
    -- is if the package has create any table privilege to be able to
    -- create a table in another schema.
    PROCEDURE pBackupEmp IS
    -- This is the date string 20170805
    dt  VARCHAR2(8);
    BEGIN
        dt := to_char(sysdate,'rrrrmmdd');
        execute immediate 'create table hr.employees' ||dt|| ' as select * from hr.employees';
        sys.dbms_output.put_line('create table success');
        exception when others then
            sys.dbms_output.put_line('create table error ' || sqlerrm);
    END pBackupEmp;
end pkg_emp_select;
/

create or replace package        pkg_emp_insert 
AUTHID CURRENT_USER AS

	PROCEDURE pInsEmp(pEmp IN 		hr_decls.decl.t_emp_t,
					  pId		OUT INTEGER);

END pkg_emp_insert;
/

grant hr_emp_insert_role to package hr_api.pkg_emp_insert;

create or replace PACKAGE BODY        pkg_emp_insert AS
    -- this verion of pInsEmp generates the employee_id using
    -- the hr.employees_seq sequence. do we want to build a 
    -- version that the employee_id is passed in the record?
    -- if we do that, then we will have to grant access to 
    -- the hr.employees_seq sequence to hr_code. Not sure
    -- we want to do that in this instance. The point of the
    -- demo is to not allow the hr_code or the users direct
    -- acces to anything in the hr schema.

	PROCEDURE pInsEmp(pEmp IN 		hr_decls.decl.t_emp_t,
					  pId		OUT INTEGER) IS
    -- generate the primary key for the employee
	begin
		SELECT hr.employees_seq.nextval
		INTO pId
		FROM DUAL;
        -- insert the row into the hr.employees table.
		INSERT into hr.employees values (
			pId,
			pEmp.first_name,
			pEmp.last_name,
			pEmp.email,
			pEmp.phone_number,
			pEmp.hire_date,
			pEmp.job_id,
			pEmp.salary,
			pEmp.commission_pct,
			pEmp.manager_id,
			pEmp.department_id,
			pEmp.ssn);
	EXCEPTION WHEN OTHERS THEN 
		-- this is going to change to use the errors handeler.
		RAISE_APPLICATION_ERROR(-20000,'error inserting into hr.employees ' || sqlcode || ' ' || sqlerrm);
	END pInsEmp;
END pkg_emp_insert;
/


-- i need a package to manage departments. select departments
-- into hr_decls.decl.t_depts_t
create or replace package hr_api.hr_dept_select as
    FUNCTION fGetDepartments RETURN hr_decls.decl.t_depts_t;
END hr_dept_select;
/

-- grant the role hr_dept_select_role to the package
-- so the package has access to the objects.
grant hr_dept_select_role to package hr_api.hr_dept_select;

-- create the package body.
create or replace package body hr_api.hr_dept_select AS
	FUNCTION fGetDepartments RETURN hr_decls.decl.t_depts_t IS
    t_depts hr_decls.decl.t_depts_t;
	BEGIN
		-- get the departments into t_depts.
		SELECT *
        BULK COLLECT INTO t_depts
        FROM hr.departments;
        --
        RETURN t_depts;
        -- We will be replacing the exception handler with the error
        -- logger that returns the primary key pointing to the error.
    EXCEPTION WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, 'HR_DEPT_SELECT.fGetDepartments raised ' || sqlerrm);
END fGetDepartments;
END hr_dept_select;
/

-- now grant execute on the package to the role used
-- to execute the api.
grant execute on hr_api.pkg_emp_select to exec_hr_emp_api_sel_role;
grant execute on hr_api.hr_dept_select to exec_hr_dep_api_sel_role;
grant execute on hr_api.pkg_emp_insert to exec_hr_emp_api_ins_role;

-- we don't need any roles now that the code is compiled.
set role none;
-- it sure would be nice if I could revoke select on employees
-- from hr_api. But when I do that, the package is invalidated.

-- install hr_decels
conn hr_decls/x@orcl
set role hr_decls_admin_role identified by x;

-- the package name "decl" is for declorations.
create or replace package hr_decls.decl IS
    -- define the cursors
    CURSOR dept_cur IS
    SELECT department_id,
           department_name,
           manager_id,
           location_id
    FROM hr.departments;

    CURSOR emp_cur IS
    SELECT employee_id,
           first_name,
           last_name,
           email,
           phone_number,
           hire_date,
           job_id,
           salary,
           commission_pct,
           manager_id,
           department_id,
		   ssn
    FROM hr.employees;

    -- types
    subtype t_dep_t IS dept_cur%rowtype;
    type t_depts_t is table of t_dep_t index by pls_integer;
    subtype t_emp_t IS emp_cur%rowtype;
    type t_emps_t is table of t_emp_t index by pls_integer;
end decl;
/

grant execute on hr_decls.decl to hr_api;
grant execute on hr_decls.decl to hr_code;
-- does the user need access to this package?
-- in this example, the user will be executing
-- code in the hr_code schema, the procedure
-- being executed requires visibility to the 
-- t_dep_t subtype.
grant execute on hr_decls.decl to usr1;
-- i don't think so, we are going to put a 
-- front end on it; and the user will be going
-- throught the front end. Now, should I use
-- APEX, PHP, or Python?
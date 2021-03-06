-- install the hr_code schema.
conn hr_code/x@orcl

set role hr_code_admin_role identified by x;

-- build a package that 
-- 	a) add an employee. Assigns the employee
-- 		to a department and location.
--  b) gets employee information by name, 
--		department or location.
--	c) determan if the person getting the 
-- 		employee information can get ssn
-- 		based on ip address (subnet), roles
--		assigned (select_emp_sensitive_role)
--		and authentication method.


CREATE OR REPLACE PACKAGE hr_code.pkg_manage_emp 
AUTHID current_user AS

  PROCEDURE pInsEmp(pEmp IN hr_decls.decl.t_emp_t);

END PKG_MANAGE_EMP;
/

create or replace PACKAGE BODY  hr_code.pkg_manage_emp AS

  PROCEDURE pInsEmp(pEmp IN hr_decls.decl.t_emp_t) AS
  iId  	integer;				-- the primary key that will 
								-- be returned by the insert proc.
  BEGIN
	-- for demo purposes, usr1 builds an employee
    -- record and calls pInsEmp.
	-- insert a row into the employees record.
    -- do all the business logic then do the insert.
    hr_api.pkg_emp_insert.pInsEmp(pEmp => pEmp, pID => iId);
	-- print the employee id.
	sys.dbms_output.put_line('employee id = ' || to_char(iId));
  END pInsEmp;

END pkg_manage_emp;
/

grant 
	execute on hr_code.pkg_manage_emp 
to exec_hr_emp_code_role;
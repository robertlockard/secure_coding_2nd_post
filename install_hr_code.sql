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

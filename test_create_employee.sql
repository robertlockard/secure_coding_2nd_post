conn usr1/x@orcl

declare
	rEmp 	hr_decls.decl.t_emp_t;
begin
	rEmp.first_name 	:= 'Rob';
	rEmp.last_name  	:= 'Lockard';
	rEmp.email			:= 'rob@oraclewizard.com';
	rEmp.phone_number	:= '+1.571.276.4790';
	rEmp.hire_date		:= trunc(sysdate);
	rEmp.job_id			:= 'AD_VP';
	rEmp.salary			:= 999999;
	rEmp.commission_pct	:= .5;
	rEmp.manager_id		:= 123;
	rEmp.department_id	:= 50;
	rEmp.ssn			:= '111-11-1111';
	-- insert the row.
	hr_code.pkg_manage_emp.pInsEmp(pEmp => rEmp);
	commit;
end;
/

-- change hr.employees table to hold ssn.
-- this will be needed to support the redaction
-- features we will explore at a later time.
-- for my friends who are not familier with
-- ssn. it is the sensitive identifiecation
-- number for all US Citizens.
-- this script is run only one time to get
-- the employees table in the format we need
-- for further functionality.

declare
  procedure Add_Column( pTable  in varchar2,
						pColumn in varchar2, 
						pTypeSize IN VARCHAR2) is
    Column_Exists exception;
    pragma Exception_Init(Column_Exists, -01430);
  begin
	
    execute immediate 'Alter Table ' || pTable || 
					' add ' || pColumn || ' ' ||
					pTypeSize;
  exception when Column_Exists then NULL;
  end Add_Column;
begin
	Add_Column(pTable => 'hr.employees',
			   pColumn => 'ssn',
			   pTypeSize => 'varchar2(11)');
end;
/

-- populate ssn with random data in the correct format.
update hr.employees set ssn = 
		floor(sys.dbms_random.value(0,9)) ||
		floor(sys.dbms_random.value(0,9)) ||
		floor(sys.dbms_random.value(0,9)) || '-' ||
		floor(sys.dbms_random.value(0,9)) ||
		floor(sys.dbms_random.value(0,9)) || '-' ||
		floor(sys.dbms_random.value(0,9)) ||
		floor(sys.dbms_random.value(0,9)) ||
		floor(sys.dbms_random.value(0,9)) ||
		floor(sys.dbms_random.value(0,9));
		
COMMIT;
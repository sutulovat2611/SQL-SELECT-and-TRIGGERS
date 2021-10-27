--****PLEASE ENTER YOUR DETAILS BELOW****
--cgh_triggers.sql

--Student ID: 30806151
--Student Name: Tatiana Sutulova
--Tutorial No: Assignment 2B

/* Comments for your marker:
*/


/*
    Trigger1:
     CHG, from now on, would like to implement a new requirement that the gap
     between the cost charged to a patient for a procedure carried out during 
     their admission and the standard procedure cost must be within the range 
     of plus or minus 20%. For example, if a procedure's standard cost is $100,
     the performing doctor or technician must not charge the patient lower than 
     $80 or more than $120 for that procedure. If the admission procedure cost
     is outside the 20% range, the trigger should prevent the action. Code a 
     single trigger to enforce this requirement.
*/
/*Please copy your trigger code with a slash(/) followed by an empty line after this line*/

CREATE OR replace TRIGGER cost_gap
  BEFORE INSERT OR UPDATE OF adprc_pat_cost ON adm_prc
  FOR EACH ROW
--declaration 
DECLARE
    assigned_cost adm_prc.adprc_pat_cost%TYPE; -- standard cost of a procedure
BEGIN
    SELECT proc_std_cost
    INTO   assigned_cost
    FROM   procedure
    WHERE  proc_code = :new.proc_code;
    
    -- checking whether its more expensive than standard price more than by 20%
    IF :new.adprc_pat_cost > assigned_cost * 1.2 THEN
      Raise_application_error(-20000, 'The assigned cost exceeds the limit');
    -- checking whether its cheaper than standard price more than by 20%
    ELSIF :new.adprc_pat_cost < assigned_cost * 0.8 THEN
      Raise_application_error(-20000,'The assigned cost is lower than the limit');
    END IF;
END;
/  

/*Test Harness for Trigger1*/
/*Please copy SQL statements for Test Harness after this line*/

-- display before value
SELECT * FROM  adm_prc;

--insert an invalid value too low
insert into ADM_PRC (ADPRC_NO,ADPRC_DATE_TIME,ADPRC_PAT_COST,ADPRC_ITEMS_COST,ADM_NO,PROC_CODE) 
    values (2611,to_date('01/JUL/2021  05:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),0,0,100010,32266);

--insert an invalid value too high 
insert into ADM_PRC (ADPRC_NO,ADPRC_DATE_TIME,ADPRC_PAT_COST,ADPRC_ITEMS_COST,ADM_NO,PROC_CODE) 
    values (2612,to_date('01/JUL/2021  05:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),20000,0,100010,32266);


-- display after value
SELECT * FROM  adm_prc;

-- closes transaction
rollback;


/*
    Trigger2:
    When a patient is discharged, the discharge date and time value is added 
    into the patient’s admission entry. 
    Once added, the discharge date and time cannot be changed. 
    Code a single trigger that: 
        - check that the discharge date and time is valid, ie. it cannot be 
        before the admission date time or, if any, the last 
        admission procedure’s start date and time 
        (you may ignore the procedure’s duration), and 
        - automatically calculate the value of admission total cost. 
        The admission total cost is the total of patient costs and item costs 
        of all procedures related to the admission plus the admin cost. 
        The admin cost is $50 flat for all patients. When the patient did 
        not undergo any procedure, then they will be charged for the admin 
        cost only.
*/

/*Please copy your trigger code with a slash(/) followed by an empty line after this line*/

CREATE OR REPLACE TRIGGER 
    discharge_date
BEFORE INSERT OR UPDATE OF  
    adm_discharge 
ON  
    admission
FOR EACH ROW 

--declaration
DECLARE
    latest_procedure admission.adm_date_time%type; -- date of the last procedure 
    total_cost admission.adm_total_cost%type; -- total cost which is admin cost + all the items cost + all the patient costs
    
BEGIN 
    -- finds the latests admission procedure 
    SELECT MAX(adprc_date_time )INTO latest_procedure FROM adm_prc WHERE adm_no = :new.adm_no;
     
    -- if discharge is later than the admission
    IF :new.adm_discharge < :new.adm_date_time THEN 
        raise_application_error(-20000, 'The assigned discharge date and time cannot be higher than the admission date and time');
    END IF;
    -- if discharge is later than the last procedure 
    IF :new.adm_discharge < latest_procedure THEN
        raise_application_error(-20001, 'The assigned discharge date and time cannot be higher than the latest procedure date and time'); 
    END IF;
    
    -- finding the total cost for that admission
    SELECT 
        SUM(adprc_pat_cost + adprc_items_cost) 
    INTO total_cost
    FROM adm_prc ap1
    WHERE ap1.adm_no = :new.adm_no;
    
    --updating the value for the admission total cost
    IF total_cost IS NULL THEN --if no procedures
        :new.adm_total_cost:= 50;
    
    ELSIF total_cost IS NOT NULL THEN  
        :new.adm_total_cost:= 50 + total_cost ;
     END IF;
END;
/ 

/*Test Harness for Trigger2*/
/*Please copy SQL statements for Test Harness after this line*/

-- Test 1: Testing when the date of admission is later than the date of discharge 
insert into ADMISSION values (100021,to_date('05/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'), to_date('02/JUL/2021  11:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),50);
-- closes transaction
rollback;

-- Test 2: Testing when the date of the latest admission procedure is later than the date of discharge
insert into ADMISSION values (100022,to_date('02/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'), null,60); --adding a new admission
insert into ADM_PRC  values (1001,to_date('04/JUL/2021  04:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),80,0,100022,32266); -- normal procedure which is not later than discharge
insert into ADM_PRC  values (1002,to_date('11/JUL/2021  04:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),80,0,100022,32266); -- procedure later than discharge
insert into ADM_PRC  values (1003,to_date('10/JUL/2021  04:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),80,0,100280,32266); -- procedure for other admission later than discharge, should not affect

--updating the admission discharge date
UPDATE ADMISSION
SET adm_discharge  = to_date('05/JUL/2021  11:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM')
WHERE adm_no = 100022 ;
SELECT * FROM ADMISSION;
-- closes transaction
rollback;

-- Test 3: Testing whether the total cost is getting updated 
insert into ADMISSION values (100027,to_date('02/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),null,null); -- both discharge date and total cost are null
insert into ADM_PRC  values (1003,to_date('10/JUL/2021  04:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),80,15,100027,32266); -- insert a procedure with pat cost: 80, item cost: 15
insert into ADM_PRC  values (1004,to_date('01/JUL/2021  04:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),250,30,100027,43556);  -- insert a procedure with pat cost: 250, item cost: 30

--Prior state
SELECT * FROM admission;

--Updating the admission setting up its discharge date
UPDATE ADMISSION
SET adm_discharge  = to_date('15/JUL/2021  11:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM')
WHERE adm_no = 100027 ;

--Post state
SELECT * FROM admission;
-- closes transaction
rollback;


-- Test 4: Testing whether the total cost is getting updated with no procedures
insert into ADMISSION values (100027,to_date('02/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),null,null); -- both discharge date and total cost are null

--Prior state
SELECT * FROM admission;

--Updating the admission setting up its discharge date
UPDATE ADMISSION
SET adm_discharge  = to_date('15/JUL/2021  11:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM')
WHERE adm_no = 100027 ;

--Post state
SELECT * FROM admission;

-- closes transaction
rollback;
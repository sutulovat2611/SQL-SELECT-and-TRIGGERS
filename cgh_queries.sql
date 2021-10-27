--cgh_queries.sql
--Author: Tatiana Sutulova

/*
    Q1: 
    List the doctor title, first name, last name and contact phone number for
    all doctors who specialise in the area of "ORTHOPEDIC SURGERY" 
    (this is the specialisation description). Order the list by the doctors' 
    last name and within this, if two doctors have the same last name, order them 
    by their respective first names.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon
-- (;) at the end of this answer

SELECT 
  doctor_title, 
  doctor_fname, 
  doctor_lname, 
  doctor_phone 
FROM 
  cgh.doctor 
WHERE 
  doctor_id IN(
    SELECT 
      doctor_id 
    FROM 
      cgh.doctor_speciality 
    WHERE 
      spec_code =(
        SELECT 
          spec_code 
        FROM 
          cgh.speciality 
        WHERE 
          spec_description = 'Orthopedic surgery'
      )
  ) 
ORDER BY 
  doctor_lname, 
  doctor_fname;
COMMIT;

/*
    Q2:
    List the item code, item description, item stock and the cost centre title 
    which provides these items for all items which have a stock greater than 50 
    items and include the word 'disposable' in their item description. Order the 
    output by the item code.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer

SELECT 
  item_code, 
  item_description, 
  item_stock, 
  cc.cc_title as cc_title 
FROM 
  cgh.item i
  JOIN cgh.costcentre cc ON i.cc_code= cc.cc_code
WHERE 
  i.item_stock > 50 
  AND (
    item_description LIKE '%Disposable' 
    OR item_description LIKE '%Disposable%' 
    OR item_description LIKE 'Disposable%'
  ) 
ORDER BY 
  item_code;
COMMIT;

/*
    Q3: 
     List the patient id, patient's full name as a single column called 'Patient 
     Name', admission date and time and the supervising doctor's full name 
     (including title) as a single column called 'Doctor Name' 
     for all those patients admitted between 10 AM on 11th of September and 6 PM 
     on the 14th of September 2021 (inclusive). Order the output by the admission
     time with the earliest admission first.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT 
  p.patient_id, 
  p.patient_fname || ' ' || p.patient_lname as "Patient Name", 
  a.adm_date_time, 
  d.doctor_fname || ' ' || d.doctor_lname as "Doctor Name" 
FROM 
  CGH.admission a 
  JOIN cgh.patient p ON a.patient_id = p.patient_id 
  JOIN cgh.doctor d ON a.doctor_id = d.doctor_id 
WHERE 
  to_char(
    a.adm_date_time, 'YYYY-MM-DD HH24:MI'
  ) BETWEEN '2021-09-11 10:00' 
  AND '2021-09-14 18:00' 
ORDER BY 
  a.adm_date_time;
COMMIT;

/*
    Q4: List the procedure code, name, description, and standard cost where the 
    procedure is less expensive than the average procedure standard cost. The 
    output must show the most expensive procedure first. The procedure standard 
    cost must be displayed with two decimal points and a leading $ symbol, for 
    example as $120.54
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT 
  proc_code, 
  proc_name, 
  proc_description, 
  LTRIM(TO_CHAR(proc_std_cost, '$99999.99')) AS proced_std_cost
FROM 
  CGH.procedure 
WHERE 
  (
    SELECT 
      AVG(proc_std_cost) AS avg_std_cost 
    FROM 
      CGH.procedure
  ) > proc_std_cost 
ORDER BY 
   proc_std_cost DESC;
COMMIT;
/*
    Q5:
    List the patient id, last name, first name, date of birth and the number of 
    times the patient has been admitted to the hospital where the number of 
    admissions is greater than 2. The output should show patients with the most 
    number of admissions first and for patients with the same number of 
    admissions, show the patients in their date of birth order. 
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
 
SELECT 
  a.patient_id, 
  p.patient_lname, 
  p.patient_fname, 
  p.patient_dob, 
  COUNT(a.patient_id) as patient_adm_no 
FROM 
  CGH.admission a 
  JOIN cgh.patient p ON a.patient_id = p.patient_id 
GROUP BY 
  a.patient_id, 
  p.patient_dob, 
  p.patient_lname, 
  p.patient_fname 
HAVING 
  COUNT(a.patient_id) > 2 
ORDER BY 
  patient_adm_no DESC, 
  p.patient_dob;
COMMIT;
    
/*
    Q6:
    List the admission number, patient id, first name, last name and the length 
    of their stay in the hospital for all patients who have been discharged and 
    who were in the hospital longer than the average stay for all discharged 
    patients. The length of stay must be shown in the form 10 days 2.0 hrs where 
    hours are rounded to one decimal digit. The output must be ordered by 
    admission number.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT 
  a.adm_no, 
  a.patient_id, 
  p.patient_fname, 
  p.patient_lname, 
  FLOOR(adm_discharge - adm_date_time)|| ' days ' || LTRIM(TO_CHAR(((adm_discharge - adm_date_time) - FLOOR(adm_discharge - adm_date_time))* 24, '999990D0')) || ' hour(s)' AS length_of_stay
 FROM 
  CGH.admission a 
  JOIN cgh.patient p ON a.patient_id = p.patient_id 
WHERE 
  adm_discharge IS NOT NULL 
  AND FLOOR(adm_discharge - adm_date_time) > (
    SELECT 
      AVG(
        FLOOR(adm_discharge - adm_date_time)
      ) 
    FROM 
      CGH.admission
  ) 
ORDER BY 
  adm_no;
COMMIT;
/*
    Q7:
    Given a doctor may charge more or less than the standard charge for a 
    procedure carried out during an admission procedure, the hospital 
    administration is interested in finding out what variations on the standard 
    price have been charged. 
    
    The hospital terms the difference between the average 
    actual charged procedure cost which has been charged to patients for all such 
    procedures which have been carried out the procedure standard cost as the 
    "Procedure Price Differential". For all procedures which have been carried 
    out on an admission determine the procedure price differential. The list 
    should show the procedure code, name, description, standard time, standard 
    cost and the procedure price differential in procedure code order. 
    
    For example 
    procedure 15509 "X-ray, Right knee" has a standard cost of $70.00, it may have 
    been charged to admissions on average across all procedures carried out for 
    $75.00 - the price differential here will be 75 - 70 that is a price 
    differential +5.00 If the average charge had been say 63.10 the price 
    differential will be -6.90.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
   
SELECT 
  a.proc_code, 
  p.proc_name, 
  p.proc_description, 
  p.proc_time, 
  p.proc_std_cost, 
  ROUND(AVG(a.adprc_pat_cost) - p.proc_std_cost, 2) AS "Procedure Price Differential" 
FROM 
  CGH.adm_prc a 
  JOIN cgh.procedure p ON a.proc_code = p.proc_code 
GROUP BY 
  a.proc_code, 
  p.proc_name, 
  p.proc_description, 
  p.proc_time, 
  p.proc_std_cost 
ORDER BY 
  a.proc_code;
COMMIT;
/*
    Q8:
    For every procedure, list the items which have been used and the maximum 
    number of those items used when the procedure was carried out on an admission. 
    Your list must show the procedure code, procedure name, item code and item 
    description and the maximum quantity of this item used for the given procedure.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer

SELECT
    p.proc_code,
    p.proc_name,
    NVL (it.item_code,'---' ) as item_code,
    NVL(i.item_description, '---') as item_description ,
    NVL(TO_CHAR(MAX(it_qty_used)), '---') as max_quan_item
FROM
    cgh.item_treatment it
JOIN 
    cgh.item i ON i.item_code = it.item_code  
FULL OUTER JOIN
    cgh.adm_prc ap ON ap.adprc_no=it.adprc_no
FULL OUTER JOIN
    cgh.procedure p ON p.proc_code=ap.proc_code
GROUP BY 
    p.proc_code,
    p.proc_name,
    i.item_description,
    it.item_code
ORDER BY
    p.proc_name,
    it.item_code;
COMMIT;  

/*
    Q9b:
    Your report must show the admission procedure number, the procedure code, 
    the admission number, the patient id who this procedure was carried out on, 
    the date and time (time in 24 hour format) that the procedure was carried 
    out and the total cost for the procedure. The total cost will be the cost 
    charged to this patient for this procedure plus the cost for extra items 
    required. The output should be in admission procedure number order.
*/
-- PLEASE PLACE REQUIRED SQL STATEMENT FOR THIS PART HERE
-- ENSURE that your query is formatted and has a semicolon (;)
-- at the end of this answer
SELECT 
    ap.adprc_no,
    ap.proc_code,
    ap.adm_no,
    pt.patient_id,
    TO_CHAR( ap.adprc_date_time, 'YYYY-MM-DD HH24:MI') AS proc_date_time,
    (ap.adprc_pat_cost + ap.adprc_items_cost) AS total_cost
FROM 
    CGH.adm_prc ap
JOIN
    cgh.admission a ON ap.adm_no=a.adm_no
JOIN 
    cgh.patient pt ON pt.patient_id = a.patient_id
WHERE 
    8 = (
SELECT 
    COUNT( 
        DISTINCT 
            (ap2.adprc_pat_cost + ap2.adprc_items_cost)
        )
FROM 
    CGH.adm_prc ap2
WHERE 
    (ap2.adprc_pat_cost + ap2.adprc_items_cost) > (ap.adprc_pat_cost + ap.adprc_items_cost)
)
ORDER BY
     ap.adprc_no;
COMMIT;

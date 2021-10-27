SET ECHO ON;

DROP TABLE adm_prc CASCADE CONSTRAINTS;

DROP TABLE admission CASCADE CONSTRAINTS;

DROP TABLE procedure CASCADE CONSTRAINTS;


CREATE TABLE adm_prc (
    adprc_no          NUMBER(7) NOT NULL,
    adprc_date_time   DATE NOT NULL,
    adprc_pat_cost    NUMBER(7, 2) NOT NULL,
    adprc_items_cost  NUMBER(6, 2) NOT NULL,
    adm_no            NUMBER(6) NOT NULL,
    proc_code         NUMBER(5) NOT NULL
);

COMMENT ON COLUMN adm_prc.adprc_no IS
    'Admission procedure identifier (PK)';

COMMENT ON COLUMN adm_prc.adprc_date_time IS
    'Date and time this procedure was carried out for this admission';

COMMENT ON COLUMN adm_prc.adprc_pat_cost IS
    'Charge to patient for this procedure';

COMMENT ON COLUMN adm_prc.adprc_items_cost IS
    'Total patient charge for extra items required';

COMMENT ON COLUMN adm_prc.adm_no IS
    'Admission number (PK)';

COMMENT ON COLUMN adm_prc.proc_code IS
    'Procedure code (PK)';

ALTER TABLE adm_prc ADD CONSTRAINT adm_prc_pk PRIMARY KEY ( adprc_no );

ALTER TABLE adm_prc ADD CONSTRAINT adm_prc_nk UNIQUE ( adprc_date_time,
                                                       adm_no );

CREATE TABLE admission (
    adm_no          NUMBER(6) NOT NULL,
    adm_date_time   DATE NOT NULL,
    adm_discharge   DATE,
    adm_total_cost  NUMBER(8, 2)
);

COMMENT ON COLUMN admission.adm_no IS
    'Admission number (PK)';

COMMENT ON COLUMN admission.adm_date_time IS
    'Admission date and time';

COMMENT ON COLUMN admission.adm_discharge IS
    'Discharge date and time';

COMMENT ON COLUMN admission.adm_total_cost IS
    'Admission total cost';

ALTER TABLE admission ADD CONSTRAINT admission_pk PRIMARY KEY ( adm_no );

CREATE TABLE procedure (
    proc_code         NUMBER(5) NOT NULL,
    proc_name         VARCHAR2(100) NOT NULL,
    proc_description  VARCHAR2(300) NOT NULL,
    proc_time         NUMBER(3) NOT NULL,
    proc_std_cost     NUMBER(7, 2) NOT NULL
);

COMMENT ON COLUMN procedure.proc_code IS
    'Procedure code (PK)';

COMMENT ON COLUMN procedure.proc_name IS
    'Procedure Name';

COMMENT ON COLUMN procedure.proc_description IS
    'Procedure Description';

COMMENT ON COLUMN procedure.proc_time IS
    'Standard time required for this procedure in mins';

COMMENT ON COLUMN procedure.proc_std_cost IS
    'Standard cost for procedure';

ALTER TABLE procedure ADD CONSTRAINT procedure_pk PRIMARY KEY ( proc_code );

ALTER TABLE procedure ADD CONSTRAINT proc_name_unq UNIQUE ( proc_name );

ALTER TABLE adm_prc
    ADD CONSTRAINT admission_admprc FOREIGN KEY ( adm_no )
        REFERENCES admission ( adm_no );

ALTER TABLE adm_prc
    ADD CONSTRAINT procedure_admproc FOREIGN KEY ( proc_code )
        REFERENCES procedure ( proc_code );
        
--admission data
insert into ADMISSION (ADM_NO,ADM_DATE_TIME,ADM_DISCHARGE, ADM_TOTAL_COST) values (100010,to_date('01/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),to_date('08/JUL/2021  11:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),957.81);
insert into ADMISSION (ADM_NO,ADM_DATE_TIME,ADM_DISCHARGE, ADM_TOTAL_COST) values (100020,to_date('01/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),to_date('03/JUL/2021  11:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),50);
insert into ADMISSION (ADM_NO,ADM_DATE_TIME,ADM_DISCHARGE, ADM_TOTAL_COST) values (100280,to_date('13/OCT/2021  09:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),null,null);

--procedure data
insert into PROCEDURE (PROC_CODE,PROC_NAME,PROC_DESCRIPTION,PROC_TIME,PROC_STD_COST) values (15511,'MRI','Imaging of brain',90,200);
insert into PROCEDURE (PROC_CODE,PROC_NAME,PROC_DESCRIPTION,PROC_TIME,PROC_STD_COST) values (17122,'Childbirth','Caesarean section',80,500);
insert into PROCEDURE (PROC_CODE,PROC_NAME,PROC_DESCRIPTION,PROC_TIME,PROC_STD_COST) values (32266,'Hemoglobin concentration','Measuring oxygen carrying protein in blood',15,76);
insert into PROCEDURE (PROC_CODE,PROC_NAME,PROC_DESCRIPTION,PROC_TIME,PROC_STD_COST) values (43556,'Vascular surgery','Removel of varicose veins',120,243.1);
insert into PROCEDURE (PROC_CODE,PROC_NAME,PROC_DESCRIPTION,PROC_TIME,PROC_STD_COST) values (65554,'Blood screen','Full blood test',10,30);

--adm_prc data
insert into ADM_PRC (ADPRC_NO,ADPRC_DATE_TIME,ADPRC_PAT_COST,ADPRC_ITEMS_COST,ADM_NO,PROC_CODE) values (1000,to_date('01/JUL/2021  04:00:00 PM','DD/MON/YYYY  HH12:MI:SS AM'),80,0,100010,32266);
insert into ADM_PRC (ADPRC_NO,ADPRC_DATE_TIME,ADPRC_PAT_COST,ADPRC_ITEMS_COST,ADM_NO,PROC_CODE) values (1010,to_date('05/JUL/2021  08:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),250,547.81,100010,43556);
insert into ADM_PRC (ADPRC_NO,ADPRC_DATE_TIME,ADPRC_PAT_COST,ADPRC_ITEMS_COST,ADM_NO,PROC_CODE) values (1020,to_date('06/JUL/2021  07:00:00 AM','DD/MON/YYYY  HH12:MI:SS AM'),30,0,100010,65554);

commit;

-- Instructions: 
-- 1) Alter the database names to match yours in the places indicated.
-- 2) The OMOPLoader.sql script must be run first also
-- 3) Make sure to have the PCORNet ontology loaded and mapped: https://github.com/SCILHS/scilhs-ontology
-- 4) For testing, change the 100000000 number to something small, like 10000
-- 5) Run this from the database with the OMOP transforms and tables.   
-- 
-- All data from 1-1-2010 is transformed.
-- Jeff Klann, PhD, and Matthew Joss
--------------------------------------------------------------------------------------------------------------------------
use eMERGE_OMOP_Mart
drop table i2b2patient_list
GO

-- Make 100000000 number smaller for testing
select distinct top 100000000 f.patient_num into i2b2patient_list from i2b2fact f
--inner join i2b2visit v on f.patient_num=v.patient_num
-- where f.start_date>='20100101' and v.start_date>='20100101'
GO
-- Change to match your database names
drop synonym i2b2patient;
GO
drop view i2b2patient;
GO
-- Change to match your database name
create view i2b2patient as select * from eMERGE_OMOP_Mart..patient_dimension where patient_num in (select patient_num from i2b2patient_list)
GO
drop synonym i2b2visit;
GO
drop view i2b2visit;
GO
-- Change to match your database name
create view i2b2visit as select * from eMERGE_OMOP_Mart..visit_dimension where (end_date is null or end_date<getdate());
GO




--exec pcornetloader;
--GO
exec OMOPclear
GO
delete from observation
GO
delete from Provider
GO
exec OMOPProvider --added for v4.0, needs to be run first. 
GO
delete from person
GO
exec OMOPdemographics
GO
delete from visit_occurrence
GO
exec OMOPencounter
GO
delete from observation_period
GO
exec OMOPobservationperiod
GO
delete from condition_occurrence
GO
exec OMOPdiagnosis
GO
delete from procedure_occurrence
GO
exec OMOPprocedure
GO
delete from measurement
GO
exec omopVital
GO
exec omopLabResultCM
GO
delete from drug_exposure
GO
exec OMOPdrug_exposure
GO
exec OMOPprocedure_secondary -- Add procedures as specified by OMOP to all the non-procedure tables
GO
delete from drug_era
GO
delete from condition_era
GO
exec OMOPera
GO
delete from death
GO
exec OMOPdeath
GO
delete from i2pReport
GO
exec omopReport
GO
select * from i2pReport;

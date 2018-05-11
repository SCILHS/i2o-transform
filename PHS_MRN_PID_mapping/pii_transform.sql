USE [AllOfUs_Mart]
GO
/****** Object:  StoredProcedure [dbo].[pii_transform]    Script Date: 5/7/2018 2:55:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[pii_transform]  as

declare addresses cursor local for
select p.person_id, cap.address_line1 as address_1, cap.address_line2 as address_2, cap.city, cap.state, cap.zip from constrack_aou_participants cap
join person p on substring(cap.person_id, 2, 12) = p.person_id;

declare @person_id integer, @address_1 varchar(120), @address_2 varchar(120), @city varchar(120), @state varchar(120), @zip varchar(120), @location_id integer

begin

--Clear all previous values
delete PII_NAME;
delete PII_EMAIL;
delete PII_PHONE_NUMBER;
delete PII_ADDRESS;
delete PII_MRN;


insert into dbo.PII_NAME
Select p.person_id, cap.firstname as first_name, cap.middle_name, cap.lastname as last_name, cap.suffix, cap.prefix from constrack_aou_participants cap
join person p on substring(cap.person_id, 2, 12) = p.person_id

insert into dbo.PII_PHONE_NUMBER
Select p.person_id, cap.work_phone as phone_number from constrack_aou_participants cap
join person p on substring(cap.person_id, 2, 12) = p.person_id where cap.work_phone is not null and cap.work_phone != ''
union
Select p.person_id, cap.home_phone as phone_number from constrack_aou_participants cap
join person p on substring(cap.person_id, 2, 12) = p.person_id where cap.home_phone is not null and cap.home_phone != ''

insert into dbo.PII_MRN
select p.person_id, amm.company_cd as health_system, amm.MRN 
from constrack_aou_participants cap
join person p on substring(cap.person_id, 2, 12) = p.person_id
join aou_mapping am on am.pmi_id = cap.person_id
join mrn_mapping mm on mm.mrn= am.mrn and am.mrn_facility = mm.company_cd 
join mrn_mapping amm on mm.empi = amm.empi
where amm.mrn is not null and amm.mrn != ''

open addresses ;
fetch next from addresses  into @person_id, @address_1, @address_2, @city, @state, @zip;
while @@fetch_status=0
begin	
SET @location_id = NEXT VALUE FOR location_id_Seq;
 insert into location (location_id, address_1, address_2, city, state, zip, county, location_source_value)
	values (@location_id,@address_1, @address_2, @city, @state, @zip, null, null);
 insert into PII_ADDRESS (person_id, location_id) values (@person_id, @location_id);
fetch next from addresses  into @person_id, @address_1, @address_2, @city, @state, @zip;
end
end

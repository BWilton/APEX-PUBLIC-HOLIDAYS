-- sequence used for all holiday related records
create sequence holiday_seq;
/

CREATE TABLE HOLIDAY_TBL
   (	ID NUMBER primary key, 
HOLIDAY_NAME varchar2(255),   
National_holiday_yn varchar2(1),
	CREATED_DATE DATE NOT NULL ENABLE, 
	CREATED_BY VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	UPDATED_DATE DATE, 
	UPDATED_BY VARCHAR2(20 BYTE));
/
 COMMENT ON TABLE HOLIDAY_TBL  IS 'This table holds the names for all the holidays';	
 /
 CREATE OR REPLACE TRIGGER HOLIDAY_TRG
before insert or update ON aug_public_holiday
for each row
begin
if inserting then
   :new.created_date := sysdate;
   :new.created_by   := nvl(v('APP_USER'),user);
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
   if :new.iD is null then
     :new.id := holiday_seq.nextval;
   end if;
elsif updating then
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
end if;
END;
/

CREATE TABLE HOLIDAY_date_TBL
   (	ID NUMBER primary key, 
	holiday_id VARCHAR2(255 BYTE), 
	HOLIDAY_DATE DATE NOT NULL ENABLE, 
	CREATED_DATE DATE NOT NULL ENABLE, 
	CREATED_BY VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	UPDATED_DATE DATE, 
	UPDATED_BY VARCHAR2(20 BYTE));

   COMMENT ON TABLE HOLIDAY_date_TBL  IS 'This table holds all national and regional public holidays plus days that the organization is closed for business e.g. the 3 days between Christmas and New Years';

CREATE OR REPLACE TRIGGER HOLIDAY_date_Trg
before insert or update ON aug_public_holiday
for each row
begin
if inserting then
   :new.created_date := sysdate;
   :new.created_by   := nvl(v('APP_USER'),user);
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
   if :new.iD is null then
     :new.id := holiday_seq.nextval;
   end if;
elsif updating then
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
end if;
END;
/

CREATE TABLE Additional_date_TBL
   (	ID NUMBER primary key, 
	HOLIDAY_DATE DATE NOT NULL ENABLE, 
	LOCATION_ID number not null,
	CREATED_DATE DATE NOT NULL ENABLE, 
	CREATED_BY VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	UPDATED_DATE DATE, 
	UPDATED_BY VARCHAR2(20 BYTE));

   COMMENT ON TABLE Additional_date_TBL  IS 'This table additional non-working days specific to a site ';

CREATE OR REPLACE TRIGGER Additional_date_Trg
before insert or update ON Additional_date_TBL
for each row
begin
if inserting then
   :new.created_date := sysdate;
   :new.created_by   := nvl(v('APP_USER'),user);
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
   if :new.iD is null then
     :new.id := holiday_seq.nextval;
   end if;
elsif updating then
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
end if;
END;
/


Create or replace table location_tbl
(id number primary key,
location_name varchar2(255),
	CREATED_DATE DATE NOT NULL ENABLE, 
	CREATED_BY VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	UPDATED_DATE DATE, 
	UPDATED_BY VARCHAR2(20 BYTE)
	);
	/
COMMENT ON TABLE location_tbl  IS 'This table holds a list of all locations';
	
CREATE OR REPLACE TRIGGER location_trg
before insert or update ON location_tbl
for each row
begin
if inserting then
   :new.created_date := sysdate;
   :new.created_by   := nvl(v('APP_USER'),user);
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
   if :new.iD is null then
     :new.id := holiday_seq.nextval;
   end if;
elsif updating then
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
end if;
END;
/	



Create or replace table location_holiday_tbl
(id number primary key,
location_id number,
holiday_id number,
	CREATED_DATE DATE NOT NULL ENABLE, 
	CREATED_BY VARCHAR2(20 BYTE) NOT NULL ENABLE, 
	UPDATED_DATE DATE, 
	UPDATED_BY VARCHAR2(20 BYTE)
	);
	/
COMMENT ON TABLE location_tbl  IS 'This table holds a list of all which holidays apply to which location';
/	
CREATE OR REPLACE TRIGGER location_holiday_trg
before insert or update ON location_holiday_tbl
for each row
begin
if inserting then
   :new.created_date := sysdate;
   :new.created_by   := nvl(v('APP_USER'),user);
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
   if :new.iD is null then
     :new.id := holiday_seq.nextval;
   end if;
elsif updating then
   :new.updated_date := sysdate;
   :new.updated_by   := nvl(v('APP_USER'),user);
end if;
END;
/	

create or replace function is_holiday (
p_date in date,
p_location_id in number default null)
return 
booleen as
begin

select 1 from HOLIDAY_date_TBL hdt,
location_holiday_tbl lht,
holiday_tbl ht
where 
ht.id = ht.holiday_id
and (ht.National_holiday_yn = 'Y' or 
     (lht.location_id = p_location_id and p_location_id is not null ))
and lht.holiday_id = hdt.holiday_id
union 
select 1 from additional_date_tbl where p_date = HOLIDAY_DATE and 
LOCATION_ID = p_location_id;


return true;
exception when no_data_found then
return false;
end is_holiday;
/

create or replace function is_holiday_yn (
p_date in date,
p_location_id in number default null)
return 
varchar2 as
begin
if is_holiday (p_date => p_date ,
p_location_id => p_location_id) then
return 'Y';
else
return 'N';
end if;
end is_holiday_yn;
/

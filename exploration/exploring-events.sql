select * from INFORMATION_SCHEMA.tables where table_name like '%event%';

select top 100 * from Powerbi.Events;

exec sp_helptext 'PowerBI.Events';


-- crm_msevtmgt_eventregistration
-- crm_msevtmgt_event

select top 100 * from crm_msevtmgt_event;

/* columns of interest:
 * msevtmgt_isrecurringevent
 * msevtmgt_customeventurl
 * msevtmgt_building
 * msevtmgt_eventenddate
 * msevtmgt_name
 * msevtmgt_eventstartdate
 * msevtmgt_externaleventtitle
 * dfe_eventstatus
 * dfe_providercontactemailaddress
 * dfe_websiteeventpartialurl
 * dfe

*/

select top 1000
    e.Id as id,
    e.msevtmgt_isrecurringevent as is_recurring,
    e.msevtmgt_customeventurl as custom_url,
    b.msevtmgt_name as building_name,
    e.msevtmgt_eventenddate as end_date,
    e.msevtmgt_name as name,
    e.msevtmgt_eventstartdate as start_date,
    e.dfe_externaleventtitle as external_name,
    e.dfe_eventstatus as status,
    e.dfe_providercontactemailaddress as provider_contact_email_address,
    e.dfe_websiteeventpartialurl as partial_url
from
    crm_msevtmgt_event e
inner join
    crm_msevtmgt_building b on e.msevtmgt_building = b.Id


select * from INFORMATION_SCHEMA.tables where table_name like '%check%';

select top 100 *
from crm_msevtmgt_building



select top 500 * from crm_OptionSetMetadata

select [option], count(*) from crm_OptionSetMetadata group by [option] order by count(*) desc

select * from crm_OptionSetMetadata where [option] = 222750000;


select distinct optionsetname from crm_OptionSetMetadata;

select * from crm_OptionSetMetadata where optionsetname = 'dfe_eventstatus'

select top 1000 * from crm_msevtmgt_checkin


select top 1000 *
from crm_msevtmgt_eventregistration

-- this should probably be the 'event_registration' view
select top 1000
    er.Id as id,
    er.msevtmgt_eventid as event_id,
    er.msevtmgt_name as name,
    -- er.msevtmgt_contactidyominame as contact_name,
    er.msevtmgt_contactid as contact_id,
    c.Id as checkin_id,
    case
    when c.id is not null 
        then 'yes'
    when e.msevtmgt_eventenddate > dateadd(week, -1, getdate())
        -- the event was recent, there's still time for attendence to be confirmed
        then 'unknown'
    else 'no'
    end as attended

from
    crm_msevtmgt_eventregistration er
left outer join
    crm_msevtmgt_checkin c on er.Id = c.msevtmgt_registrationid
inner join
    crm_msevtmgt_event e on er.msevtmgt_eventid = e.Id
order by e.msevtmgt_eventenddate desc


select top 1000
    er.msevtmgt_contactid as contact_id,
    count(*) as quantity
from
    crm_msevtmgt_eventregistration er
group by
    er.msevtmgt_contactid
order by
    quantity desc;

select
    er.msevtmgt_eventid as event_id,
    er.msevtmgt_contactidyominame as contact_name,
    er.msevtmgt_name as name,
    c.Id
from
    crm_msevtmgt_eventregistration er
left outer join
    crm_msevtmgt_checkin c on er.Id = c.msevtmgt_registrationid
where er.msevtmgt_contactid = 'e7d1c859-b86a-e911-a824-000d3ab08ce9';



select statuscode, count(*) from crm_msevtmgt_eventregistration group by statuscode;




select
    cast(e.msevtmgt_eventstartdate as date) as start_date,
    count(*)
from
    crm_msevtmgt_event e
group by 
    e.msevtmgt_eventstartdate;

select top 100 *
from crm_msevtmgt_checkin;


select count(*) from crm_msevtmgt_eventregistration




select top 100 * from crm_msevtmgt_eventregistration order by createdon desc

-- channel creation

select * from crm_OptionSetMetadata where optionsetname = 'dfe_channelcreation'


select distinct optionsetname
from crm_OptionSetMetadata
where optionsetname like '%channel%'
order by OptionSetName


/* Mailing list stuff */

select * from information_schema.views where table_name like '%mail%';

-- no permissions, definition is empty
select * from sys.sql_modules where object_id = OBJECT_ID('PowerBI.DFE_MailingListSignup');

select top 100 * from  crm_dfe_candidatejourneystep;

select top 100 * from  crm_dfe_teachingsubjectlist;

select * from information_schema.tables where table_name like '%candidate%';

select top 100 * from crm_dfe_candidateschoolexperience;

select top 100 * from crm_dfe_candidatepastteachingposition;

select top 100 * from 

select * from information_schema.columns where column_name like '%mailing%'

select top 1000 table_schema, table_name, column_name, ordinal_position, data_type from information_schema.columns where table_name = 'crm_contact' and table_schema = 'dbo' and column_name like 'dfe%' order by ordinal_position asc;

select top 100 * from crm_dfe_config
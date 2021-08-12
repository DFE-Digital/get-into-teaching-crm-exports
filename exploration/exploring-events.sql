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


select * from INFORMATION_SCHEMA.tables where table_name like '%building%';

select top 100 *
from crm_msevtmgt_building



select top 1000 *
from crm_msevtmgt_eventregistration


select top 1000
    er.Id as id,
    er.msevtmgt_eventid as event_id,
    er.msevtmgt_name as name,
    -- er.msevtmgt_contactidyominame as contact_name,
    er.msevtmgt_contactid as contact_id

from
    crm_msevtmgt_eventregistration er

/go
-- create view git.event_registrations as (
select
    top 1000
    er.Id as id,
    er.msevtmgt_eventid as event_id,
    er.msevtmgt_contactid as contact_id,
    case
    when c.id is not null 
        then 'yes'
    when e.msevtmgt_eventenddate > dateadd(week, -1, getdate())
        -- the event was recent (or hasn't happened yet), 
        -- there's still time for attendence to be confirmed
        then 'unknown'
    else 'no'
    end as attended,
    convert(smalldatetime, er.createdon) as registered_on,
    convert(smalldatetime, c.createdon) as attendence_confirmed_on,
    md.LocalizedLabel as creation_channel

from
    crm_msevtmgt_eventregistration er
left outer join
    crm_msevtmgt_checkin c 
        on er.Id = c.msevtmgt_registrationid
inner join
    crm_msevtmgt_event e 
        on er.msevtmgt_eventid = e.Id
inner join 
    crm_OptionSetMetadata md
        on er.dfe_channelcreation = md.[Option]
        and md.OptionSetName = 'dfe_channelcreation'

order by
    e.msevtmgt_eventenddate desc
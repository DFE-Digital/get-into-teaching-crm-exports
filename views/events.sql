-- create view git.events as (
select
    top 1000
    e.Id as id,
    b.msevtmgt_name as venue,
    convert(smalldatetime, e.msevtmgt_eventstartdate) as starts_at,
    convert(smalldatetime, e.msevtmgt_eventenddate) as finishes_at,
    convert(date, e.msevtmgt_eventstartdate) as date,
    e.msevtmgt_name as name,
    md.LocalizedLabel as status,
    e.dfe_websiteeventpartialurl as partial_url
from
    crm_msevtmgt_event e
inner join
    crm_msevtmgt_building b
        on e.msevtmgt_building = b.Id
inner join
    crm_OptionSetMetadata md
        on e.dfe_eventstatus = md.[Option]
        and md.OptionSetName = 'dfe_eventstatus'
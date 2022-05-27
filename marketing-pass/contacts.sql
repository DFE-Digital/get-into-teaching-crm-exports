drop table if exists fuzzy.apply_contacts;

-- create a copy of the data we want with readable
-- column names in the fuzzy schema
-- we're using a table here rather than a view so
-- we can index/manipulate it if we need to...
--
-- note we're replacing â€™ with a "'" to replace
-- fancy quotes with regular ones
select
    trim(lower(emailaddress1)) as email_address,
    replace(trim(lower(firstname)), 'â€™', '''') as first_name,
    replace(trim(lower(lastname)), 'â€™', '''') as last_name,
    trim(lower(birthdate)) as date_of_birth,
    replace(trim(lower(address1_postalcode)), ' ', '') as postcode,
    replace(trim(lower(address1_telephone1)), ' ', '') as phone,
    trim(lower(dfe_applyid)) as apply_id,
    cast(year(try_convert(date, birthdate, 103)) as char(4)) as date_of_birth_year,
    cast(month(try_convert(date, birthdate, 103)) as char(2)) as date_of_birth_month,
    cast(day(try_convert(date, birthdate, 103)) as char(2)) as date_of_birth_day

into
    fuzzy.apply_contacts
from
    [powerbi].[crm_contact_applyData_26052022] 
;

drop table if exists fuzzy.crm_contacts;

-- same for crm contacts, this time we'll bring
-- the contact id along too...
--
-- here we're omitting the records that were
-- created by Apply so we don't try and fuzzily
-- match like for like
--
-- also omit contacts who have already been linked
-- to apply via their applyid
select
    trim(lower(c.emailaddress1)) as email_address,
    trim(lower(c.firstname)) as first_name,
    trim(lower(c.lastname)) as last_name,
    format(c.birthdate, 'dd/MM/yyyy') as date_of_birth,
    replace(trim(lower(c.address1_postalcode)), ' ', '') as postcode,
    replace(trim(lower(c.address1_telephone1)), ' ', '') as phone,
    trim(lower(c.dfe_applyid)) as apply_id,
    c.id as contact_id,
    cast(year(c.birthdate) as char(4)) as date_of_birth_year,
    cast(month(c.birthdate) as char(2)) as date_of_birth_month,
    cast(day(c.birthdate) as char(2)) as date_of_birth_day

into
    fuzzy.crm_contacts
from
    [dbo].[crm_contact] c
left outer join
    -- dynamics central EAV lookup
    crm_OptionSetMetadata cc
        on c.dfe_channelcreation = cc.[Option]
        and cc.OptionSetName = 'dfe_channelcreation'
        and cc.entityname = 'contact'
left outer join
    powerbi.crm_contact pc
        on c.id = pc.id
where
    cc.localizedLabel <> 'Apply for Teacher Training'
and
    c.dfe_applyid is null
and
    pc.isduplicate is null
;

create index apply_first_name on fuzzy.apply_contacts (first_name);
create index apply_last_name on fuzzy.apply_contacts (last_name);

create index crm_first_name on fuzzy.crm_contacts (first_name);
create index crm_last_name on fuzzy.crm_contacts (last_name);
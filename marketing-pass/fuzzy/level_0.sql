-- New level: emails match exactly
-- ordinarily these should've just been matched by GIT/BAT datasharing
insert into fuzzy.matches
select distinct
    a.email_address,
    a.first_name,
    a.last_name,
    a.date_of_birth,
    a.postcode,
    a.phone,

    c.email_address,
    c.first_name,
    c.last_name,
    c.date_of_birth,
    c.postcode,
    c.phone,

    a.apply_id,
    c.contact_id,
    0

from
    fuzzy.apply_contacts a
inner join
    fuzzy.crm_contacts c 
        on a.email_address = c.email_address
;
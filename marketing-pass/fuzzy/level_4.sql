-- 4.1 Identify and deal with any double-matches
--
-- We're ignoring this, we don't mind duplicates in matches as we'll
-- group them and `min` the level on the way out
--
-- 4.2 Match exactly on name where GiT DOB is NULL
--
-- do this!
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
    4

from
    fuzzy.apply_contacts a
inner join
    fuzzy.crm_contacts c 
        on
            -- ON (a.dob is null 
            -- 	and a.Lastname=b.Lastname
            -- 	and a.FirstName=b.FirstName)
            (
                    c.date_of_birth is null
                and
                    a.first_name = c.first_name
                and
                    a.last_name = c.last_name
            )
;
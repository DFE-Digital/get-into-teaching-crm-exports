-- 3.2 Match on first five characters of Firstname and first five characters of Lastname and DOB
-- * or first five characters of Firstname, first five characters of Lastname and DOB month-day swapped
-- * or first five characters of Firstname and full Lastname and within 1 character on DOB
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
    2

from
    fuzzy.apply_contacts a
inner join
    fuzzy.crm_contacts c 
        on a.first_name = c.first_name
        and a.last_name = c.last_name
where
    a.email_address <> c.email_address
and
    a.first_name is not null
and
    a.first_name not in (' ', '.')
and
    (a.first_name <> 'a' and a.last_name <> 'b')
and (
	-- (left(a.FirstName,5)=left(b.FirstName,5) and left(a.LastName,5)=left(b.LastName,5) and a.dob=b.dob)
	-- or
	-- (left(a.FirstName,5)=left(b.FirstName,5) and left(a.LastName,5)=left(b.LastName,5) 
	-- and (year(a.dob)=year(b.dob) and month(a.dob)=day(b.dob) and day(a.dob)=month(b.dob)))
    (
            left(a.first_name, 5) = left(c.first_name, 5)
        and
            left(a.last_name, 5) = left(c.last_name, 5)
    )

    and (
            a.date_of_birth = c.date_of_birth
        or
            (
                    a.date_of_birth_year = c.date_of_birth_year
                and
                    a.date_of_birth_month = c.date_of_birth_day
                and
                    a.date_of_birth_day = c.date_of_birth_month
            )
    )
);
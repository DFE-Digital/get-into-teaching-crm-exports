-- 3.3 Match on edit-distance=<2 on first five characters of Firstname, exactly on first five characters of
-- Lastname, and exactly on DOB
-- or first five characters of Firstname exactly, edit_distance=<1 on first five characters of Lastname, and DOB exactly
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
    3

from
    fuzzy.apply_contacts a
inner join
    fuzzy.crm_contacts c

    -- ON (
    -- 	(TAD_UserSpace.DataInsights.Edit_Distance_Within(left(a.FirstName,5),left(b.FirstName,5),2) <> 999
    -- 	and left(a.LastName,5)=left(b.LastName,5)
    -- 	and a.dob=b.dob)
    -- 	or
    -- 	(left(a.Firstname,5)=left(b.Firstname,5)
    -- 	and TAD_UserSpace.DataInsights.Edit_Distance_Within(left(a.Lastname,5),left(b.Lastname,5),1) <> 999
    -- 	and a.dob=b.dob)
    -- 	)
        on
            (
                    (
                            fuzzy.lev(left(a.first_name, 5), left(c.first_name, 5), 2) <> 999
                        and
                            left(a.last_name, 5) = left(c.last_name, 5)
                    )
                or
                    (
                            left(a.first_name, 5) = left(c.first_name, 5)
                        and
                            fuzzy.lev(left(a.last_name, 5), left(c.last_name, 5), 2) <> 999

                    )
            )
        and
            (a.date_of_birth = c.date_of_birth)
;
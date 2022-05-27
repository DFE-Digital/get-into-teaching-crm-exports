-- 3.1 Match exactly on Firstname and Lastname, and within 1 character on DOB
-- * or within 2 characters on just year/month/date of DOB (i.e. 2 characters on one part where other parts match)
-- * or where month and date are swapped.
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
    1

from
    fuzzy.apply_contacts a
inner join
    fuzzy.crm_contacts c 
        on a.first_name = c.first_name
        and a.last_name = c.last_name
where (
    --Edit-distance=1 on DOB
    --  TAD_UserSpace.DataInsights.Edit_Distance_Within(cast(a.dob as varchar(10)),cast(b.dob as varchar(10)),1)<>999

    fuzzy.lev(a.date_of_birth, c.date_of_birth, 1) <> 999

    --Or Ed-dist=<2 on year of DOB, with month and day the same
    --    or (TAD_UserSpace.DataInsights.Edit_Distance_Within(cast(year(a.dob) as varchar(10)),cast(year(b.dob) as varchar(10)),2)<>999
    --		and  month(a.dob)=month(b.dob) and day(a.dob)=day(b.dob))
    or (
            fuzzy.lev(c.date_of_birth_year, c.date_of_birth_year, 2) <> 999
        and
            a.date_of_birth_month = c.date_of_birth_month
        and
            a.date_of_birth_day = c.date_of_birth_day
    )

    --Or Ed-dist=<2 on month of DOB, with year and day the same
    --    or (TAD_UserSpace.DataInsights.Edit_Distance_Within(cast(month(a.dob) as varchar(10)),cast(month(b.dob) as varchar(10)),2)<>999
    --      and  year(a.dob)=year(b.dob) and day(a.dob)=day(b.dob))
    or (
            fuzzy.lev(c.date_of_birth_month, c.date_of_birth_month, 2) <> 999
        and
            a.date_of_birth_year = c.date_of_birth_year
        and
            a.date_of_birth_day = c.date_of_birth_day
    )


    --Or Ed-dist=<2 on day of DOB, with month and year the same
    --    or (TAD_UserSpace.DataInsights.Edit_Distance_Within(cast(day(a.dob) as varchar(10)),cast(day(b.dob) as varchar(10)),2)<>999
    --        and  month(a.dob)=month(b.dob) and year(a.dob)=year(b.dob))
    or (
            fuzzy.lev(c.date_of_birth_day, c.date_of_birth_day, 2) <> 999
        and
            a.date_of_birth_year = c.date_of_birth_year
        and
            a.date_of_birth_month = c.date_of_birth_month
    )

    --Or year is the same, but month and day are swapped
    --   or (year(a.dob)=year(b.dob) and month(a.dob)=day(b.dob) and day(a.dob)=month(b.dob))
    or (
            a.date_of_birth_year = c.date_of_birth_year
        and
            a.date_of_birth_month = c.date_of_birth_day
        and
            a.date_of_birth_day = c.date_of_birth_month
    )
);
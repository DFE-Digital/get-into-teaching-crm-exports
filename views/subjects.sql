alter view git.subjects as (
    -- retreive all contact ids along with the preferred subjects
    select
        -- contact id, unique contact identifier
        c.id as contact_id,

        -- the names of the two subjects chosen when signing up
        -- to various services.
        -- * subject 1 is required
        -- * in School Experience - subject 2 is optional
        -- * in Get Into Teaching - subject 2 is not asked for
        tsl1.dfe_name as preferred_teaching_subject_1,
        tsl2.dfe_name as preferred_teaching_subject_2

    from
        crm_contact c
    left outer join
        crm_dfe_teachingsubjectlist tsl1
            on c.dfe_preferredteachingsubject01 = tsl1.id
    left outer join
        crm_dfe_teachingsubjectlist tsl2
            on c.dfe_preferredteachingsubject02 = tsl2.id

    where
        c.createdon >= '2019-01-01'
);

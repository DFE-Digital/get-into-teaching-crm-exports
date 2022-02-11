alter view git.school_experience_requests as (
    select
        -- contact id, matches contact_id in event_registrations, tta views etc (guid)
        se.dfe_contactid as contact_id,

        -- the URN (unique reference number) of the school the request was made against
        se.dfe_urn as urn,
        
        -- the first choice subject made by the candidate when making the request
        s.dfe_name as [subject],

        -- the request placement date
        cast(se.dfe_dateofschoolexperience as date) as placement_date,

        -- the length of the placement in days
        se.dfe_placementduration as duration

    from
        crm_dfe_candidateschoolexperience se

    left outer join 
        crm_dfe_teachingsubjectlist s
            on s.id = se.dfe_teachingsubject  

    where
        -- rows without a URN are legacy experiences imported
        -- from the prior system
        dfe_urn is not null
);
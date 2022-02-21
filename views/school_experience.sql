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
        se.dfe_placementduration as duration,

        -- event status, the state change on the request record
        -- made by School Experience.
        --
        -- Values are:
        --
        -- Requested                   1
        -- Inactive                    2
        -- Confirmed                   222_750_000
        -- Withdrawn                   222_750_001
        -- Rejected                    222_750_002
        -- Cancelled by school         222_750_003
        -- Cancelled by candidate      222_750_004
        -- Completed                   222_750_005
        smd.localizedlabel as status

    from
        crm_dfe_candidateschoolexperience se

    left outer join 
        crm_dfe_teachingsubjectlist s
            on s.id = se.dfe_teachingsubject  
    
    left outer join
        crm_StatusMetaData smd
            on se.statuscode = smd.Status
            and smd.EntityName = 'dfe_candidateschoolexperience'

    where
        -- rows without a URN are legacy experiences imported
        -- from the prior system
        dfe_urn is not null
);
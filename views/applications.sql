alter view git.applications as (
    -- show all contacts who have actually made an application so we can build
    -- a fuller picture of their journey
    select
        -- application id, primary key
        af.id as id,
        
        -- contact id, matches contact_id in event_registrations, tta views etc (guid)
        af.dfe_contact as contact_id,

        -- when was the application made, both datetime and time
        convert(smalldatetime, af.createdon) as applied_at,
        convert(date, af.createdon) as applied_on,

        -- application phase, there appear to be two values:
        -- * Apply 1 (the first application)
        -- * Apply 2 (any subsequent application)
        phase.localizedlabel as phase,

        -- application status, these are states from Apply's state machine
        --
        -- https://github.com/dfe-digital/apply-for-teacher-training#application-states
        status.localizedlabel as status

from
    crm_dfe_applyapplicationform af

left outer join
    -- dynamics central EAV lookup (application phase)
    crm_OptionSetMetadata phase
        on af.dfe_applyphase = phase.[Option]
        and phase.optionsetname = 'dfe_candidateapplyphase'
        and phase.EntityName = 'contact'

left outer join
    -- dynamics central EAV lookup (application status)
    crm_OptionSetMetadata status
        on af.dfe_applystatus = status.[Option]
        and status.optionsetname = 'dfe_candidateapplystatus'
        and status.EntityName = 'contact' 
);
-- create view as git.teacher_training_adviser _signups as (
select
    top 100
    c.id as contact_id,
    c.dfe_gitisttaservicestartdate as signed_up_at,
    tta_subscription_channel_lookup.LocalizedLabel as subscription_channel,

    case c.dfe_gitisttaservicedonotemail
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as opted_out_of_all_emails,

    case c.dfe_gitismailinglistservicedonotbulkemail
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as opted_out_of_bulk_emails,

    case c.dfe_gitisttaservicedonotpostalmail
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as opted_out_of_post


from
    crm_contact c

left outer join
    crm_OptionSetMetadata tta_subscription_channel_lookup
        on c.dfe_gitisttaservicesubscriptionchannel = tta_subscription_channel_lookup.[Option]
        and tta_subscription_channel_lookup.optionsetname = 'dfe_gitisttaservicesubscriptionchannel'

where
    c.dfe_gitisttaservicestartdate is not null;
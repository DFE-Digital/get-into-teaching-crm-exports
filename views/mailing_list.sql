-- create view git.mailing_list_subscriptions as (
select
    c.id as contact_id,
    c.dfe_gitismailinglistservicestartdate as subscribed_at,
    ml_subscription_channel_lookup.[localizedlabel] as subscription_channel,
    
    case c.dfe_gitismailinglistserviceissubscriber
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as still_subscribed,
    

    case c.dfe_gitismailinglistservicedonotemail
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as opted_out_of_all_emails,

    case c.dfe_gitismailinglistservicedonotbulkemail
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as opted_out_of_bulk_emails,


    case c.dfe_gitismailinglistservicedonotpostalmail
        when 0 then 'no'
        when 1 then 'yes'
        else null 
    end as opted_out_of_post

from
    crm_contact c

left outer join
    crm_OptionSetMetadata ml_subscription_channel_lookup
        on c.dfe_gitismlservicesubscriptionchannel = ml_subscription_channel_lookup.[Option]
        and ml_subscription_channel_lookup.optionsetname = 'dfe_gitismlservicesubscriptionchannel'

where
    c.dfe_gitismailinglistservicestartdate is not null;
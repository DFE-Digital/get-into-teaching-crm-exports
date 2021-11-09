alter view git.mailing_list_subscriptions as (
	-- shows all contacts, their subscription channel and indicators
	-- of whether they're still subscribed to emails, post, bulk mail etc
	select
		-- contact id, matches contact_id in event_registrations, tta views etc (guid)
		c.id as contact_id,

		-- the date and time a subscription was made (eg. 2021-08-01 16:48)
		convert(smalldatetime, c.dfe_gitismailinglistservicestartdate) as subscribed_at,

		-- subscription channel pulled from the common lookup table
		-- channels include things like 'on campus service', 'social media',
		-- 'grad fairs', 'pop-up events' etc
		sc.[localizedlabel] as subscription_channel,

		-- is the contact still subscribed?
		case c.dfe_gitismailinglistserviceissubscriber
			when 0 then 'no'
			when 1 then 'yes'
			else null
		end as still_subscribed,

		-- TODO: clarify the relationship between opted_out_of_all_emails
		--       and opted_out_of_bulk_emails. Does the former include the
		--       latter? (i.e. is our 'all' in the column name accurate?)

		-- has the contact opted out of emails?
		case c.dfe_gitismailinglistservicedonotemail
			when 0 then 'no'
			when 1 then 'yes'
			else null
		end as opted_out_of_all_emails,

		-- has the contact opted out bulk emails?
		case c.dfe_gitismailinglistservicedonotbulkemail
			when 0 then 'no'
			when 1 then 'yes'
			else null
		end as opted_out_of_bulk_emails,

		-- has the contact opted out post?
		case c.dfe_gitismailinglistservicedonotpostalmail
			when 0 then 'no'
			when 1 then 'yes'
			else null
		end as opted_out_of_post

	from
		-- dynamics primary list of contacts
		crm_contact c

	left outer join
		-- dynamics central EAV lookup
		crm_OptionSetMetadata sc
			on c.dfe_gitismlservicesubscriptionchannel = sc.[Option]
			and sc.optionsetname = 'dfe_gitismlservicesubscriptionchannel'
			and sc.EntityName = 'contact'

	where
		-- only target users who've actually signed up to the
		-- mailing list
		c.dfe_gitismailinglistservicestartdate is not null
);

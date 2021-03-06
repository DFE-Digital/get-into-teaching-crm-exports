alter view git.teacher_training_adviser_signups as (
	-- shows all contacts who have signed up for a TTA
	select
		-- contact id, matches contact_id in event_registrations, mailing list views etc (guid)
		c.id as contact_id,

		-- the date and time the signup was completed
		convert(smalldatetime, c.dfe_gitisttaservicestartdate) as signed_up_at,

		-- the date on which the signup was completed
		convert(date, c.dfe_gitisttaservicestartdate) as signed_up_on,

		-- subscription channel pulled from the common lookup table
		-- channels include things like 'on campus service', 'social media',
		-- 'grad fairs', 'pop-up events' etc
		sc.LocalizedLabel as subscription_channel,

		-- TODO: clarify the relationship between opted_out_of_all_emails
		--       and opted_out_of_bulk_emails. Does the former include the
		--       latter? (i.e. is our 'all' in the column name accurate?)

		-- has the contact opted out of all TTA emails?
		c.dfe_gitisttaservicedonotemail as opted_out_of_all_emails,

		-- has the contact opted out of all TTA bulk emails?
		c.dfe_gitismailinglistservicedonotbulkemail as opted_out_of_bulk_emails,

		-- has the contact opted out post?
		c.dfe_gitisttaservicedonotpostalmail as opted_out_of_post

	from
		-- dynamics primary list of contacts
		crm_contact c

	left outer join
		-- dynamics central EAV lookup
		crm_OptionSetMetadata sc
			on c.dfe_gitisttaservicesubscriptionchannel = sc.[Option]
			and sc.optionsetname = 'dfe_gitisttaservicesubscriptionchannel'
			and sc.EntityName = 'contact'

	where
		-- only target users who've actually signed up for a TTA
		c.dfe_gitisttaservicestartdate is not null
);

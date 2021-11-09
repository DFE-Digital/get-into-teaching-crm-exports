alter view git.event_registrations as (
	-- shows a full list of event registrations. A registration
	-- is a record that joins an event with a contact and potentially
	-- a checkin.
	select
		-- the event registration id (guid)
		er.id as id,

		-- event id, matches git.events.id (guid)
		er.msevtmgt_eventid as event_id,

		-- contact id, matches contact_id in mailing list and tta views (guid)
		er.msevtmgt_contactid as contact_id,

		-- the attendance status of the registration
		-- when 'yes' the registrant attended
		-- when unknown:
		--      * the event hasn't happened yet
		--      * the event happened in the last week so there's still
		--        an opportunity for the registrant to confirm attendance
		-- when 'no' the registrant did not attend
		case
		when ci.id is not null
			then 'yes'
		when e.msevtmgt_eventenddate > dateadd(week, -1, getdate())
			then 'unknown'
		else 'no'
		end as attended,

		-- the timestamp the registration was made (e.g., 2021-05-30T10:12:34)
		convert(smalldatetime, er.createdon) as registered_at,

		-- the date the registration was made (e.g., 2021-05-30)
		convert(date, er.createdon) as registered_on,

		-- the date the attendance was confirmed (e.g., 2021-06-12)
		convert(smalldatetime, ci.createdon) as attendance_confirmed_at,

		-- creation channel pulled from common lookup table via 'dfe_ChannelCreation'
		cc.LocalizedLabel as creation_channel

	from
		-- raw event registrations from dynamics
		crm_msevtmgt_eventregistration er

	left outer join
		-- raw checkins list from dynamics. may or may not exist so left outer
		-- join to include both attended and not-attended registrations
		crm_msevtmgt_checkin ci
			on er.Id = ci.msevtmgt_registrationid

	inner join
		-- raw events listing from Dynamics
		crm_msevtmgt_event e
			on er.msevtmgt_eventid = e.Id

	inner join
		-- dynamics central EAV lookup
		crm_OptionSetMetadata cc
			on er.dfe_ChannelCreation = cc.[Option]
			and cc.OptionSetName = 'dfe_channelcreation'
			and cc.EntityName = 'msevtmgt_eventregistration'

);

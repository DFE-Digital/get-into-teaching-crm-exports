alter view git.events as (
	-- shows a full list of events containing date, building and status
	select
		-- the event id (guid)
		e.id as id,

		-- venue name (e.g., University of Cumbria) retrieved from
		-- the buildings table
		b.msevtmgt_name as venue,

		-- event start and finish times (e.g., 2021-05-25 17:30:00)
		-- some are null and the date conversion fails so wrap
		-- them in a case statment to check
		case
			when e.msevtmgt_eventstartdate is null
				then null
			else
				convert(smalldatetime, e.msevtmgt_eventstartdate)	
		end as starts_at,

		case
			when e.msevtmgt_eventenddate is null
				then null
			else
				convert(smalldatetime, e.msevtmgt_eventenddate)	
		end as finishes_at,

		-- the date on which the event starts. we assume there are
		-- no multi-day events (none present at time of writing)
		-- (e.g., 2021-05-25)
		convert(date, e.msevtmgt_eventstartdate) as date,

		-- the event's name. appears to follow the format of being
		-- the venue followed by a more descriptive name
		-- (e.g., "Institute of Physics - get into teaching physics online event")
		e.msevtmgt_name as name,

		-- event status, pulled from the common lookup table via 'dfe_EventStatus'
		-- current statuses are 'Closed', 'In Draft', 'Open'
		-- and 'Pending Review - submitted by 3rd party'
		es.LocalizedLabel as status,

		-- the slug used for individual event pages in the website, they all follow
		-- a standard format of a six digit number followed by manually-entered string
		-- with words separated by dashes
		-- (e.g., 210524-star-institute)
		e.dfe_websiteeventpartialurl as partial_url,

		-- the event type name
		-- (e.g., 'Train to Teach event', 'School or university event')
		et.[LocalizedLabel] as event_type,

		-- is the event online only?
		e.dfe_isonlineevent as [online],
		
		-- virtual events are online but have a building because they're
		-- relevant to people searching by area - for example a provider
		-- in Newcastle wants to attract local people to their event, even
		-- if they don't attend in person
		case
			when (e.dfe_isonlineevent = 1 and b.msevtmgt_postalcode is not null) then 1
			else 0
		end as virtual

	from
		-- raw events listing from Dynamics
		crm_msevtmgt_event e

	left outer join
		-- raw buildings listing from Dynamics
		crm_msevtmgt_building b
			on e.msevtmgt_building = b.Id

	inner join
		-- dynamics central EAV lookup (status)
		crm_OptionSetMetadata es
			on e.dfe_EventStatus = es.[Option]
			and es.OptionSetName = 'dfe_eventstatus'
			and es.EntityName = 'msevtmgt_event'

	inner join
		-- dynamics global EAV lookup (type)
		crm_GlobalOptionSetMetadata et
			on e.dfe_event_type = et.[Option]
			and et.OptionSetName = 'dfe_event_type'
);
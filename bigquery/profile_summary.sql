with

  transactions as (
    select contact_id, min(date) as min_date, max(date) as max_date
    from `get-into-teaching.transactions.transaction_summary`
    group by contact_id
  ),

  applications as (
    select
      contact_id,
      min(applied_at) as min_applied_at,
      max(applied_at) as max_applied_at
    from `get-into-teaching.transactions.applications`
    group by contact_id
  ),

  successful_applications as (
    select
      contact_id,
      min(applied_at) as min_applied_at,
      max(applied_at) as max_applied_at,
    from `get-into-teaching.transactions.applications`
    where success
    group by contact_id
  ),

  event_registrations as (
    select
      contact_id,
      min(registered_at) as min_registered_at,
      max(registered_at) as max_registered_at,
      max(attended) as attended
    from `get-into-teaching.transactions.event_registrations`
    group by contact_id
  ),

  attended_event_registrations as (
    select
      contact_id,
      min(registered_at) as min_registered_at,
      max(registered_at) as max_registered_at,
      max(attended) as attended
    from `get-into-teaching.transactions.event_registrations`
    where attended = 'yes'
    group by contact_id
  )

select
  p.*,

  -- FIXME move this to UDF
  case
      when degree_status in ('Final year', 'Graduate or postgraduate')
      then 'Eligible'
      when degree_status in ('First year', 'Second year')
      then 'Pipeline'
      else 'Ineligible'
  end as eligibilty,

  -- FIXME move this to UDF
  case
    when p.created_on between '2014-09-01' and '2015-08-31' then '2014-2015'
    when p.created_on between '2015-09-01' and '2016-08-31' then '2015-2016'
    when p.created_on between '2016-09-01' and '2017-08-31' then '2016-2017'
    when p.created_on between '2017-09-01' and '2018-08-31' then '2017-2018'
    when p.created_on between '2018-09-01' and '2019-08-31' then '2018-2019'
    when p.created_on between '2019-09-01' and '2020-08-31' then '2019-2020'
    when p.created_on between '2020-09-01' and '2021-08-31' then '2020-2021'
    when p.created_on between '2021-09-01' and '2022-08-31' then '2021-2022'
    when p.created_on between '2022-09-01' and '2023-08-31' then '2022-2023'
    when p.created_on between '2023-09-01' and '2024-08-31' then '2023-2024'
    else 'Legacy'
  end as marketing_cycle,

  t.min_date as earliest_transaction_at,
  t.max_date as latest_transaction_at,

  a.min_applied_at as earliest_applied_at,
  a.max_applied_at as latest_applied_at,

  sa.min_applied_at as earliest_successful_applied_at,
  sa.max_applied_at as latest_successful_applied_at,

  er.min_registered_at as earliest_event_registered_at,
  er.max_registered_at as latest_event_registered_at,

  aer.min_registered_at as earliest_attended__event_registered_at,
  aer.max_registered_at as latest_attended_event_registered_at,

  case when ml.contact_id is null then false else true end as subscribed_to_mailing_list,
  case when tta.contact_id is null then false else true end as signed_up_for_tta,
  case when er.contact_id is null then false else true end as registered_for_an_event,
  case when aer.contact_id is null then false else true end as attended_an_event,
  case when a.contact_id is null then false else true end as applied,
  case when sa.contact_id is null then false else true end as successfully_applied,

from
  `get-into-teaching.transactions.profile` p

left outer join
  `get-into-teaching.transactions.mailing_list_subscriptions` ml
    on p.id = ml.contact_id

left outer join
  `get-into-teaching.transactions.teacher_training_adviser_signups` tta
    on p.id = tta.contact_id

left outer join
  transactions t
    on p.id = t.contact_id

left outer join
  applications a
    on p.id = a.contact_id

left outer join
  successful_applications sa
    on p.id = sa.contact_id

left outer join
  event_registrations er
    on p.id = er.contact_id

left outer join
  attended_event_registrations aer
    on p.id = aer.contact_id
;

with git_transactions as (
    select
      contact_id,
      'Mailing list subscriptions' as transaction,
      subscription_channel as channel,
      subscribed_at as transaction_date_and_time,
      subscribed_on as transaction_date,

      -- ignore these, only apply to events but we need
      -- to match for the union
      null as attended,
      null as event_type,
      null as event_date
    from
      `get-into-teaching.transactions.mailing_list_subscriptions`

  union all
    select
      contact_id,
      'Event registrations' as transaction,
      creation_channel as channel,
      registered_at as transaction_date_and_time,
      registered_on as transaction_date,

      attended as attended,
      e.event_type,
      e.date as event_date
    from
      `get-into-teaching.transactions.event_registrations` er
    inner join
      `get-into-teaching.transactions.events` e 
        on er.event_id = e.id

  union all

  select
    contact_id,
    'Teacher training adviser signup' as transaction,
    subscription_channel as channel,
    signed_up_at as transaction_date_and_time,
    signed_up_on as transaction_date,

      -- ignore these, only apply to events but we need
      -- to match for the union
    null as attended,
    null as event_type,
    null as event_date
  from
    `get-into-teaching.transactions.teacher_training_adviser_signups`
),
first_transactions as (
  select
    gt.transaction,
    gt.contact_id,
    min(gt.transaction_date_and_time) as first_transaction_date_and_time
  from
    git_transactions gt
  group by
    gt.transaction,
    gt.contact_id
),
candidates_who_applied as (
  select distinct contact_id from `get-into-teaching.transactions.applications`
),
successful_applicants as (
  select
    distinct a.contact_id
  from
    `get-into-teaching.transactions.applications` a
  where
    a.status in ('Recruited', 'Pending conditions', 'Offer deferred')
)
select
  t.*,
  cast(t.transaction_date_and_time as date) date,
  case
    when a.contact_id is not null then true
    else false
  end as applied,
  case
    when sa.contact_id is not null then true
    else false
  end as has_made_successful_application,
  pe.eligibilty,
  p.chosen_subject,
  p.international,
  p.has_adviser,
  p.journey_stage,
  p.returner,
  p.creation_channel,
  p.created_via_git_bat_sync,
  p.degree_status,
  p.country,
  p.duplicate,
  p.recruitment_stage,
  p.created_at as profile_created_at,
  p.created_on as profile_created_on,

  case
    when t.transaction_date between '2019-09-01' and '2020-08-31' then '2019-2020'
    when t.transaction_date between '2020-09-01' and '2021-08-31' then '2020-2021'
    when t.transaction_date between '2021-09-01' and '2022-08-31' then '2021-2022'
    when t.transaction_date between '2022-09-01' and '2023-08-31' then '2022-2023'
    when t.transaction_date between '2023-09-01' and '2024-08-31' then '2023-2024'
  end as marketing_cycle,

  case
    when t.transaction_date between '2019-10-12' and '2020-10-11' then '2019-2020'
    when t.transaction_date between '2020-10-12' and '2021-10-11' then '2020-2021'
    when t.transaction_date between '2021-10-12' and '2022-10-11' then '2021-2022'
    when t.transaction_date between '2022-10-12' and '2023-10-11' then '2022-2023'
    when t.transaction_date between '2023-10-12' and '2024-10-11' then '2023-2024'
  end as application_cycle,

  -- note some people sign up for the mailing list while registering for an
  -- event so there's a possibility they have two 'first transactions'
  case
    when ft.contact_id is not null then true
    else false
  end as first_transaction

from
  git_transactions t
left outer join
  candidates_who_applied a
    on t.contact_id = a.contact_id
left outer join
  `get-into-teaching.transactions.profile_eligibility` pe
    on t.contact_id = pe.contact_id
left outer join
  `get-into-teaching.transactions.profile` p
    on t.contact_id = p.id  
left outer join
  successful_applicants sa
    on t.contact_id = sa.contact_id
left outer join
  first_transactions ft
    on t.contact_id = ft.contact_id
    and t.transaction_date_and_time = ft.first_transaction_date_and_time
    and t.transaction = ft.transaction
;

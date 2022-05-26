with
  people_who_have_completed_a_transaction as (
    select distinct(contact_id) from `get-into-teaching.transactions.transaction_summary`
  ),
  people_who_subscribed_to_the_mailing_list as (
    select distinct(contact_id) from `get-into-teaching.transactions.mailing_list_subscriptions`
  ),
  people_who_signed_up_for_a_tta as (
    select distinct(contact_id) from `get-into-teaching.transactions.teacher_training_adviser_signups`
  ),
  people_who_registered_for_an_event as (
    select distinct(contact_id) from `get-into-teaching.transactions.event_registrations`
  ),
  people_who_attended_an_event as (
    select distinct(contact_id) from `get-into-teaching.transactions.event_registrations` where attended = 'yes'
  )
select
    a.id as application_id,
    a.applied_at,
    a.applied_on,
    a.phase as application_phase,
    a.status as application_status,
    a.recruitment_year,
    a.application_complete,

    p.id as contact_id,
    p.journey_stage,
    p.degree_status,
    p.chosen_subject,
    p.fallback_subject,
    p.has_postcode,
    p.has_date_of_birth,
    p.adviser_assigned_at,
    p.adviser_assigned_on,
    p.has_adviser,
    p.international,
    p.returner,
    p.country,
    p.creation_channel,
    p.created_via_git_bat_sync,
    p.created_on as profile_created_on,

    case
      when p.created_on between '2014-09-01' and '2015-08-31' then '2014-2015'
      when p.created_on between '2015-09-01' and '2016-08-31' then '2015-2016'
      when p.created_on between '2016-09-01' and '2017-08-31' then '2016-2017'
      when p.created_on between '2017-09-01' and '2018-08-31' then '2017-2018'
      when p.created_on between '2018-09-01' and '2019-08-31' then '2018-2019'
      when p.created_on between '2019-09-01' and '2020-08-31' then '2019-2020'
      when p.created_on between '2020-09-01' and '2021-08-31' then '2020-2021'
      when p.created_on between '2021-09-01' and '2022-08-31' then '2021-2022'
      else 'Legacy'
    end as marketing_cycle,

    case
      when status in ('Recruited', 'Pending conditions', 'Offer deferred') then true 
      else false
    end as success,

    case
      when t.contact_id is null then false
      else true
    end as has_completed_transaction,

    case
      when ml.contact_id is null then false
      else true
    end as has_subscribed_to_the_mailing_list,

    case
      when tta.contact_id is null then false
      else true
    end as has_signed_up_for_a_tta,

    case
      when er.contact_id is null then false
      else true
    end as has_registered_for_an_event,

    case
      when ea.contact_id is null then false
      else true
    end as has_attended_an_event,

    case
      when p.chosen_subject = 'primary' then 'primary'
      else 'secondary'
  end as education_phase,

from
  `get-into-teaching.transactions.applications` a
left outer join
  `get-into-teaching.transactions.profile` p
    on a.contact_id = p.id
left outer join people_who_have_completed_a_transaction t
    on a.contact_id = t.contact_id
left outer join people_who_subscribed_to_the_mailing_list ml
    on a.contact_id = ml.contact_id
left outer join people_who_signed_up_for_a_tta tta
    on a.contact_id = tta.contact_id
left outer join people_who_registered_for_an_event er
    on a.contact_id = er.contact_id
left outer join people_who_attended_an_event ea
    on a.contact_id = ea.contact_id
;

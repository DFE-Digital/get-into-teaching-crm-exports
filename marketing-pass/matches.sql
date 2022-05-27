drop table if exists fuzzy.matches;

create table fuzzy.matches
(
    -- apply fields
    apply_email_address varchar,
    apply_first_name varchar,
    apply_last_name varchar,
    apply_date_of_birth varchar,
    apply_postcode varchar,
    appy_phone varchar,

    -- crm fields
    crm_email_address varchar,
    crm_first_name varchar,
    crm_last_name varchar,
    crm_date_of_birth varchar,
    crm_postcode varchar,
    crm_phone varchar,

    -- extra info and match type
    apply_id varchar,
    crm_id varchar,
    match_type int
)
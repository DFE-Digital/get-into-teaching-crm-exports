drop table if exists fuzzy.matches;

create table fuzzy.matches
(
    -- apply fields
    apply_email_address varchar(300),
    apply_first_name varchar(300),
    apply_last_name varchar(300),
    apply_date_of_birth varchar(300),
    apply_postcode varchar(300),
    appy_phone varchar(300),

    -- crm fields
    crm_email_address varchar(300),
    crm_first_name varchar(300),
    crm_last_name varchar(300),
    crm_date_of_birth varchar(300),
    crm_postcode varchar(300),
    crm_phone varchar(300),

    -- extra info and match type
    apply_id varchar(300),
    crm_id varchar(300),
    match_type int
)
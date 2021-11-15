alter view git.school_experience_events as
    -- shows each 'event' that happens in the lifecycle of a school
    -- experience request
    --
    -- we need to do some cleaning up before we actually select any data
    -- so the view definition's split into three bits:
    --
    --
    -- splitting the log:
    --
    -- The school experience application writes data to a single varchar(max)
    -- column (dfe_notesforclassroomexperience), probably Dynamics-related
    -- (GITIS was still pretty new when SE was integrated)
    --
    -- The format is a header line, followed by a blank line, then rows
    -- of data:
    --
    -- RECORDED   ACTION                 EXP DATE   URN    NAME
    --
    -- 01/01/2021 REQUEST                01/02/2021 111111 Springfield Elementary School
    -- 02/01/2021 ACCEPTED               01/02/2021 111111 Springfield Elementary School
    --
    -- When there's no data the string 'RTBF' is present; not sure what this means
    -- Some events have some lines of raw text that follow it, they are notes about
    -- the event and we ignore them here.
    with split_log as (
        select
            id,
            value as line

        from
            crm_contact
            -- use cross apply with string_split to yield a row in the resultset PER
            -- row in the unstructured data - split on newline
            cross apply string_split(
                -- make things easier by replacing the \r\n with just \n
                replace(
                    dfe_notesforclassroomexperience,
                    char(13)+char(10),
                    char(10)
                ), char(10)
            )

        where
            dfe_notesforclassroomexperience is not null  -- only target SE-related rows
            and value <> 'RTBF'                          -- no idea what RTBF stands for but looks like 'no data'!
            and value <> 'none'                          -- no data (why are these here?)
            and value not like 'RECORDED%'               -- not the header row
            and len(trim(value)) > 1                     -- not the empty row beneath the header

            -- make sure it starts with a date in format NN/NN/NNNN; unfortunately there's no
            -- proper regexp support in SQL server so just pull out bits and inspect them
            -- ¯\_(ツ)_/¯
            and (substring(value, 1, 2)  like '[0-9][0-9]')
            and (substring(value, 4, 2)  like '[0-9][0-9]')
            and (substring(value, 7, 4)  like '[0-9][0-9][0-9][0-9]')

    ),
    -- Now we have two columns; the candidate uuid and the single record lines from
    -- dfe_notesforclassroomexperience. The next job is to split the line up into
    -- its constituent parts.
    --
    -- This is complicated by the fact the lines aren't all the same. I suspect there
    -- was a 'schema' change at some point and values got shifted right a bit, some time
    -- in early-mid 2020.
    --
    -- We can deal with it using a case statement and checking where the delimiting
    -- space lies. Ugly and not guaranteed to be correct, but looks alright at a glance.
    --
    -- The format used in Ruby to create the log lines:
    --
    -- "%10<recorded>s %-22<action>s %10<date>s %-6<urn>s %.25<name>s"
    --
    -- note, the `-` after the percent symbol means left pad
    parsed_log as (
        select
            -- contact_id, just passing it through
            id,

            -- recorded, date in format 01/01/1990
            substring(line, 1, 10) as recorded,

            -- the event type - values are:
            --  CANCELLED BY SCHOOL   
            --  REQUEST               
            --  CANCELLED BY CANDIDATE
            --  DID NOT ATTEND        
            --  ACCEPTED              
            --  ATTENDED              
            substring(line, 12, 22) as action,

            -- the date the experience is requested for
            -- sometimes it's missing which shifts the next
            -- value (urn) one to the left, so we check that
            -- the first character is present and if it's not
            -- just mark it as null, otherwise pull out 10
            -- chars for the date format 01/01/1990
            case
                when substring(line, 35, 1) = ' '
                    then null
                else
                    substring(line, 35, 10) 
            end as exp_date,

            -- urn, GIAS's unique identifier for a school.
            -- depending on whether the exp_date above is present
            -- it either starts at char 46 or 44
            case
                when substring(line, 45, 1) = ' '
                    then substring(line, 46, 6)
                else
                    substring(line, 44, 6)
            end as urn

            -- debug line, useful for counting spaces!
            -- replace(line, ' ', '_'  )as whole_thing
        from
            split_log
    )

    -- the actual view contents converted to proper types
    select
        -- contact id, unique contact identifier
        id as contact_id,

        -- the date on which the event occurred
        parse(recorded as date using 'en-gb') as recorded_on,

        -- the type of event (see list above)
        action as event_type,

        -- the date the experience was requested for - TBC
        parse(exp_date as date using 'en-gb') as experience_requested_on,

        -- the GIAS school ID the request was made to 
        cast(urn as integer) as urn
    from
        parsed_log

;

# Get Into Teaching Data Exports

This is a summary of the views we intend on exporting from the GITIS CRM.

The `PII risk` column is an estimation of how risky the data is from the point of view of identifying a candidate, from 0 (no risk) to 3 (identifiable).

We aim to maintain this overall risk at zero.

## `git.mailing_list_subscriptions`

| Origin table            | Origin column                                | Reporting name             | PII risk  | Description        | Type             |
| ------------            | -------------                                | --------------             | --------: | ------             | ----             |
| `crm_contact`           | `Id`                                         | `id`                       | 0         | Contact identifier | `uuid`           |
| `crm_contact`           | `dfe_gitismailinglistservicestartdate`       | `subscribed_at`            | 0         |                    | `smalldatetime`  |
| `crm_OptionSetMetadata` | `Option`                                     | `subscription_channel`     | 0         |                    | `varchar`        |
| `crm_contact`           | `dfe_gitismailinglistserviceissubscriber`    | `still_subscribed`         | 0         |                    | `varchar` yes/no |
| `crm_contact`           | `dfe_gitismailinglistservicedonotemail`      | `opted_out_of_all_emails`  | 0         |                    | `varchar` yes/no |
| `crm_contact`           | `dfe_gitismailinglistservicedonotbulkemail`  | `opted_out_of_bulk_emails` | 0         |                    | `varchar` yes/no |
| `crm_contact`           | `dfe_gitismailinglistservicedonotpostalmail` | `opted_out_of_post`        | 0         |                    | `varchar` yes/no |

## `git.teacher_training_adviser_signups`

| Origin table            | Origin column                               | Reporting name             | PII risk  | Description        | Type             |
| ------------            | -------------                               | --------------             | --------: | ------             | ----             |
| `crm_contact`           | `Id`                                        | `id`                       | 0         | Contact identifier | `uuid`           |
| `crm_contact`           | `dfe_gitisttaservicestartdate`              | `signed_up_at`             | 0         |                    | `smalldatetime`  |
| `crm_OptionSetMetadata` | `Option`                                    | `subscribed_at`            | 0         |                    | `smalldatetime`  |
| `crm_contact`           | `dfe_gitisttaservicedonotemail`             | `opted_out_of_all_emails`  | 0         |                    | `varchar` yes/no |
| `crm_contact`           | `dfe_gitismailinglistservicedonotbulkemail` | `opted_out_of_bulk_emails` | 0         |                    | `varchar` yes/no |
| `crm_contact`           | `dfe_gitisttaservicedonotpostalmail`        | `opted_out_of_post`        | 0         |                    | `varchar` yes/no |


## `git.events`

| Origin table            | Origin column                | Reporting name | PII risk  | Description      | Type            |
| ------------            | -------------                | -------------- | --------: | ------           | ----            |
| `crm_msevtmgt_event`    | `Id`                         | `id`           | 0         | Event identifier | `uuid`          |
| `msevtmgt_building`     | `msevtmgt_name`              | `venue`        | 0         |                  | `varchar`       |
| `crm_msevtmgt_event`    | `msevtmgt_eventstartdate`    | `starts_at`    | 0         |                  | `smalldatetime` |
| `crm_msevtmgt_event`    | `msevtmgt_eventenddate`      | `finishes_at`  | 0         |                  | `smalldatetime` |
| `crm_msevtmgt_event`    | `msevtmgt_eventstartdate`    | `date`         | 0         |                  | `date`          |
| `crm_OptionSetMetadata` | `Option`                     | `status`       | 0         |                  | `varchar`       |
| `crm_msevtmgt_event`    | `dfe_websiteeventpartialurl` | `partial_url`  | 0         |                  | `varchar`       |

## `git.event_registrations`

| Origin table                     | Origin column        | Reporting name            | PII risk  | Description                   | Type                     |
| ------------                     | -------------        | --------------            | --------: | ------                        | ----                     |
| `crm_msevtmgt_eventregistration` | `Id`                 | `id`                      | 0         | Event registration identifier | `uuid`                   |
| `crm_msevtmgt_eventregistration` | `msevtmgt_eventid`   | `event_id`                | 0         | Event identifier              | `uuid`                   |
| `crm_msevtmgt_eventregistration` | `msevtmgt_contactid` | `contact_id`              | 0         | Contact identifier            | `uuid`                   |
| `crm_msevtmgt_checkin`           | `id`                 | `attended`                | 0         |                               | `varchar` yes/no/unknown |
| `crm_msevtmgt_eventregistration` | `createdon`          | `registered_at`           | 0         |                               | `smalldatetime`          |
| `crm_msevtmgt_checkin`           | `createdon`          | `attendance_confirmed_at` | 0         |                               | `smalldatetime`          |
| `crm_OptionSetMetadata`          | `Option`             | `creation_channel`        | 0         |                               | `varchar`                |
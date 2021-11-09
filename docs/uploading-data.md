# Uploading data to BigQuery

We're not going to go into too much depth here as this extends beyond our remit and we may need to work with the CRM team to implement something that's simple and robust.

## All-in-one solutions

1. [Kingswaysoft's BigQuery Source Component](https://www.kingswaysoft.com/products/ssis-productivity-pack/help-manual/google-services/google-bigquery-source)

## Using Google Cloud SDK

Google offers a [Cloud SDK](https://cloud.google.com/sdk) package that provides tools for interacting with Google Cloud products and services.

We can use the `gsutil` tool to upload files to Google Cloud Storage buckets. This approach allows us to upload entire files and is simpler than streaming events (the route Apply have taken). The current levels of GIT data don't necessitate streaming or require up-to-the-minute data, so it should be sufficient.

### Preparing everything

We need to install the SDK tools. I followed [these instructions](https://cloud.google.com/sdk/docs/install#rpm) and installed via `dnf` in the usual manner.

Now we can authenticate:

```
$ gcloud auth login

  Your current project is [None].  You can change this setting by running:
    $ gcloud config set project PROJECT_ID
```

Our Google Cloud Platform dashboard tells us our project ID is `275553675734`, so:

```
$ gcloud config set project 275553675734
  Updated property [core/project].
```

### Actually uploading files

These are the four files we're going to upload:

```
$ ls -l
.rw-r--r--@ 1.6M peter 22 Sep 14:50 event_registrations.csv
.rw-r--r--@ 200k peter 22 Sep 14:50 events.csv
.rw-r--r--@ 1.4M peter 22 Sep 14:50 mailing_list_signups.csv
.rw-r--r--@ 260k peter 22 Sep 14:50 teacher_training_adviser_signups.csv
```

It appears we need to use [`gsutil cp`](https://cloud.google.com/storage/docs/gsutil/commands/cp) to copy files.

Note, our bucket is called `git-proof-of-concept` and we're uploading the four files listed in the first command:

```
$ gsutil cp *.csv gs://git-proof-of-concept
Copying file://event_registrations.csv [Content-Type=text/csv]...
Copying file://events.csv [Content-Type=text/csv]...
Copying file://mailing_list_signups.csv [Content-Type=text/csv]...
Copying file://teacher_training_adviser_signups.csv [Content-Type=text/csv]...
- [4 files][  3.3 MiB/  3.3 MiB]
Operation completed over 4 objects/3.3 MiB.
```

That was easier than expected 🎉

This approach should be easily to automate too.

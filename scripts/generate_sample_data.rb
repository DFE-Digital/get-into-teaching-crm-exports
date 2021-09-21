# frozen_string_literal: true

require 'securerandom'
require 'time'
require 'csv'
require 'pry'

# Generate some data to use in our proof of concept BigQuery/Google Data Studio setup

DAYS_IN_YEAR         = 365
HOURS                = (9..16).to_a
MINUTES              = [0, 30].freeze
CONTACTS             = 20_000
EVENTS               = 1_300
EVENT_REGISTRATIONS  = 9_000
MAILING_LIST_SIGNUPS = 15_000
TTA_SIGNUPS          = 3_000

def datetime_in_past(year: 3)
  adjust = Kernel.rand(DAYS_IN_YEAR * year)

  DateTime.now - (adjust * Kernel.rand(-0.99..0.99))
end

def format_datetime(date)
  date.strftime("%Y-%m-%d %H:%M:00")
end

def format_date(date)
  date.strftime("%Y-%m-%d")
end

def event_times(date)
  start_time = [HOURS.sample, MINUTES.sample]
  finish_time = [(start_time[0] + Kernel.rand(2..4)), MINUTES.sample]

  [
    DateTime.new(date.year, date.month, date.day, start_time[0], start_time[1]),
    DateTime.new(date.year, date.month, date.day, finish_time[0], finish_time[1])
  ].map { |d| format_datetime(d) }
end

def write_csv(data, filename, headers:)
  CSV.open("/tmp/#{filename}", "w", headers: headers, write_headers: true, force_quotes: true) do |f|
    data.each { |row| f << row }
  end
end

def mimic_url(text)
  text.gsub(/\s/i, '-').downcase
end

contact_ids = CONTACTS.times.map { SecureRandom.uuid }

# Generate weighted from a hash in the format { "value" => weighting }. The value
# will be repeated by the size of the weighting so #sample will return favoured
# values more frequently
class WeightedSample
  attr_reader :values

  def initialize(weightings)
    @values = weightings.flat_map { |val, weight| Array.new(weight, val) }
  end

  def sample
    @values.sample
  end
end

# EVENTS
# ======

# A fake event as it would be listed on GIT
class Event
  attr_reader :id, :date, :times, :name, :status

  def initialize(number, status)
    @number = number

    @id = SecureRandom.uuid
    @date = datetime_in_past(year: 4)
    @times = event_times(date)
    @name = "Event #{number}"
    @status = status
  end

  def to_h
    {
      id: SecureRandom.uuid,
      venue: "#{name} venue",
      starts_at: times[0],
      finishes_at: times[1],
      date: format_date(date),
      name: name,
      status: status,
      partial_url: "/#{date.strftime('%y%m%d')}-#{mimic_url(name)}"
    }
  end
end

event_statuses = WeightedSample.new({ "Closed" => 3, "In Draft" => 1, "Open" => 12 })
events = EVENTS.times.map { |i| Event.new(i, event_statuses.sample) }

write_csv(events.map(&:to_h), "events.csv", headers: events.first.to_h.keys)

# EVENT REGISTRATIONS
# ===================

# A fake event registration - joins to events and contains a contact_id
class EventRegistration
  attr_reader :id, :event, :event_id, :contact_id, :attended,
              :registered_at, :attendance_confirmed_at, :creation_channel

  def initialize(event, contact_id, attended)
    @id = SecureRandom.uuid
    @event = event
    @event_id = event.id
    @contact_id = contact_id
    @attended = attended
  end

  def to_h
    {
      id: SecureRandom.uuid,
      event_id: event_id,
      contact_id: contact_id,
      attended: attended,
      registered_at: format_datetime(event.date - (5..70).to_a.sample),
      attendance_confirmed_at: format_datetime(event.date + (1..7).to_a.sample),
      creation_channel: "Website"
    }
  end
end

attended_statuses = WeightedSample.new({ "Yes" => 4, "No" => 2, "Unknown" => 1 })
open_events = events.select { |e| e.status == "Open" }
event_registrations = EVENT_REGISTRATIONS.times.map do
  EventRegistration.new(open_events.sample, contact_ids.sample, attended_statuses.sample)
end

write_csv(event_registrations.map(&:to_h), "event_registrations.csv", headers: event_registrations.first.to_h.keys)

# MAILING LIST SIGNUPS
# ======= ==== =======

# A mailing list signup record with flags covering the candidate's status
class MailingListSignup
  attr_reader :contact_id, :subscribed_at, :still_subscribed, :opted_out_of_all_emails,
              :opted_out_of_bulk_emails, :opted_out_of_post, :subscription_channel

  def initialize(contact_id)
    @contact_id = contact_id
    @subscribed_at = datetime_in_past(year: 6)

    @subscription_channel = "Website"
    @still_subscribed = random_yes_or_no
    @opted_out_of_all_emails = random_yes_or_no
    @opted_out_of_bulk_emails = random_yes_or_no
    @opted_out_of_post = random_yes_or_no
  end

  def to_h
    {
      contact_id: contact_id,
      subscribed_at: format_datetime(subscribed_at),
      subscription_channel: subscription_channel,
      still_subscribed: still_subscribed,
      opted_out_of_all_emails: opted_out_of_all_emails,
      opted_out_of_bulk_emails: opted_out_of_bulk_emails,
      opted_out_of_post: opted_out_of_post,
    }
  end

private

  def random_yes_or_no
    %w(yes no no no).sample
  end
end

mailing_list_signups = MAILING_LIST_SIGNUPS.times.map { MailingListSignup.new(contact_ids.sample) }
write_csv(mailing_list_signups.map(&:to_h), "mailing_list_signups.csv", headers: mailing_list_signups.first.to_h.keys)

# Teacher Training Adviser Signups
# ======= ======== ======= =======


# Details on the candidate's signup to a TTA
class TeacherTrainingAdviserSignup
  attr_reader :contact_id, :signed_up_at, :subscription_channel,
              :opted_out_of_all_emails, :opted_out_of_bulk_emails,
              :opted_out_of_post

  def initialize(contact_id)
    @contact_id = contact_id
    @signed_up_at = datetime_in_past(year: 3)

    @subscription_channel = "Website"
    @opted_out_of_all_emails = random_yes_or_no
    @opted_out_of_bulk_emails = random_yes_or_no
    @opted_out_of_post = random_yes_or_no
  end

  def to_h
    {
      contact_id: contact_id,
      signed_up_at: format_datetime(signed_up_at),
      subscription_channel: subscription_channel,
      opted_out_of_all_emails: opted_out_of_all_emails,
      opted_out_of_bulk_emails: opted_out_of_bulk_emails,
      opted_out_of_post: opted_out_of_post,
    }
  end

private

  def random_yes_or_no
    %w(yes no no no).sample
  end
end

tta_signups = TTA_SIGNUPS.times.map { TeacherTrainingAdviserSignup.new(contact_ids.sample) }
write_csv(tta_signups.map(&:to_h), "teacher_training_adviser_signups.csv", headers: tta_signups.first.to_h.keys)


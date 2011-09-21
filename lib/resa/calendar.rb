require 'icalendar'
require 'date'
require 'open-uri'

module Resa
  class Calendar

    # Flush all events and re-import
    def self.import(filename = :reservations)
      server = Resa.config[:calendar][:server]
      ics = Resa.config[:calendar][filename]

      cal_file = open(server + ics).read

      calendar = Icalendar.parse(cal_file)
      cal = calendar.first
      events = cal.events

      events.each do |e|
        room = Room.find_or_create(e.location).first

        room.flush_events

        room.events.create(
          title:      e.summary,
          organizer:  e.organizer,
          dtstart:    e.dtstart,
          dtend:      e.dtend
        )
      end
    end

    # Export calendar
    def self.export
      server = Resa.config[:calendar][:server]
      ics = Resa.config[:calendar][:name]

      cal = Icalendar::Calendar.new

      rooms = Resa::Room.all
      rooms.each do |room|
        events = room.events

        events.each do |event|
          puts event.title
          cal.add_event(event.to_ics)
        end
      end

      cal.publish

      export = File.new(server + ics, "w")
      export.write(cal.to_ical)
      export.close
    end
  end
end

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

      # building location index by name.
      locations = Location.all
      location_index = locations.inject({}) do |result, location|
        result[location.name] = location
        result
      end
      calendar.first.events.each do |event|
        evt = Event.create(
          title:        event.summary,
          dtstart:      event.dtstart,
          dtend:        event.dtend,
          location_id:  location_index[event.location]._id
        )
        user = MongoidUser.where(:_id => event.organizer.to_s).one
        evt.organizer = user
        evt.save
      end
    end

    # Export calendar
    def self.export
      server = Resa.config[:calendar][:server]
      ics = Resa.config[:calendar][:name]

      cal = Icalendar::Calendar.new

      events = Event.all
      events.each do |event|
        cal.add_event(event.to_ics)
      end

      cal.publish

      export = File.new(server + ics, "w")
      export.write(cal.to_ical)
      export.close
    end
  end
end

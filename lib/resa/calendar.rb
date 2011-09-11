require 'icalendar'
require 'date'
require 'open-uri'

module Resa
  class Calendar
    
    # Flush all events and re-import
    def self.import
      server = Resa.config[:calendar][:server]
      calendar = Resa.config[:calendar][:name]
      
      cal_file = open(server + calendar).read
      
      cals = Icalendar.parse(cal_file)
      cal = cals.first
      events = cal.events

      events.each do |e|
        room = Resa::Room.find_or_create(e.location).first

        room.events.create(
          title:    e.summary,
          dtstart:  e.dtstart,
          dtend:    e.dtend
        )
      end
    end
  end
end

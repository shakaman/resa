require 'icalendar'
require 'date'
require 'open-uri'

module Resa
  class Calendar
    
    # Flush all events and re-import
    def self.import
      server = Resa.config[:calendar][:server]
      ics = Resa.config[:calendar][:name]
      
      cal_file = open(server + ics).read
      
      calendar = Icalendar.parse(cal_file)
      cal = calendar.first
      events = cal.events

      events.each do |e|
        room = Room.find_or_create(e.location).first
        
        room.flush_events

        room.events.create(
          title:    e.summary,
          dtstart:  e.dtstart,
          dtend:    e.dtend
        )
      end
    end
  end

  # Export calendar
  def self.export
    server = Resa.config[:calendar][:server]
    ics = Resa.config[:calendar][:name]
      
    cal_file = open(server + ics).read
    calendar = Icalendar.parse(cal_file)
    
    calendar.publish
    content_type 'text/calendat', :charset => 'utf-8'
    calendar.to_ical
  end
end

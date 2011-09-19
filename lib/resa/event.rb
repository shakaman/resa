module Resa
  class Event
    include Mongoid::Document
    field :title,       type: String
    field :dtstart,     type: DateTime
    field :dtend,       type: DateTime

    # others fields
    # categories, alarms, contacts, duration, organizer
    
    embedded_in :room, :class_name => "Resa::Room"
 
    # Convert event to iCalendar
    def to_ics
      event = Icalendar::Event.new

      event.start         = self.dtstart
      event.end           = self.dtend
      event.summary       = self.title
      event.location      = self.room.name 

      event
    end
  end
end

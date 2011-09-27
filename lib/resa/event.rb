module Resa
  class Event
    include Mongoid::Document
    field :title,       type: String
    field :organizer,   type: String
    field :location,    type: String
    field :dtstart,     type: Time
    field :dtend,       type: Time

    embedded_in :room, :class_name => "Resa::Room"

    def self.list
      rooms = Room.all
      list = Array.new

      rooms.each do |room|
        list.concat room.events
      end

      list
    end

    # Convert event to iCalendar
    def to_ics
      event = Icalendar::Event.new

      event.start         = self.dtstart
      event.end           = self.dtend
      event.summary       = self.title
      event.organizer     = self.organizer
      event.location      = self.room.name 

      event
    end
  end
end

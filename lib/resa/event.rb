module Resa
  class Event
    include Mongoid::Document
    field :title,       :type => String
    field :organizer,   :type => String
    field :dtstart,     :type => Time
    field :dtend,       :type => Time

    has_one :location, class_name: 'Resa::Location', inverse_of: :event

    # Convert event to iCalendar
    def to_ics
      event = Icalendar::Event.new

      event.start         = self.dtstart
      event.end           = self.dtend
      event.summary       = self.title
      event.organizer     = self.organizer
      event.location      = self.location.name

      event
    end
  end
end

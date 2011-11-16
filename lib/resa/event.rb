module Resa
  class Event
    include Mongoid::Document
    include Mongoid::Timestamps
    field :title,       :type => String
    field :dtstart,     :type => Time
    field :dtend,       :type => Time

    belongs_to :location, :class_name => 'Resa::Location', :inverse_of => :event
    belongs_to :organizer, :class_name => 'MongoidUser', :inverse_of => :events
    accepts_nested_attributes_for :organizer

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

module Resa
  class Event
    include Mongoid::Document
    field :title,       type: String
    field :dtstart,     type: DateTime
    field :dtend,       type: DateTime
    
    embedded_in :room, :class_name => "Resa::Room"

  end
end

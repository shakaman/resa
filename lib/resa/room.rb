module Resa
  class Room
    include Mongoid::Document
    field :name, type: String
    embeds_many :events, :class_name => "Resa::Event"

    validates_uniqueness_of :name

    def self.list
      rooms = Room.all
      list = Array.new
      rooms.each do |room|
        list << room.name
      end

      list.join(', ')
    end

    def self.find_or_create(name)
      create(:name => name)
      where(:name => name)
    end
  end
end

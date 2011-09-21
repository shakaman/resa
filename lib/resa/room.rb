module Resa
  class Room
    include Mongoid::Document
    field :name, type: String
    embeds_many :events, :class_name => "Resa::Event"

    validates_uniqueness_of :name

    # List of rooms
    # @return list
    def self.list
      rooms = Room.all
      list = Hash.new

      rooms.each do |room|
        list[room.name] = Resa.config[:rooms][room.name.to_sym] if Resa.config[:rooms].keys.include?(room.name.to_sym)
      end

      list
    end

    # Find or create a room
    # @params name
    def self.find_or_create(name)
      create(:name => name)
      where(:name => name)
    end



    # Flush all events
    def flush_events
      self.events.delete_all
    end
    
    # Returns all events of the day
    def reservations_for_a_day(date=nil)
      if date.nil?
        date = Time.now
        date = date.strftime("%Y-%m-%d")
      end

      # Je pense que ca serait plus simple trier dans un tableau
      reservations = Array.new

      # 00h00<-->start<-->end<-->23h59
      reservations.concat self.events.where(:dtstart.gte => Time.parse(date + ' 00h00'), :dtstart.lte => Time.parse(date + ' 23h59'))

      # <--yesterday<-->end
      reservations.concat self.events.where(:dtend.gte => Time.parse(date + ' 00h00'), :dtend.lte => Time.parse(date + ' 23h59'))
      
      # start<-->tomorrow-->
      reservations.concat self.events.where(:dtstart.gte => Time.parse(date + ' 00h00'), :dtstart.lte => Time.parse(date + ' 23h59'))
      
      # <--yesterday<-->start|--|end<-->tomorrow->>
      reservations.concat self.events.where(:dtstart.lte => Time.parse(date), :dtend.gte => Time.parse(date))
      
      reservations.sort_by {|a| a.dtstart}
      reservations.uniq
    end

    def availabilities
      self.events.where(:dtstart.gte => Time.now, :dtend.lte => Time.parse('23h59'))
    end
    
    # Returns all events of the day
    def check_availability(dtstart=nil, dtend=nil)
      if dtstart.nil? || dtend.nil?
        return 'Date error'
      end

      reservations = Array.new
      
      # dtstart > start && dtend < end
      reservations.concat self.events.where(:dtstart.gte => dtstart, :dtend.lte => dtend)

      # dtstart < start && dtend > start && dtend < end
      reservations.concat self.events.where(:dtstart.lte => dtstart, :dtend.gte => dtstart, :dtend.lte => dtend)

      # dtstart > start && dtstart < end && dtend > end
      reservations.concat self.events.where(:dtstart.gte => dtstart, :dtstart.lte => dtend, :dtend.gte => dtend)
      
      # dtstart < start && dtend > end
      reservations.concat self.events.where(:dtstart.lte => dtstart, :dtend.gte => dtend)
      
      unless reservations.empty?
        return 'Room not available'
      end
    end
  end
end

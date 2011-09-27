module Resa
  class Room
    include Mongoid::Document
    field :name, :type => String
    embeds_many :events, :class_name => "Resa::Event"

    validates_uniqueness_of :name

    # List of rooms
    # @return list
    def self.list
      rooms = Room.all
      list = Array.new

      rooms.each do |room|
        room_hash = Hash.new
        room_hash['_id'] = room.name
        room_hash['name'] = Resa.config[:rooms][room.name.to_sym] if Resa.config[:rooms].keys.include?(room.name.to_sym)

        list << room_hash
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

    # Returns all events for a month
    def reservations_for_a_month(year=nil, month=nil)
      date = Time.now

      year = date.year if year.nil?
      month = date.month if month.nil?

      reservations = Array.new
      reservations.concat self.events.where(:dtstart.gte => Date.new(year.to_i, month.to_i, 1), :dtstart.lte => Date.new(year.to_i, month.to_i, -1))

      reservations.sort_by {|a| a.dtstart}
      reservations.uniq
    end


    # Returns all events of the day
    def reservations_for_a_day(date=nil)
      if date.nil?
        date = Time.now
        date = date.strftime("%Y-%m-%d")
      end

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

    # Returns all events of the day.
    #
    # @return [true, false]
    #
    def available?(dtstart=nil, dtend=nil)
      if dtstart.nil? || dtend.nil?
        return false
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
        return false
      end

      true
    end
  end
end

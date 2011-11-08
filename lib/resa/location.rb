module Resa
  class Location
    include Mongoid::Document

    field :name, :type => String
    field :color, :type => String
    belongs_to :event, class_name: 'Resa::Event', inverse_of: :location

    validates_presence_of :name
    validates_uniqueness_of :name

    def self.import
      data = YAML.load_file(Resa.config_file)
      data[:locations].each do |key, location|
        create! location
      end
    end

  end

end

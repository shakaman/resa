class MongoidUser
  has_many :events, class_name: 'Resa::Event', inverse_of: :organizer
end

class User
  def can_update?(event)
    p event.organizer
    p db_instance
    admin? || (event.organizer == db_instance) || event.organizer.nil?
  end
end

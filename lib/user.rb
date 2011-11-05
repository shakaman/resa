class MongoidUser
  has_many :events, class_name: 'Resa::Event', inverse_of: :organizer

end

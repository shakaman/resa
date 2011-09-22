RESA
====

Requirements
------------

ruby 1.9
mkdir tmp
Setup with `gem install bundler && bundle install`.
Start with `bundle exec thin start -C config/development.yml`.
Check http://localhost:3000/ with your $BROWSER of choice.


Install
-------

`cp config/config_example.yml config/config.yml`

Load environment in console
`ruby bin/console`

Tests
-----

`bundle exec ruby test/resa_test.rb`

TODO
====
`http://localhost:3000/` 																					: return rooms available now
`http://localhost:3000/rooms` 																		: return list of rooms
`http://localhost:3000/rooms/:id` 																: return room's availability for the current day
`http://localhost:3000/rooms/:id/reservations` 										: return room's availability for the day
`http://localhost:3000/rooms/:id/reservations/:year/:month/:day`	: return room's availability for a day


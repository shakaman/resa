RESA
====

Requirements
------------

Setup with `gem install bundler && bundle install`.
Start with `bundle exec thin start -C config/development.yml`.
Check http://localhost:4567/ with your $BROWSER of choice.


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
`http://localhost:4567/` 																: return rooms available now

`http://localhost:4567/rooms` 													: return list of rooms

`http://localhost:4567/rooms/:room_id` 									: return room's availability for the current day

`http://localhost:4567/rooms/:room_id/tomorrow` 				: return room's availability for the next day


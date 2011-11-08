# RESA

**Check and make reservations for our meeting rooms.**

## Requirements

* Ruby 1.9

## Install

``` bash
git clone https://github.com/shakaman/resa.git
cd resa
mkdir tmp
gem install bundler && bundle install
cp config/config_example.yml config/config.yml
cp config/development_example.yml config/development.yml
```

Edit various config files (be smart) `config/config.yml` and `config/development.yml`.

notice: you should add a user using console and switch it''s permission_level to -1.
You now have an admin account.

	bundle exec ruby bin/console
	User.set(:email => "admin@admin.com", :password => "admin",
	  :password_confirmation => 'admin', :permission_level => -1)

	Create Location set on console:
	Resa::Location.import
	Resa::Calendar.import

## Usage

Start with:

``` bash
export RUBYLIB=./lib/
bundle exec thin start -C config/development.yml
```

Check http://localhost:3000/ in your `$BROWSER` of choice.

Load the development environment in a IRB console:

``` ruby
ruby bin/console
```

## Tests

``` bash
rake test
```

## License

GNU AFFERO GENERAL PUBLIC LICENSE
see license.txt

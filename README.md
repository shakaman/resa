# RESA

**Check and make reservations for our meeting rooms.**

## Requirements

* Ruby 1.9

## Install

``` bash
bundle install # or bundle pack
```

Edit various config files (be smart), then:

``` bash
mkdir tmp
Setup with `gem install bundler && bundle install`.
cp config/config_example.yml config/config.yml
cp config/development_example.yml config/development.yml
Start with `bundle exec thin start -C config/development.yml`.
Check http://localhost:3000/ with your $BROWSER of choice.

*TODO: clean the conf and paths.*

## Use

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

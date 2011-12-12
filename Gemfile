source :rubygems

# Framework
gem 'sinatra'

# BD
gem 'mongoid'
gem 'bson_ext'

# Libs calendar
gem 'icalendar'

# Serve with thin
gem 'thin'

# templating using haml
gem 'haml'

# flash notification
gem 'rack-flash'

# authentication
gem 'sinatra-authentication', :git => 'git://github.com/spk/sinatra-authentication.git',
  :branch => 'resa'

# mail
gem 'pony'

# JSON
gem 'yajl-ruby'

# pagination
# XXX: using git version for sinatra support
# see https://github.com/udzura/kaminari/commit/1da155b15befe9b16cf7b05973072c5f8729017e
gem 'kaminari', :require => 'kaminari/sinatra', :git => 'https://github.com/amatsuda/kaminari.git'
gem 'padrino-helpers'

# development
group :development do
  gem 'capistrano'
  gem 'shotgun'
  # An IRB alternative and runtime developer console
  gem 'pry'
  gem 'rake'
  gem 'letter_opener'
end

group :test do
  gem 'minitest', '~>2.4.0'
  gem 'rack-test', '~>0.6.1'
end

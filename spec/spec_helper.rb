$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pg_tester'
require 'fileutils'

RSpec.configure do |config|
  unless ENV['JENKINS']
    config.color = true
    config.tty = true
  end
end



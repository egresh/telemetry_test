#!/usr/bin/env ruby

require_relative "lib/telemetry"

APP_ROOT = File.expand_path("../", __FILE__)

include Telemetry::ActionUtils

# Examples to test the code
# action = create_action(['-s', './run_ruby.rb', '-l', '-a'])
# action = create_action(['-n', 'www.google.com'])
# action = create_action(['-c', '/tmp', 'test_name', 'file'])
# action = create_action(['-d', '/tmp/test_name'])
# action = create_action(['-m', '/tmp/foo.txt', 'arg', 'arg2', 'arg3'])

begin
  action = create_action(ARGV)
  action.execute
rescue StandardError => e
  puts e.message
  puts
  puts "Run the program with '-u' to see the usage"
  puts "Example: main.rb -u"
  exit false
end

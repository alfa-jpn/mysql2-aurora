require 'bundler/setup'
require 'spec_helpers/coverage_helper'
require 'mysql2/aurora'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.order = :random
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

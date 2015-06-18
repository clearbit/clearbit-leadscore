$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'clearbit/lead_score'
require 'pry'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = 'random'
end

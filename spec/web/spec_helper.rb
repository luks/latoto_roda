ENV["RACK_ENV"] = "test"
require_relative '../../latoto'
raise "test database doesn't end with test" unless DB.get{current_database{}} =~ /test\z/


require 'capybara'
require 'capybara/dsl'
require 'rack/test'

require_relative '../minitest_helper'

Capybara.app = Latoto.freeze

class Minitest::Spec
  include Rack::Test::Methods
  include Capybara::DSL
end

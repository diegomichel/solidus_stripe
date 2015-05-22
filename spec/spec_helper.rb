require "simplecov"
SimpleCov.start "rails"

ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "rspec/rails"
require "rspec/active_model/mocks"
require "capybara/rspec"
require "capybara/rails"
require "capybara/poltergeist"
require "database_cleaner"
require "ffaker"
require "rspec/active_model/mocks"
require "braintree"

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }

require "spree/testing_support/factories"
require "spree/testing_support/order_walkthrough"
require "spree/testing_support/preferences"

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.mock_with :rspec

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.use_transactional_fixtures = false

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::Preferences

  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation

    # Don't log Braintree to STDOUT.
    Braintree::Configuration.logger = Logger.new("spec/dummy/tmp/log")
  end

  config.before do
    DatabaseCleaner.strategy = RSpec.current_example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
    reset_spree_preferences
  end

  config.after do
    DatabaseCleaner.clean
  end

  Capybara.javascript_driver = :poltergeist
end

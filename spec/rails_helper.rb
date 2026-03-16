ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryBot::Syntax::Methods

  # Disable transactional fixtures for system tests (Capybara needs persisted data)
  config.before(:each, type: :system) do
    config.use_transactional_fixtures = false
  end

  config.after(:each, type: :system) do
    config.use_transactional_fixtures = true
  end

  # Cleanup database and ActionMailer between tests
  config.before(:each, type: :system) do
    # Clear ActionMailer deliveries to prevent test pollution
    ActionMailer::Base.deliveries.clear
  end

  config.after(:each, type: :system) do
    # Truncate all tables after system tests
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE users, async_logs, active_storage_attachments, active_storage_blobs, active_job_locks RESTART IDENTITY CASCADE")
  end
end

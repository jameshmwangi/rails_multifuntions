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
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include FactoryBot::Syntax::Methods

  # Disable transactional fixtures globally — manage manually below
  config.use_transactional_fixtures = false

  config.around(:each) do |example|
    if example.metadata[:type] == :system
      # System specs: no transaction wrapping — Capybara needs real commits
      example.run
    else
      # All other specs: wrap in transaction and roll back
      ActiveRecord::Base.transaction do
        example.run
        raise ActiveRecord::Rollback
      end
    end
  end

  config.before(:each, type: :system) do
    ActionMailer::Base.deliveries.clear
  end

  config.after(:each, type: :system) do
    ActiveRecord::Base.connection.execute(
      "TRUNCATE TABLE users, async_logs, active_storage_attachments, " \
      "active_storage_blobs, active_job_locks RESTART IDENTITY CASCADE"
    )
  end
end

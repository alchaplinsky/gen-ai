# frozen_string_literal: true

require 'gen_ai'
require 'vcr'

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.default_cassette_options = {
    record: ENV['API_ACCESS_TOKEN'] ? :all : :new_episodes,
    match_requests_on: %i[method uri]
  }
  c.filter_sensitive_data('FAKE_TOKEN') { ENV.fetch('API_ACCESS_TOKEN', nil) }
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  warning = <<-WARNING
    WARNING: You are running the test suite with an API access token!
    This should only be done for recording new HTTP requests to the API
    with VCR and store them in the cassettes directory. If you are not
    recording new cassettes, please remove the API access token from the
    environment variables to avoid additional costs for API calls.
  WARNING

  config.before(:suite) do
    if ENV['API_ACCESS_TOKEN']
      RSpec.configuration.reporter.message(RSpec::Core::Formatters::ConsoleCodes.wrap(warning, :red))
    end
  end
end

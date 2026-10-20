ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/retry'
Minitest::Retry.use!

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module ActionDispatch
  class IntegrationTest
    # Forgery protection is off in tests, so nothing is written to the session
    # until a page stores something. Viewing a query stores the last view.
    def start_session
      get query_url(queries(:one))
      session.id.to_s
    end
  end
end

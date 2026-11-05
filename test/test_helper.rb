ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/retry'
Minitest::Retry.use!
require_relative 'support/recorded_dns'

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Recorded DNS lookups finish in well under a millisecond, so tests that
    # check a lookup's duration advance the clock by a fixed step per read.
    def with_monotonic_clock(step:)
      original = Time.method(:monotonic_now)
      now = 0.0
      Time.define_singleton_method(:monotonic_now) { now += step }
      yield
    ensure
      Time.define_singleton_method(:monotonic_now, original)
    end
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

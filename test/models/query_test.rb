# == Schema Information
#
# Table name: queries
#
#  id            :uuid             not null, primary key
#  dnssec_failed :boolean
#  domain        :string
#  duration      :integer
#  results       :json             not null
#  server        :string
#  server_ip     :string
#  type          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  session_id    :string
#
require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  test 'domain setter will strip paths' do
    query = Query.new(domain: 'd53.com/path')
    assert_equal 'd53.com', query.domain
  end

  test 'domain setter will strip just a trailing slash' do
    query = Query.new(domain: 'd53.com/')
    assert_equal 'd53.com', query.domain
  end

  test 'domain setter will strip protocols' do
    query1 = Query.new(domain: 'http://d53.com')
    query2 = Query.new(domain: 'ftp://d53.com')
    assert_equal 'd53.com', query1.domain
    assert_equal 'd53.com', query2.domain
  end

  test 'domain setter will strip spaces' do
    query = Query.new(domain: 'd53 .com')
    assert_equal 'd53.com', query.domain
  end

  test 'domain setter will strip protocol, path, and spaces together' do
    query = Query.new(domain: 'http://d53.com/this path')
    assert_equal 'd53.com', query.domain
  end

  test 'domain setter will strip trailing period' do
    query = Query.new(domain: 'd53.co.')
    assert_equal 'd53.co', query.domain
  end

  test 'server setter will only set known server' do
    query_with_known_server = Query.new(server: 'Cloudflare')
    query_with_unknown_server = Query.new(server: 'Flarecloud')

    assert_equal 'Cloudflare', query_with_known_server.server
    assert_equal '1.1.1.1', query_with_known_server.server_ip
    assert_nil query_with_unknown_server.server
    assert_nil query_with_unknown_server.server_ip
  end

  test 'server setter is case insensitive' do
    query = Query.new(server: 'cloudflare')
    assert_equal 'Cloudflare', query.server
  end

  test 'type setter will only set known type' do
    query_with_known_type = Query.new(type: 'A')
    query_with_unknown_type = Query.new(type: 'B')
    assert_equal 'A', query_with_known_type.type
    assert_nil query_with_unknown_type.type
  end

  test 'type setter is case insensitive' do
    query = Query.new(type: 'a')
    assert_equal 'A', query.type
  end

  test 'type setter ignores nil' do
    query = Query.new(type: nil)
    assert_nil query.type
  end

  test 'domain setter ignores blank values' do
    query = Query.new(domain: 'd53.co')
    query.domain = ''
    assert_equal 'd53.co', query.domain
  end

  test 'domain_name is an alias for domain' do
    query = Query.new(domain_name: 'HTTPS://D53.co/')
    assert_equal 'd53.co', query.domain
  end

  test 'requires domain, server, and type' do
    query = Query.new
    refute query.valid?
    assert_includes query.errors[:domain], "can't be blank"
    assert_includes query.errors[:server], "can't be blank"
    assert_includes query.errors[:type], "can't be blank"
  end

  test 'is valid with domain, server, and type' do
    query = Query.new(domain: 'd53.co', server: 'Google', type: 'A')
    assert query.valid?
  end

  test 'for_session scopes to the session' do
    queries(:two).update!(session_id: 'mine')
    assert_equal [queries(:two)], Query.for_session('mine').to_a
  end

  test 'for_session is empty without a session' do
    queries(:one).update!(session_id: '')
    assert_empty Query.for_session('')
    assert_empty Query.for_session(nil)
  end

  test 'owned_by? matches the session' do
    query = queries(:one)
    assert query.owned_by?('other-session')
    refute query.owned_by?('mine')
  end

  test 'owned_by? is false without a session' do
    query = Query.new(session_id: '')
    refute query.owned_by?('')
    refute query.owned_by?(nil)
  end

  test 'duration_ms is delimited' do
    assert_equal '1,234 ms', queries(:one).duration_ms
  end

  test 'duration_ms defaults to zero' do
    assert_equal '0 ms', Query.new.duration_ms
  end

  test 'redirect_params are lowercase' do
    assert_equal(
      { domain_name: 'google.com', type: 'a', server: 'cloudflare' },
      queries(:one).redirect_params
    )
  end

  test 'do_dns_lookup! stores the lookup' do
    query = Query.new(domain: 'a.testing.d53.co', server: 'Cloudflare', type: 'A')
    assert_same query, query.do_dns_lookup!
    assert_equal 'NOERROR', query.results.dig('json', 'status')
    assert_equal '0.0.0.0', query.results.dig('json', 'answer', 0, 'address')
    assert query.duration.positive?
    refute query.dnssec_failed
  end
end

# == Schema Information
#
# Table name: queries
#
#  id         :uuid             not null, primary key
#  domain     :string
#  duration   :integer
#  results    :json             not null
#  server     :string
#  server_ip  :string
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  session_id :string
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
end

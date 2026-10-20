require 'test_helper'

class RedirectControllerTest < ActionDispatch::IntegrationTest
  setup do
    @domain = Faker::Internet.unique.domain_name
  end

  test 'should create query with server, type, and domain' do
    get "/google/mx/#{@domain}"

    assert_redirected_to query_path(new_query)
    assert_equal 'Google', new_query.server
    assert_equal 'MX', new_query.type
    assert_equal @domain, new_query.domain
  end

  test 'should create query with type and domain' do
    get "/mx/#{@domain}"

    assert_redirected_to query_path(new_query)
    assert_equal 'Cloudflare', new_query.server
    assert_equal 'MX', new_query.type
    assert_equal @domain, new_query.domain
  end

  test 'should 404 unless type and domain' do
    get "/#{@domain}"
    assert_response :not_found
  end

  test 'should 404 unless valid type' do
    get "/x/#{@domain}"
    assert_response :not_found
  end

  test 'should 404 unless server' do
    get "/flarecloud/a/#{@domain}"
    assert_response :not_found
  end

  test 'should allow case insensitive type' do
    get "/A/#{@domain}"
    assert_response :redirect
  end

  test 'should allow case insensitive server' do
    get "/GoOgLe/a/#{@domain}"
    assert_response :redirect
  end

  test 'should strip a format from the domain' do
    get "/a/#{@domain}.json"

    assert_redirected_to query_path(new_query)
    assert_equal 'A', new_query.type
  end

  test 'should store the lookup results and session' do
    session_id = start_session
    get "/a/#{@domain}"

    assert_equal session_id, new_query.session_id
    assert_equal '1.1.1.1', new_query.server_ip
    assert new_query.results.dig('json', 'status').present?
  end

  test 'should 404 when the domain is blank once cleaned' do
    assert_no_difference('Query.count') do
      get '/a/%20'
    end

    assert_response :not_found
  end

  private

  def new_query
    @new_query ||= Query.find_by(domain: @domain)
  end
end

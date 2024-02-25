require "test_helper"

class RedirectControllerTest < ActionDispatch::IntegrationTest
  setup do
    @domain = Faker::Internet.unique.domain_name
  end

  test "should create query with server, type, and domain" do
    get "/google/mx/#{@domain}"

    assert_redirected_to query_path(new_query)
    assert_equal 'Google', new_query.server
    assert_equal 'MX', new_query.type
    assert_equal @domain, new_query.domain
  end

  test "should create query with type and domain" do
    get "/mx/#{@domain}"

    assert_redirected_to query_path(new_query)
    assert_equal 'Cloudflare', new_query.server
    assert_equal 'MX', new_query.type
    assert_equal @domain, new_query.domain
  end

  test "should create query with domain" do
    get "/#{@domain}"

    assert_redirected_to query_path(new_query)
    assert_equal 'Cloudflare', new_query.server
    assert_equal 'A', new_query.type
    assert_equal @domain, new_query.domain
  end

  private

  def new_query
    @new_query ||= Query.find_by(domain: @domain)
  end
end

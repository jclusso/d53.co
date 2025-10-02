require 'test_helper'

class QueriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @query = queries(:one)
  end

  test 'should get index' do
    get queries_url
    assert_response :success
  end

  test 'should create query' do
    domain = Faker::Internet.unique.domain_name
    assert_difference('Query.count') do
      post queries_url, params: {
        query: { domain: domain, server: 'Cloudflare', type: 'A' }
      }
    end

    assert_redirected_to query_url(Query.find_by(domain: domain))
  end

  test 'should show query' do
    get query_url(@query)
    assert_response :success
  end

  test 'should destroy query' do
    assert_difference('Query.count', -1) do
      delete query_url(@query)
    end

    assert_redirected_to root_url
  end
end

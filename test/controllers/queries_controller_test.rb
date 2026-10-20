require 'test_helper'

class QueriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @query = queries(:one)
  end

  test 'should get index' do
    get queries_url
    assert_response :success
  end

  test 'index only lists queries from the current session' do
    session_id = start_session
    queries(:two).update!(session_id: session_id)

    get queries_url
    assert_select 'tbody tr', 1
    assert_select 'tbody a', text: queries(:two).domain
  end

  test 'index lists nothing without a session' do
    get queries_url
    assert_select 'tbody', false
  end

  test 'index lists every query with the all filter' do
    get queries_url(filter: 'all')
    assert_select 'tbody tr', Query.count
  end

  test 'index clamps the limit' do
    Query.insert_all(
      Array.new(30) do |i|
        {
          domain: "#{i}.d53.co", type: 'A', server: 'Cloudflare',
          server_ip: '1.1.1.1', results: {}
        }
      end
    )

    get queries_url(filter: 'all')
    assert_select 'tbody tr', 25

    get queries_url(filter: 'all', limit: 27)
    assert_select 'tbody tr', 27

    get queries_url(filter: 'all', limit: 1000)
    assert_select 'tbody tr', Query.count
  end

  test 'index prefills type and server from the latest query' do
    session_id = start_session
    queries(:two).update!(session_id: session_id)

    get queries_url
    assert_select 'select[name="query[type]"] option[selected]', text: 'NS'
    assert_select 'select[name="query[server]"] option[selected]', text: 'Google'
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

  test 'create stores the lookup results and session' do
    session_id = start_session
    post queries_url, params: {
      query: { domain: 'a.testing.d53.co', server: 'Google', type: 'A' }
    }

    query = Query.order(:created_at).last
    assert_equal session_id, query.session_id
    assert_equal '8.8.8.8', query.server_ip
    assert_equal 'NOERROR', query.results.dig('json', 'status')
    assert query.duration.positive?
  end

  test 'create renders index when invalid' do
    assert_no_difference('Query.count') do
      post queries_url, params: {
        query: { domain: '', server: 'Cloudflare', type: 'A' }
      }
    end

    assert_response :unprocessable_content
    assert_select 'form[action=?]', queries_path
  end

  test 'should show query' do
    get query_url(@query)
    assert_response :success
    assert_select 'span', text: @query.domain
    assert_select 'span', text: '1,234 ms'
  end

  test 'show 404s for an unknown query' do
    get query_url(SecureRandom.uuid)
    assert_response :not_found
  end

  test 'show defaults to the json view' do
    get query_url(@query)
    assert_select 'code.language-json', text: /142\.250\.80\.46/
    assert_select 'a.bg-lime-500', text: 'JSON'
  end

  test 'show renders the zone view' do
    get query_url(@query, view: 'zone')
    assert_select 'code.language-dns', text: /google\.com\.\s+300\s+IN\s+A/
    assert_select 'a.bg-lime-500', text: 'ZONE'
  end

  test 'show remembers the last view' do
    get query_url(@query, view: 'zone')
    get query_url(queries(:dnssec_failed))
    assert_select 'code.language-dns'
  end

  test 'show hides the view toggle without a zone' do
    get query_url(queries(:two), view: 'zone')
    assert_select 'a', text: 'ZONE', count: 0
    assert_select 'code.language-json', text: /TIMEOUT/
  end

  test 'show warns when dnssec validation failed' do
    get query_url(queries(:dnssec_failed))
    assert_select 'p', text: /failed DNSSEC validation/
  end

  test 'show does not warn when dnssec validation passed' do
    get query_url(@query)
    assert_select 'p', text: /failed DNSSEC validation/, count: 0
  end

  test 'show links to the realtime lookup' do
    get query_url(@query)
    assert_select 'input[name=realtime_query][value=?]',
                  'http://www.example.com/cloudflare/a/google.com'
  end

  test 'show only offers removal to the owner' do
    get query_url(@query)
    assert_select 'button', text: 'Remove', count: 0

    @query.update!(session_id: session.id.to_s)
    get query_url(@query)
    assert_select 'button', text: 'Remove'
  end

  test 'should destroy query' do
    @query.update!(session_id: start_session)

    assert_difference('Query.count', -1) do
      delete query_url(@query)
    end

    assert_redirected_to root_url
  end

  test 'destroy 404s for another session' do
    start_session

    assert_no_difference('Query.count') do
      delete query_url(@query)
    end

    assert_response :not_found
  end

  test 'destroy 404s without a session' do
    @query.update!(session_id: '')

    assert_no_difference('Query.count') do
      delete query_url(@query)
    end

    assert_response :not_found
  end
end

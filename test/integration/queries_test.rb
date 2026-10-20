require 'test_helper'

class QueriesTest < ActionDispatch::IntegrationTest
  test 'searching shows the results and adds them to recent' do
    start_session
    get root_path
    assert_select 'form[action=?]', queries_path

    post queries_path, params: {
      query: { domain: 'MX.testing.d53.co', server: 'Quad9', type: 'mx' }
    }
    follow_redirect!
    assert_select 'span', text: 'Results'
    assert_select 'code.language-json', text: /mxv\.testing\.d53\.co/

    get root_path
    assert_select 'tbody a', text: 'mx.testing.d53.co'
  end

  test 'removing a query takes it out of recent' do
    start_session
    post queries_path, params: {
      query: { domain: 'a.testing.d53.co', server: 'Cloudflare', type: 'A' }
    }
    follow_redirect!
    assert_select 'button', text: 'Remove'

    delete path
    follow_redirect!
    assert_select 'tbody a', text: 'a.testing.d53.co', count: 0
  end

  test 'a realtime lookup redirects to the results' do
    get '/google/txt/txt.testing.d53.co'
    follow_redirect!
    assert_select 'code.language-json', text: /test-text/
  end
end

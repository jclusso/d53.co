require 'application_system_test_case'

class QueriesTest < ApplicationSystemTestCase
  setup do
    @query = queries(:one)
  end

  test 'should create query' do
    visit root_path
    create_query
    assert_text 'Results'
  end

  test 'should destroy Query' do
    visit root_path
    create_query
    # need to call twice since the session doesn't get created until it's been
    # set at least once in tests. we set it with the type after creating.
    create_query
    click_on 'Remove', match: :first
    accept_alert
    assert_current_path root_path
  end

  private

  def create_query
    fill_in 'query[domain]', with: @query.domain
    select @query.server, from: 'query[server]'
    select @query.type, from: 'query[type]'
    click_on 'Search'
  end
end

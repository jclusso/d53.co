require "application_system_test_case"

class QueriesTest < ApplicationSystemTestCase
  setup do
    @query = queries(:one)
  end

  test "should create query" do
    visit root_path

    fill_in "query[domain]", with: @query.domain
    select @query.server, from: "query[server]"
    select @query.type, from: "query[type]"
    click_on "Search"

    assert_current_path query_path(Query.last)
  end

  test "should destroy Query" do
    visit query_url(@query)
    click_on "Delete Search", match: :first
    accept_alert
    assert_current_path root_path
  end
end

require 'test_helper'

class ApplicationFormBuilderTest < ActionView::TestCase
  include FormsHelper

  setup do
    @builder = ApplicationFormBuilder.new(:query, Query.new, self, {})
  end

  test 'text field gets the default class' do
    html = fragment(@builder.text_field(:domain, {}))
    assert_select html, 'input.form-field__input[name=?]', 'query[domain]'
    assert_select html, 'label', false
  end

  test 'text field keeps a custom class' do
    html = fragment(@builder.text_field(:domain, class: 'custom'))
    assert_select html, 'input.custom'
    assert_select html, 'input.form-field__input', false
  end

  test 'text field wraps a string label' do
    html = fragment(@builder.text_field(:domain, label: 'Domain Name'))
    assert_select html, 'div.block > label.form-field__label', text: 'Domain Name'
    assert_select html, 'div.block > input.form-field__input:not([label])'
  end

  test 'text field wraps a default label' do
    html = fragment(@builder.text_field(:domain, label: true))
    assert_select html, 'div.block > label.form-field__label', text: 'Domain'
  end

  test 'text field passes hash label options' do
    html = fragment(@builder.text_field(:domain, label: { class: 'custom' }))
    assert_select html, 'div.block > label.custom', text: 'Domain'
  end

  test 'text field passes array label arguments' do
    html = fragment(
      @builder.text_field(:domain, label: ['Host', { class: 'custom' }])
    )
    assert_select html, 'div.block > label.custom', text: 'Host'
  end

  test 'select gets the default class' do
    html = fragment(@builder.select(:type, Query::TYPES))
    assert_select html, 'select.form-field__input[name=?]', 'query[type]'
    assert_select html, 'option', Query::TYPES.count
  end

  test 'select wraps a label' do
    html = fragment(@builder.select(:type, Query::TYPES, label: 'Type'))
    assert_select html, 'div.block > label.form-field__label', text: 'Type'
    assert_select html, 'div.block > select.form-field__input'
  end

  test 'submit gets the default class' do
    html = fragment(@builder.submit('Search'))
    assert_select html, 'input.btn[type=submit][value=Search]'
  end

  test 'submit accepts options without a value' do
    html = fragment(@builder.submit(class: 'custom'))
    assert_select html, 'input.custom[type=submit]'
  end

  private

  def fragment(html)
    Nokogiri::HTML5.fragment(html)
  end
end

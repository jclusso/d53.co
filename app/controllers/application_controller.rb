class ApplicationController < ActionController::Base
  default_form_builder ApplicationFormBuilder

  private

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
end

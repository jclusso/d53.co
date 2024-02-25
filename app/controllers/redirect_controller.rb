class RedirectController < ApplicationController

  def create
    if params[:domain_name].present?
      query = Query.new(params.permit(:server, :type, :domain_name))
      query.type ||= 'A'
      query.server ||= 'Cloudflare'
      query.session_id = session.id.to_s

      if query.valid?
        query.do_dns_lookup!
        query.save

        redirect_to query_path(query)
      else
        redirect_to root_path
      end
    else
      redirect_to root_path
    end
  end

end

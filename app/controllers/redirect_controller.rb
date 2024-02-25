class RedirectController < ApplicationController

  def create
    query = Query.new(params.permit(:server, :type, :domain_name))
    query.server ||= 'Cloudflare'
    query.session_id = session.id.to_s

    if query.valid?
      query.do_dns_lookup!
      query.save

      redirect_to query_path(query)
    else
      not_found
    end
  end

end

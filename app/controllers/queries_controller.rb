class QueriesController < ApplicationController
  before_action :set_query, only: %i[show destroy]

  def index
    @queries = if params[:filter] == 'all'
      Query.all
    else
      Query.where(session_id: session.id.to_s)
    end.order(created_at: :desc)
  end

  def show
  end

  def create
    @query = Query.new(query_params)
    @query.session_id = session.id.to_s

    if @query.valid?
      dns_lookup = DNSLookup.new(@query.domain, @query.type, @query.server_ip)
      @query.results = dns_lookup.run
      @query.duration = dns_lookup.duration
      @query.save

      session[:last_query_type] = @query.type

      redirect_to @query
    else
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @query.destroy!

    redirect_to root_path
  end

  private

  def set_query
    @query = Query.find(params[:id])
  end

  def query_params
    pars = params.require(:query).permit(:domain, :type, :server)
    if pars[:domain].present?
      pars[:domain].gsub!(/(^\w+:|^)\/\//, '')
      pars[:domain].gsub!(/\/.+/, '')
    end
    pars
  end
end

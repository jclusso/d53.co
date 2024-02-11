class QueriesController < ApplicationController
  before_action :set_query, only: %i[show destroy]

  def index
    @queries = if params[:filter] == 'all'
      Query.all.order(created_at: :desc)
    else
      my_queries
    end
  end

  def show
  end

  def create
    @query = Query.new(query_params)
    session[:last_query_type] = @query.type

    if @query.valid?
      dns_lookup = DNSLookup.new(@query.domain, @query.type, @query.server_ip)
      @query.results = dns_lookup.run
      @query.duration = dns_lookup.duration
      @query.save

      session[:queries] ||= []
      session[:queries].push(@query.id)

      redirect_to @query
    else
      render :new, status: :unprocessable_entity
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
    params.require(:query).permit(:domain, :type, :server)
  end
end

class QueriesController < ApplicationController
  before_action :set_query, only: %i[show destroy]

  def index
    @queries = if params[:filter] == 'all'
      Query.all
    else
      Query.where(session_id: session.id.to_s)
    end.order(created_at: :desc)

    @query = Query.new(@queries.first&.slice(:type, :server))
    @limit = params[:limit].to_i.clamp(25, 500)
  end

  def show
    @view = params[:view] || session[:last_query_view] || 'json'
    session[:last_query_view] = @view
  end

  def create
    @query = Query.new(query_params)
    @query.session_id = session.id.to_s

    if @query.valid?
      @query.do_dns_lookup!
      @query.save

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
    params.require(:query).permit(:domain, :type, :server)
  end
end

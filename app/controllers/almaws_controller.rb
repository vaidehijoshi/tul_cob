class AlmawsController < ApplicationController
	include AlmaRequests
	before_action do
		params.merge!(user_id: current_user.uid) if current_user
	end

  def availability
    render json: AlmaRequests.get_bibs_availability(params[:mms_ids]) if
    	params[:mms_ids] && !params[:mms_ids].blank?
  end

  def bib
		render json: AlmaRequests.get_bib(params[:mms_id])
  end

  def bib_availability
    render json: AlmaRequests.get_bib_availability(params[:mms_id])
  end

  def items
  	render json: AlmaRequests.get_items(params)
  end

  def request_options
  	render json: AlmaRequests.get_request_options(params)
  end

  def requests
  	render json: AlmaRequests.get("/bibs/#{params[:mms_id]}/requests")
  end
end

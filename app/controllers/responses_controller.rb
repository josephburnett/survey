class ResponsesController < ApplicationController
  before_action :require_login
  before_action :find_response, only: [:show]
  
  def index
    if params[:section_id]
      @section = current_user.sections.find(params[:section_id])
      @responses = @section.responses.where(user: current_user)
    else
      @responses = current_user.responses
    end
  end

  def show
  end
  
  private
  
  def find_response
    @response = current_user.responses.find(params[:id])
  end
end

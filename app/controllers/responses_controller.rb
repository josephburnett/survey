class ResponsesController < ApplicationController
  before_action :require_login
  before_action :find_response, only: [:show, :edit, :update, :soft_delete]
  
  def index
    if params[:section_id]
      @section = current_user.sections.find(params[:section_id])
      @responses = @section.responses.not_deleted.where(user: current_user)
    else
      @responses = current_user.responses.not_deleted
    end
  end

  def show
  end
  
  def new
    @response = Response.new
    @sections = current_user.sections.not_deleted
  end
  
  def create
    @response = current_user.responses.build(response_params)
    
    if @response.save
      redirect_to @response, notice: 'Response created successfully'
    else
      @sections = current_user.sections.not_deleted
      render :new
    end
  end
  
  def edit
    @sections = current_user.sections.not_deleted
  end
  
  def update
    if @response.update(response_params)
      redirect_to @response, notice: 'Response updated successfully'
    else
      @sections = current_user.sections.not_deleted
      render :edit
    end
  end
  
  def soft_delete
    @response.soft_delete!
    redirect_to responses_path, notice: 'Response deleted successfully'
  end
  
  private
  
  def find_response
    @response = current_user.responses.not_deleted.find(params[:id])
  end
  
  def response_params
    params.require(:response).permit(:section_id)
  end
end

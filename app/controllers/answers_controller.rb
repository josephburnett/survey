class AnswersController < ApplicationController
  before_action :require_login
  before_action :find_answer, only: [:show]
  
  def index
    @answers = current_user.answers
  end

  def show
  end
  
  private
  
  def find_answer
    @answer = current_user.answers.find(params[:id])
  end
end

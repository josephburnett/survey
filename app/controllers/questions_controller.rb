class QuestionsController < ApplicationController
  before_action :require_login
  before_action :find_question, only: [:show]
  
  def index
    @questions = current_user.questions
  end
  
  def show
  end
  
  def create
    @section = current_user.sections.find(params[:section_id])
    @question = Question.new(question_params)
    @question.user = current_user
    
    if @question.save
      @section.questions << @question
      redirect_to @section, notice: 'Question created successfully'
    else
      redirect_to @section, alert: 'Error creating question'
    end
  end
  
  private
  
  def find_question
    @question = current_user.questions.find(params[:id])
  end
  
  def question_params
    params.require(:question).permit(:name)
  end
end

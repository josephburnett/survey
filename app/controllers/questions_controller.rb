class QuestionsController < ApplicationController
  before_action :require_login
  
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
  
  def question_params
    params.require(:question).permit(:name)
  end
end

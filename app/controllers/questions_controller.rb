class QuestionsController < ApplicationController
  before_action :require_login
  before_action :find_question, only: [:show, :edit, :update, :soft_delete]
  
  def index
    @questions = current_user.questions.not_deleted
  end
  
  def show
  end
  
  def new
    @question = Question.new
  end
  
  def edit
  end
  
  def update
    if @question.update(question_params)
      redirect_to @question, notice: 'Question updated successfully'
    else
      render :edit
    end
  end
  
  def soft_delete
    @question.soft_delete!
    redirect_to questions_path, notice: 'Question deleted successfully'
  end
  
  def create
    if params[:section_id]
      # Creating question from section
      @section = current_user.sections.find(params[:section_id])
      @question = Question.new(question_params)
      @question.user = current_user
      
      if @question.save
        @section.questions << @question
        redirect_to @section, notice: 'Question created successfully'
      else
        redirect_to @section, alert: 'Error creating question'
      end
    else
      # Standalone question creation
      @question = current_user.questions.build(question_params)
      
      if @question.save
        redirect_to @question, notice: 'Question created successfully'
      else
        render :new
      end
    end
  end
  
  private
  
  def find_question
    @question = current_user.questions.not_deleted.find(params[:id])
  end
  
  def question_params
    params.require(:question).permit(:name, :question_type, :range_min, :range_max)
  end
end

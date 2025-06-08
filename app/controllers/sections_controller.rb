class SectionsController < ApplicationController
  before_action :require_login
  before_action :find_section, only: [:show, :edit, :update, :soft_delete, :survey, :submit_survey]
  
  def index
    @sections = current_user.sections.not_deleted
  end
  
  def show
    @question = Question.new
    @available_questions = current_user.questions.not_deleted - @section.questions
  end
  
  def new
    @section = Section.new
  end
  
  def create
    @section = current_user.sections.build(section_params)
    
    if @section.save
      redirect_to @section, notice: 'Section created successfully'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @section.update(section_params)
      redirect_to @section, notice: 'Section updated successfully'
    else
      render :edit
    end
  end
  
  def soft_delete
    @section.soft_delete!
    redirect_to sections_path, notice: 'Section deleted successfully'
  end
  
  def survey
    @response = Response.new
  end
  
  def submit_survey
    @response = Response.new(section: @section, user: current_user)
    
    if @response.save
      # Process answers for each question
      params[:answers]&.each do |question_id, answer_data|
        question = @section.questions.find(question_id)
        answer = @response.answers.build(
          question: question,
          user: current_user,
          answer_type: question.question_type
        )
        
        case question.question_type
        when 'string'
          answer.string_value = answer_data[:value]
        when 'number'
          answer.number_value = answer_data[:value].to_f
        when 'bool'
          answer.bool_value = answer_data[:value] == '1'
        when 'range'
          answer.number_value = answer_data[:value].to_f
        end
        
        answer.save
      end
      
      redirect_to @section, notice: 'Survey submitted successfully'
    else
      render :survey, alert: 'Error submitting survey'
    end
  end
  
  def add_question
    @section = current_user.sections.find(params[:id])
    @question = current_user.questions.find(params[:question_id])
    
    unless @section.questions.include?(@question)
      @section.questions << @question
      redirect_to @section, notice: 'Question added to section successfully'
    else
      redirect_to @section, alert: 'Question is already in this section'
    end
  end
  
  private
  
  def find_section
    @section = current_user.sections.not_deleted.find(params[:id])
  end
  
  def section_params
    params.require(:section).permit(:name, :prompt)
  end
end

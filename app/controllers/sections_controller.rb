class SectionsController < ApplicationController
  before_action :require_login
  before_action :find_section, only: [:show, :survey, :submit_survey]
  
  def index
    @sections = current_user.sections
  end
  
  def show
    @question = Question.new
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
  
  private
  
  def find_section
    @section = current_user.sections.find(params[:id])
  end
end

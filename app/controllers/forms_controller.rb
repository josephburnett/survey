class FormsController < ApplicationController
  before_action :require_login
  before_action :find_form, only: [:show, :edit, :update, :soft_delete, :survey, :submit_survey]
  
  def index
    @forms = current_user.forms.not_deleted
  end
  
  def show
    @section = Section.new
    @available_sections = current_user.sections.not_deleted - @form.sections
  end
  
  def new
    @form = Form.new
  end
  
  def create
    @form = current_user.forms.build(form_params)
    
    if @form.save
      redirect_to @form, notice: 'Form created successfully'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @form.update(form_params)
      redirect_to @form, notice: 'Form updated successfully'
    else
      render :edit
    end
  end
  
  def soft_delete
    @form.soft_delete!
    redirect_to forms_path, notice: 'Form deleted successfully'
  end
  
  def survey
    @response = Response.new
  end
  
  def submit_survey
    @response = Response.new(form: @form, user: current_user)
    
    if @response.save
      # Process answers for each question across all sections
      params[:answers]&.each do |question_id, answer_data|
        question = Question.find(question_id)
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
      
      redirect_to @form, notice: 'Form submitted successfully'
    else
      render :survey, alert: 'Error submitting form'
    end
  end
  
  def add_section
    @form = current_user.forms.find(params[:id])
    @section = current_user.sections.find(params[:section_id])
    
    unless @form.sections.include?(@section)
      @form.sections << @section
      redirect_to @form, notice: 'Section added to form successfully'
    else
      redirect_to @form, alert: 'Section is already in this form'
    end
  end
  
  private
  
  def find_form
    @form = current_user.forms.not_deleted.find(params[:id])
  end
  
  def form_params
    params.require(:form).permit(:name)
  end
end
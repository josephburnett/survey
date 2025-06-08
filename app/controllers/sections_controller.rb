class SectionsController < ApplicationController
  before_action :require_login
  
  def index
    @sections = current_user.sections
  end
end

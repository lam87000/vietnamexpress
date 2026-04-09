class Admin::BaseController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'
  
  private
  
  def authenticate_admin!
    unless current_user&.admin?
      redirect_to admin_login_path, alert: 'Accès non autorisé'
    end
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  helper_method :current_user
end
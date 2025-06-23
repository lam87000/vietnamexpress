class Admin::SessionsController < ApplicationController
  layout 'application'
  
  def new
    redirect_to admin_root_path if current_user&.admin?
  end
  
  def create
    user = User.find_by(email: params[:email])
    
    if user&.authenticate(params[:password]) && user.admin?
      session[:user_id] = user.id
      redirect_to admin_root_path, notice: 'Connexion réussie'
    else
      flash.now[:alert] = 'Email ou mot de passe incorrect'
      render :new, status: :unprocessable_entity
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Déconnexion réussie'
  end
  
  private
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  helper_method :current_user
end
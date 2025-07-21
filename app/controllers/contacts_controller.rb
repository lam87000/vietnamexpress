class ContactsController < ApplicationController
  def create
    @contact_params = contact_params
    
    # Validation simple
    if @contact_params[:name].blank? || @contact_params[:email].blank? || @contact_params[:message].blank?
      redirect_to root_path, alert: "Veuillez remplir tous les champs obligatoires (nom, email, message)."
      return
    end
    
    # Validation format email
    unless @contact_params[:email].match?(URI::MailTo::EMAIL_REGEXP)
      redirect_to root_path, alert: "Veuillez saisir une adresse email valide."
      return
    end
    
    begin
      # Envoi de l'email
      ContactMailer.notification(@contact_params).deliver_now
      
      redirect_to root_path, notice: "Votre message a bien été envoyé. Nous vous répondrons dans les plus brefs délais."
    rescue => e
      Rails.logger.error "Erreur envoi email contact: #{e.message}"
      redirect_to root_path, alert: "Une erreur s'est produite lors de l'envoi de votre message. Veuillez réessayer."
    end
  end
  
  private
  
  def contact_params
    params.permit(:name, :email, :phone, :date, :message)
  end
end
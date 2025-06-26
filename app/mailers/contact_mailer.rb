class ContactMailer < ApplicationMailer
  def notification(contact_params)
    @name = contact_params[:name]
    @email = contact_params[:email]
    @phone = contact_params[:phone]
    @date = contact_params[:date]
    @message = contact_params[:message]
    
    # Email de destination : toujours votre Gmail (celui configuré dans les variables)
    recipient_email = ENV['GMAIL_USERNAME']
    
    mail(
      to: recipient_email,
      subject: "Nouveau message de contact - Vietnam Express",
      reply_to: @email
    )
  end
end
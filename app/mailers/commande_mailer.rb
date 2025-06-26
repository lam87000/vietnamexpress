class CommandeMailer < ApplicationMailer
  def confirmation(commande)
    @commande = commande
    @order_items = @commande.order_items.includes(:plat)
    
    mail(
      to: @commande.client_email,
      subject: "Confirmation de votre commande ##{@commande.id} - Vietnam Express"
    )
  end
end
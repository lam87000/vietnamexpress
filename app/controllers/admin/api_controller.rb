class Admin::ApiController < Admin::BaseController
  # Endpoint pour vérifier s'il y a de nouvelles commandes
  def new_orders
    # Compter les commandes en attente créées dans les 30 dernières secondes
    new_orders_count = Commande.today
                              .where(statut: 'en_attente')
                              .where('created_at > ?', 30.seconds.ago)
                              .count

    # Obtenir la dernière commande pour les détails
    latest_order = nil
    if new_orders_count > 0
      latest_order = Commande.today
                            .where(statut: 'en_attente')
                            .order(created_at: :desc)
                            .first
    end

    render json: {
      has_new_orders: new_orders_count > 0,
      count: new_orders_count,
      latest_order: latest_order ? {
        id: latest_order.id,
        client_nom: latest_order.client_nom,
        created_at: latest_order.created_at.strftime('%H:%M'),
        montant_total: latest_order.montant_total
      } : nil
    }
  end
end
class Admin::DashboardController < Admin::BaseController
  def index
    # Statistiques du jour
    @stats = {
      today_orders_count: Commande.today.count,
      today_revenue: Commande.today.sum(:montant_total) || 0,
      pending_count: Commande.today.by_status('en_attente').count,
      low_stock_plats: Plat.where('stock_quantity <= 5').count
    }
    
    # Commandes du jour par statut - triées par heure de retrait (plus urgent en premier)
    @today_orders = Commande.today.includes(:order_items, :plats)
    @pending_orders = @today_orders.select { |c| c.statut == 'en_attente' }.sort_by { |c| Time.parse(c.heure_retrait.to_s) }
    @confirmed_orders = @today_orders.select { |c| c.statut == 'confirmee' }.sort_by { |c| Time.parse(c.heure_retrait.to_s) }
    @ready_orders = @today_orders.select { |c| c.statut == 'prete' }.sort_by { |c| Time.parse(c.heure_retrait.to_s) }
    
    # Compter les nouvelles commandes en attente (créées dans les 5 dernières minutes)
    @new_pending_count = Commande.today.where(statut: 'en_attente').where('created_at > ?', 5.minutes.ago).count
  end
end
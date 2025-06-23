class Admin::DashboardController < Admin::BaseController
  def index
    @today_orders = Commande.today.includes(:order_items, :plats).order(created_at: :desc)
    @pending_orders = @today_orders.by_status('en_attente')
    @confirmed_orders = @today_orders.by_status('confirmee')
    @ready_orders = @today_orders.by_status('prete')
    
    @stats = {
      today_orders_count: @today_orders.count,
      today_revenue: @today_orders.sum(:montant_total),
      pending_count: @pending_orders.count,
      low_stock_plats: Plat.where('stock_quantity <= 5').count
    }
  end
end
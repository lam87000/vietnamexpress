#controller permettant de gérer le controle des commandes (fin/start) de la partie admin. Fontionnne avec la route toggle_orders_settings dans le fichier routes.rb

class Admin::SettingsController < Admin::BaseController
    def toggle_orders
      duration = params[:duration].to_i.minutes
  
      if restaurant_accepting_orders?
        # Si les commandes sont activées, on les désactive pour la durée choisie
        if duration > 0
          set_orders_disabled_until(Time.current + duration)
          flash[:notice] = "Les commandes ont été suspendues pour #{params[:duration]} minutes."
        else
          flash[:alert] = "Veuillez choisir une durée valide."
        end
      else
        # Si les commandes sont désactivées, on les réactive immédiatement
        set_orders_disabled_until(nil) # On efface la clé du cache
        flash[:notice] = "Les commandes sont de nouveau acceptées."
      end
      
      redirect_to admin_root_path
    end
  end
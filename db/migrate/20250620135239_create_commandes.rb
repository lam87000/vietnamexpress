class CreateCommandes < ActiveRecord::Migration[7.1]
  def change
    create_table :commandes do |t|
      t.date :jour_commande, null: false
      t.time :heure_retrait, null: false
      t.decimal :montant_total, precision: 8, scale: 2, null: false
      t.string :client_nom, null: false
      t.string :client_telephone, null: false
      t.string :client_email, null: false
      t.text :notes
      t.string :statut, default: 'en_attente'

      t.timestamps
    end
    
    add_index :commandes, :jour_commande
    add_index :commandes, :statut
    add_index :commandes, :client_email
  end
end

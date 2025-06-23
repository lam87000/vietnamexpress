class CreateOrderItems < ActiveRecord::Migration[7.1]
  def change
    create_table :order_items do |t|
      t.references :commande, null: false, foreign_key: true
      t.references :plat, null: false, foreign_key: true
      t.integer :quantite, null: false
      t.decimal :prix_unitaire, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end

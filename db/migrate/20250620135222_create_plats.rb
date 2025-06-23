class CreatePlats < ActiveRecord::Migration[7.1]
  def change
    create_table :plats do |t|
      t.string :nom, null: false
      t.decimal :prix, precision: 8, scale: 2, null: false
      t.string :image_url
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.integer :stock_quantity, default: 0
      t.boolean :available, default: true

      t.timestamps
    end
    
    add_index :plats, :nom
    add_index :plats, :available
  end
end

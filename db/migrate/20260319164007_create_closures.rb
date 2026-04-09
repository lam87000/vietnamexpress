class CreateClosures < ActiveRecord::Migration[7.1]
  def change
    create_table :closures do |t|
      t.date :start_on, null: false
      t.date :end_on, null: false
      t.string :reason

      t.timestamps
    end
  end
end

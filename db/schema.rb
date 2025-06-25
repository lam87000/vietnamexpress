# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_25_055953) do
  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "display_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "commandes", force: :cascade do |t|
    t.date "jour_commande", null: false
    t.time "heure_retrait", null: false
    t.decimal "montant_total", precision: 8, scale: 2, null: false
    t.string "client_nom", null: false
    t.string "client_telephone", null: false
    t.string "client_email", null: false
    t.text "notes"
    t.string "statut", default: "en_attente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_email"], name: "index_commandes_on_client_email"
    t.index ["jour_commande"], name: "index_commandes_on_jour_commande"
    t.index ["statut"], name: "index_commandes_on_statut"
  end

  create_table "order_items", force: :cascade do |t|
    t.integer "commande_id", null: false
    t.integer "plat_id", null: false
    t.integer "quantite", null: false
    t.decimal "prix_unitaire", precision: 8, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commande_id"], name: "index_order_items_on_commande_id"
    t.index ["plat_id"], name: "index_order_items_on_plat_id"
  end

  create_table "plats", force: :cascade do |t|
    t.string "nom", null: false
    t.decimal "prix", precision: 8, scale: 2, null: false
    t.string "image_url"
    t.text "description"
    t.integer "category_id", null: false
    t.integer "stock_quantity", default: 0
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_plats_on_available"
    t.index ["category_id"], name: "index_plats_on_category_id"
    t.index ["nom"], name: "index_plats_on_nom"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role", default: "user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "order_items", "commandes"
  add_foreign_key "order_items", "plats"
  add_foreign_key "plats", "categories"
end

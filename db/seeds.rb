# db/seeds.rb
# Ce fichier est SÛR pour la production. Il ne contient que les données
# indispensables au premier lancement du site.

puts "🌱 Création des données de base..."

# --- 1. Création du compte Administrateur ---
# En production, le mot de passe doit être une variable d'environnement sécurisée.
admin_email = "admin@vietnamexpress.fr"
admin_password = Rails.env.production? ? ENV['ADMIN_INITIAL_PASSWORD'] : "admin123"

# Sécurité : On bloque le seed en production si le mot de passe n'est pas défini.
if Rails.env.production? && admin_password.blank?
  abort("❌ ERREUR: La variable d'environnement ADMIN_INITIAL_PASSWORD doit être définie en production.")
end

admin = User.find_or_initialize_by(email: admin_email)
if admin.new_record?
  admin.password = admin_password
  admin.role = 'admin' # On s'assure qu'il est bien admin
  admin.save!
  puts "✅ Compte administrateur créé pour '#{admin.email}'."
else
  puts "ℹ️  Le compte administrateur '#{admin.email}' existe déjà."
end


# --- 2. Création des Catégories de plats ---
# Ce sont les seules données de menu nécessaires au départ.
categories_data = [
  { id: 1, name: "Entrées" },
  { id: 2, name: "Plats" },
  { id: 3, name: "Garnitures" },
  { id: 4, name: "Plats en soupe" },
  { id: 5, name: "Desserts" } # J'ai vu "Dessert" dans votre code, je l'ai mis au pluriel "Desserts"
]

puts "\n- Création ou mise à jour des catégories..."
categories_data.each do |cat_data|
  Category.find_or_create_by!(id: cat_data[:id]) do |c|
    c.name = cat_data[:name]
  end
end
puts "✅ Catégories créées."


puts "\n🎉 Seeds de base terminés. L'application est prête à être utilisée."
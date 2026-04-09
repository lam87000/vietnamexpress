# db/seeds.rb
# Version Robuste pour la Production AVEC MESSAGES DE DEBUG

puts "🌱 [DEBUG] Début du script de seeds."

# --- 1. Mise à jour forcée du compte Administrateur ---
admin_email = "admin@vietnamexpress.fr"
puts "🌱 [DEBUG] Email admin à traiter: #{admin_email}"

admin_password = ENV['ADMIN_INITIAL_PASSWORD']

if Rails.env.production?
  if admin_password.present?
    puts "🌱 [DEBUG] Variable ADMIN_INITIAL_PASSWORD trouvée."
  else
    abort("❌ ERREUR: La variable d'environnement ADMIN_INITIAL_PASSWORD est ABSENTE ou VIDE en production.")
  end
end

# ÉTAPE 1 : On trouve l'utilisateur existant OU on en prépare un nouveau en mémoire.
# Rien n'est sauvegardé en base de données à ce stade.
admin = User.find_or_initialize_by(email: admin_email)

if admin.new_record?
  puts "🌱 [DEBUG] L'utilisateur '#{admin_email}' n'existait pas. Préparation pour création."
else
  puts "🌱 [DEBUG] L'utilisateur '#{admin_email}' existe déjà. Préparation pour mise à jour."
end

# ÉTAPE 2 : On FORCE les attributs. Que l'utilisateur soit nouveau ou ancien,
# on lui assigne le bon mot de passe et le statut admin.
admin.password = admin_password
admin.admin = true # <- On force le statut admin à 'true'

# ÉTAPE 3 : On sauvegarde.
# Si l'utilisateur était nouveau, il est créé.
# S'il existait, il est mis à jour avec les attributs ci-dessus.
if admin.save
  puts "✅ [DEBUG] Sauvegarde de l'admin réussie."
  puts "✅ [DEBUG] Attributs finaux: email=#{admin.email}, est admin?=#{admin.admin?}"
else
  # Si la sauvegarde échoue, on affiche les erreurs pour comprendre pourquoi.
  puts "❌ ERREUR: Impossible de sauvegarder l'administrateur : #{admin.errors.full_messages.to_sentence}"
  abort # On arrête tout le processus de déploiement en cas d'erreur ici.
end


# --- 2. Création des Catégories de plats ---
# (Cette partie ne change pas)
puts "\n- Création/Mise à jour des catégories..."
categories_data = [
  { id: 1, name: "Entrées" },
  { id: 2, name: "Plats" },
  { id: 3, name: "Garnitures" },
  { id: 4, name: "Plats en soupe" },
  { id: 5, name: "Desserts" }
]
categories_data.each do |cat_data|
  Category.find_or_create_by!(id: cat_data[:id]) do |c|
    c.name = cat_data[:name]
  end
end
puts "✅ Catégories synchronisées."


puts "\n🎉 [DEBUG] Seeds de base terminés."
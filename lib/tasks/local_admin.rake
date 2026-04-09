# Task pour créer un utilisateur admin LOCAL uniquement
# Usage : rails local_admin:create
# IMPORTANT : Ne fonctionne QUE en environnement development

namespace :local_admin do
  desc "Créer un utilisateur admin pour les tests locaux (development uniquement)"
  task create: :environment do
    # SÉCURITÉ : Bloquer complètement en production
    if Rails.env.production?
      puts "❌ ERREUR : Cette task ne peut pas être exécutée en production !"
      puts "❌ Accès bloqué pour des raisons de sécurité."
      exit 1
    end

    # Vérifier l'environnement development
    unless Rails.env.development?
      puts "❌ Cette task ne fonctionne qu'en environnement development"
      puts "❌ Environnement actuel : #{Rails.env}"
      exit 1
    end

    puts "🏠 Création d'un utilisateur admin LOCAL pour tests..."
    puts "📍 Environnement : #{Rails.env}"

    # Données admin de test
    admin_email = "admin.test@restaurant-local.dev"
    admin_password = "test123456"

    # Vérifier si l'admin existe déjà
    existing_admin = User.find_by(email: admin_email)

    if existing_admin
      puts "✅ Admin de test existe déjà !"
      puts "📧 Email : #{admin_email}"
      puts "🔑 Mot de passe : #{admin_password}"
      puts "🔗 URL : http://localhost:3000/admin/login"
      return
    end

    # Créer l'utilisateur admin de test
    begin
      admin_user = User.create!(
        email: admin_email,
        password: admin_password,
        password_confirmation: admin_password,
        admin: true
      )

      puts "✅ Utilisateur admin de test créé avec succès !"
      puts ""
      puts "📊 INFORMATIONS DE CONNEXION (LOCAL UNIQUEMENT) :"
      puts "🌐 URL : http://localhost:3000/admin/login"
      puts "📧 Email : #{admin_email}"
      puts "🔑 Mot de passe : #{admin_password}"
      puts ""
      puts "⚠️  RAPPEL : Cet admin n'existe QUE en local/development"
      puts "🚫 Il ne sera JAMAIS déployé en production"

    rescue ActiveRecord::RecordInvalid => e
      puts "❌ Erreur lors de la création de l'admin :"
      puts e.message
    end
  end

  desc "Supprimer l'utilisateur admin de test local"
  task destroy: :environment do
    # SÉCURITÉ : Bloquer complètement en production
    if Rails.env.production?
      puts "❌ ERREUR : Cette task ne peut pas être exécutée en production !"
      exit 1
    end

    unless Rails.env.development?
      puts "❌ Cette task ne fonctionne qu'en environnement development"
      exit 1
    end

    admin_email = "admin.test@restaurant-local.dev"
    admin_user = User.find_by(email: admin_email)

    if admin_user
      admin_user.destroy!
      puts "🗑️  Admin de test supprimé avec succès"
    else
      puts "ℹ️  Aucun admin de test à supprimer"
    end
  end

  desc "Afficher les informations de l'admin de test"
  task info: :environment do
    if Rails.env.production?
      puts "❌ Cette task ne fonctionne pas en production"
      exit 1
    end

    admin_email = "admin.test@restaurant-local.dev"
    admin_user = User.find_by(email: admin_email)

    if admin_user
      puts "✅ Admin de test disponible :"
      puts "🌐 URL : http://localhost:3000/admin/login"
      puts "📧 Email : #{admin_email}"
      puts "🔑 Mot de passe : test123456"
    else
      puts "❌ Aucun admin de test. Lancez : rails local_admin:create"
    end
  end
end
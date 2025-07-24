# config/sitemap.rb
# Ce fichier définit le plan du site pour les moteurs de recherche.

# --- ÉTAPE 1 : Définir l'URL officielle de votre site ---
# C'est l'étape la plus importante. On utilise votre nom de domaine.
SitemapGenerator::Sitemap.default_host = "https://vietnamexpress.fr"

SitemapGenerator::Sitemap.create do
  # Instructions pour la génération :
  # La priorité va de 0.0 (peu important) à 1.0 (très important).
  # 'changefreq' indique à Google à quelle fréquence la page est susceptible de changer.

  # --- Pages Principales ---

  # Page d'accueil : la plus importante de toutes.
  add '/', priority: 1.0, changefreq: 'weekly'

  # Page "Notre Carte" (liste de tous les plats).
  add '/plats', priority: 0.9, changefreq: 'weekly'

  # Page pour "Commander" en ligne.
  add '/commandes/new', priority: 0.9, changefreq: 'monthly'

  # La section "Contact" est sur la page d'accueil, donc déjà incluse.

  # --- Pages de Détail (générées automatiquement) ---

  # Ajoute une URL pour chaque catégorie de plats.
  Category.find_each do |category|
    # Exemple d'URL générée : https://vietnamexpress.fr/categories/1
    add category_path(category), lastmod: category.updated_at, priority: 0.7
  end

  # Ajoute une URL pour chaque plat disponible à la vente.
  Plat.available.find_each do |plat|
    # Exemple d'URL générée : https://vietnamexpress.fr/plats/1
    add plat_path(plat), lastmod: plat.updated_at, priority: 0.8
  end
end
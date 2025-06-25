# Seeds pour Restaurant Limoges - Version simple pour Render
puts "🌱 Création des données de base..."

# Créer l'utilisateur admin
admin = User.find_or_create_by!(email: "admin@vietnamexpress.fr") do |u|
  u.password = "admin123"
  u.role = "admin"
end
puts "✅ Admin créé"

# Créer les catégories
categories_data = [
  { id: 1, name: "Entrées" },
  { id: 2, name: "Plats" },
  { id: 3, name: "Garnitures" },
  { id: 4, name: "Plats en soupe" },
  { id: 5, name: "Dessert" }
]

categories_data.each do |cat_data|
  Category.find_or_create_by!(id: cat_data[:id]) do |c|
    c.name = cat_data[:name]
  end
end
puts "✅ Catégories créées"

# Créer les plats
plats_data = [
  # Entrées
  { nom: "Nems croustillants (2 pièces)", description: "Rouleaux de printemps frits garnis de légumes et viande", prix: 4.50, category_id: 1, image_path: "nems-croustillants-restaurant-vietnamien-limoges.jpg" },
  { nom: "Rouleaux de printemps (2 pièces)", description: "Rouleaux frais aux crevettes et légumes", prix: 5.50, category_id: 1, image_path: "rouleaux-printemps-restaurant-vietnamien-limoges.jpg" },
  { nom: "Salade vietnamienne", description: "Salade fraîche aux herbes et légumes croquants", prix: 6.50, category_id: 1, image_path: "salade-vietnamienne-fraiche-limoges.jpg" },
  { nom: "Beignets de crevettes (4 pièces)", description: "Crevettes enrobées dans une pâte croustillante", prix: 7.50, category_id: 1, image_path: "beignets-crevettes-restaurant-asiatique-limoges.jpg" },
  { nom: "Crevettes aigre-douce", description: "Crevettes sautées dans une sauce aigre-douce", prix: 8.50, category_id: 1, image_path: "crevettes-aigre-douce-asiatique-limoges.jpg" },
  { nom: "Crêpe vietnamienne", description: "Crêpe croustillante garnie de crevettes et pousses de soja", prix: 9.50, category_id: 1, image_path: "crepe-vietnamienne-restaurant-limoges.jpg" },
  { nom: "Bánh hỏi", description: "Vermicelles de riz servis avec herbes fraîches", prix: 10.50, category_id: 1, image_path: "banh-hoi-chinois-limoges.jpeg" },
  { nom: "Assortiment d'entrées", description: "Sélection de nos meilleures entrées", prix: 12.50, category_id: 1, image_path: "restaurant-chinois-limoges.jpg" },

  # Plats
  { nom: "Bo bun", description: "Vermicelles de riz au bœuf grillé et légumes", prix: 11.50, category_id: 2, image_path: "bo-bun-vermicelles-boeuf-limoges.jpg" },
  { nom: "Porc au caramel", description: "Porc mijoté dans une sauce caramel vietnamienne", prix: 12.50, category_id: 2, image_path: "porc-caramel-restaurant-limoges.jpg" },
  { nom: "Poulet grillé vietnamien", description: "Poulet mariné et grillé aux épices vietnamiennes", prix: 13.50, category_id: 2, image_path: "Poulet-grille-vietnamien-limoges.jpg" },
  { nom: "Canard laqué", description: "Canard rôti à la sauce soja et aux cinq épices", prix: 15.50, category_id: 2, image_path: "canard-limoges-restaurant-asiatique.jpg" },
  { nom: "Crevettes sautées", description: "Crevettes sautées aux légumes et gingembre", prix: 14.50, category_id: 2, image_path: "crevettes-limoges-centre-ville.jpg" },
  { nom: "Poulet aux champignons", description: "Poulet sauté aux champignons noirs et sauce soja", prix: 12.50, category_id: 2, image_path: "poulet-champignons-chinois-limoges.webp" },
  { nom: "Nouilles sautées", description: "Nouilles sautées aux légumes et viande au choix", prix: 11.50, category_id: 2, image_path: "nouilles-sautees-restaurant-chinois-limoges.jpg" },
  { nom: "Mì xào", description: "Nouilles sautées vietnamiennes aux fruits de mer", prix: 13.50, category_id: 2, image_path: "mi-xao-limoges-japonais.jpg" },

  # Garnitures
  { nom: "Riz blanc", description: "Riz jasmin parfumé", prix: 3.00, category_id: 3 },
  { nom: "Riz sauté", description: "Riz sauté aux légumes et œuf", prix: 4.50, category_id: 3 },
  { nom: "Légumes sautés", description: "Mélange de légumes sautés", prix: 5.50, category_id: 3 },

  # Plats en soupe
  { nom: "Hoành thánh mì", description: "Soupe de raviolis aux crevettes et nouilles", prix: 9.50, category_id: 4, image_path: "hoanh-thanh-mi-restaurant-vietnamien-limoges.jpg" },
  { nom: "Hủ tiếu - soupe Saïgonnaise", description: "Soupe de nouilles de riz aux fruits de mer", prix: 10.50, category_id: 4, image_path: "soupe-nouilles-porc-crevette-saigonnaise-limoges.jpg" },
  { nom: "Phở Bò", description: "Soupe traditionnelle vietnamienne au bœuf", prix: 11.50, category_id: 4 },

  # Desserts
  { nom: "Perles de coco", description: "Dessert traditionnel aux perles de tapioca", prix: 4.50, category_id: 5 },
  { nom: "Flan coco", description: "Flan onctueux au lait de coco", prix: 5.00, category_id: 5 },
  { nom: "Banane flambée", description: "Banane caramélisée au rhum", prix: 6.50, category_id: 5 },
  { nom: "Litchis au sirop", description: "Litchis frais au sirop parfumé", prix: 4.50, category_id: 5 },
  { nom: "Salade de fruits exotiques", description: "Mélange de fruits tropicaux frais", prix: 5.50, category_id: 5 }
]

plats_data.each do |plat_data|
  Plat.find_or_create_by!(nom: plat_data[:nom]) do |p|
    p.description = plat_data[:description]
    p.prix = plat_data[:prix]
    p.category_id = plat_data[:category_id]
    p.image_path = plat_data[:image_path]
  end
end
puts "✅ Plats créés"

puts "�� Seeds terminés !"

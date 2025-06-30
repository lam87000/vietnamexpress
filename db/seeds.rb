# Seeds pour Restaurant Limoges - Version simple pour Render
puts "🌱 Création des données de base..."

# Créer l'utilisateur admin (forcer la mise à jour)
admin = User.find_or_initialize_by(email: "admin@vietnamexpress.fr")
admin.password = "admin123"
admin.admin = true
admin.save!
puts "✅ Admin créé: #{admin.email} - Admin: #{admin.admin?}"

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
  { nom: "Nems Maison (pièce)", description: "Porc ou poulet, vermicelle, carotte, champignon noir, ail et fines herbes", prix: 1.20, category_id: 1, image_url: "nems-croustillants-restaurant-vietnamien-limoges.jpg" },
  { nom: "Rouleaux de printemps (pièces)", description: "Galette de riz, salade, soja en pousse, crevettes, nouilles de riz", prix: 2.00, category_id: 1, image_url: "rouleaux-printemps-restaurant-vietnamien-limoges.jpg" },
  { nom: "Salade vietnamienne", description: "Carotte, choux blancs, vinaigre, crevettes", prix: 4.00, category_id: 1, image_url: "salade-vietnamienne-fraiche-limoges.jpg" },
  { nom: "Beignets de crevettes", description: "Farine de blé, crevette", prix: 1.00, category_id: 1, image_url: "beignets-crevettes-restaurant-asiatique-limoges.jpg" },
  { nom: "Crêpe vietnamienne", description: "Farine de riz, lait, soja jeune pousse, crevette, poulet, sauce poisson", prix: 4.00, category_id: 1, image_url: "crepe-vietnamienne-restaurant-limoges.jpg" },
  { nom: "Miến Gà", description: "Potage de vermicelles au poulet", prix: 4.00, category_id: 1, image_url: "banh-hoi-chinois-limoges.jpeg" },
  { nom: "Samossa au boeuf", description: "Galette de blé, carotte, peti pois, boeuf", prix: 1.00, category_id: 1, image_url: "restaurant-chinois-limoges.jpg" },
  { nom: "Raiolis frits aux crevettes", description: "Galette de blé, crevette, porc", prix: 1.00, category_id: 1, image_url: "restaurant-chinois-limoges.jpg" },

  # Plats
  { nom: "Poule au gingembre", description: "Tendres morceaux de poulet émincés et sautés, délicatement parfumés par la fraîcheur vivifiante du gingembre", prix: 10.00, category_id: 2, image_url: "banh-xeo-vietnamien-limoges.jpg" }, 
  { nom: "Bo bun", description: "Vermicelles, bœuf, salade, carottes et cacahuètes", prix: 10.00, category_id: 2, image_url: "bo-bun-vermicelles-boeuf-limoges.jpg" }, 
  { nom: "Porc au caramel au poivre", description: "Porc mijoté dans une sauce caramel vietnamienne", prix: 10.00, category_id: 2, image_url: "porc-caramel-restaurant-limoges.jpg" }, 
  { nom: "Cuisse de poulet grillée", description: "Poulet mariné et grillé aux épices vietnamiennes", prix: 10.00, category_id: 2, image_url: "Poulet-grille-vietnamien-limoges.jpg" }, 
  { nom: "Magret laqué", description: "Magret rôti à la sauce soja et aux cinq épices", prix: 11.00, category_id: 2, image_url: "canard-limoges-restaurant-asiatique.jpg" }, 
  { nom: "Crevettes au 3 champignons", description: "Crevettes sautées", prix: 10.00, category_id: 2, image_url: "crevettes-limoges-centre-ville.jpg" }, 
  { nom: "Crevettes aigre-douce", description: "Crevettes sautées dans une sauce aigre-douce", prix: 10.00, category_id: 1, image_url: "crevettes-aigre-douce-asiatique-limoges.jpg" }, 
  { nom: "Poulet acurry et pate jaune", description: "Poulet au curry", prix: 10.00, category_id: 2, image_url: "poulet-champignons-chinois-limoges.webp" }, 
  { nom: "Mì xào", description: "Assiette de nouilles sautées aux légumes", prix: 5,50, category_id: 2, image_url: "mi-xao-limoges-japonais.jpg" },
  { nom: "Mì xào", description: "Assiette de nouilles sautées légumes crevettes ou boeuf", prix: 10.00, category_id: 2, image_url: "mi-xao-limoges-japonais.jpg" }, x
  { nom: "Mì xào giòn", description: "Assiette de nouilles croustillantes, légumes, crevettes ou boeuf", prix: 11.00, category_id: 2, image_url: "mi-xao-limoges-japonais.jpg" }, 
  { nom: "Bánh hỏi", description: "Assiette de vermicelles, traverser de porc laqué", prix: 10.00, category_id: 2, image_url: "banh-xeo-vietnamien-limoges.jpg" }, 
  { nom: "bò lúc lắc", description: "Assiette de boeuf sauté, riz et légumes", prix: 11.00, category_id: 2, image_url: "banh-xeo-vietnamien-limoges.jpg" }, 
  { nom: "Poulet au trois champignons", description: "Poulet et ses champignons", prix: 10.00, category_id: 2, image_url: "poulet-champignons-chinois-limoges.webp" },


  # Garnitures
  { nom: "Riz blanc", description: "Riz jasmin parfumé", prix: 4.00, category_id: 3 },
  { nom: "Riz tonkinois", description: "Riz sauté aux légumes et œuf", prix: 4.00, category_id: 3 },
  { nom: "Salade vietnamienne aux crevettes", description: "Carotte, choux blancs, vinaigre, crevettes", prix: 4.00, category_id: 3 },
  { nom: "Nouilles sautées aux légumes", description: "Nouilles sautées aux légumes et viande au choix", prix: 5.50, category_id: 3, image_url: "nouilles-sautees-restaurant-chinois-limoges.jpg" },

  # Plats en soupe
  { nom: "Hoành thánh mì", description: "Soupe de raviolis aux crevettes, porc et nouilles de blé", prix: 10.00, category_id: 4, image_url: "hoanh-thanh-mi-restaurant-vietnamien-limoges.jpg" },
  { nom: "Hủ tiếu - soupe Saïgonnaise", description: "Soupe de nouilles de riz, porc et crevettes", prix: 10.00, category_id: 4, image_url: "soupe-nouilles-porc-crevette-saigonnaise-limoges.jpg" },
  { nom: "Phở Bò", description: "Nouilles de riz au boeuf", prix: 10.00, category_id: 4, image_url: "soupe-nouilles-porc-crevette-saigonnaise-limoges.jpg" },

  # Desserts
  { nom: "Perles de coco", description: "Dessert traditionnel aux perles de tapioca", prix: 1.50, category_id: 5 },
  { nom: "Glace (vanille, fraise...)", description: "Boule au choix", prix: 1.50, category_id: 5 },
  { nom: "Beignet banane (ou pomme / ananas)", description: "beignet frit", prix: 1.50, category_id: 5 },
  { nom: "Ché Chuôi vietnamien", description: "Banane, lait coco, tapioca", prix: 2.50, category_id: 5 },
  { nom: "Coup de fruit", description: "assortiment de fruits", prix: 2.50, category_id: 5 }
]

plats_data.each do |plat_data|
  Plat.find_or_create_by!(nom: plat_data[:nom]) do |p|
    p.description = plat_data[:description]
    p.prix = plat_data[:prix]
    p.category_id = plat_data[:category_id]
    p.image_url = plat_data[:image_url]
    p.stock_quantity = 100  # Quantité en stock pour rendre les plats disponibles
  end
end
puts "✅ Plats créés"

puts "�� Seeds terminés !"

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Création des catégories vietnamiennes
puts "Création des catégories..."

categories_data = [
  { 
    name: "Entrées", 
    description: "Nos délicieuses entrées pour commencer votre repas",
    display_order: 1 
  },
  { 
    name: "Soupes", 
    description: "Nos soupes traditionnelles vietnamiennes", 
    display_order: 2 
  },
  { 
    name: "Plats principaux", 
    description: "Nos spécialités vietnamiennes authentiques", 
    display_order: 3 
  },
  { 
    name: "Nouilles et Riz", 
    description: "Plats à base de nouilles et riz parfumé", 
    display_order: 4 
  },
  { 
    name: "Desserts", 
    description: "Pour finir en beauté votre repas", 
    display_order: 5 
  },
  { 
    name: "Boissons", 
    description: "Thés, jus et boissons traditionnelles", 
    display_order: 6 
  }
]

categories_data.each do |cat_data|
  Category.find_or_create_by(name: cat_data[:name]) do |cat|
    cat.description = cat_data[:description]
    cat.display_order = cat_data[:display_order]
  end
end

puts "#{Category.count} catégories créées."

# Création des plats vietnamiens
puts "Création des plats..."

plats_data = [
  # Entrées
  {
    nom: "Nems au porc",
    prix: 6.50,
    description: "Rouleaux de printemps frits, farcis au porc haché, légumes et vermicelles, servis avec sauce nuoc-mam",
    category: "Entrées",
    stock_quantity: 25,
    image_url: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500"
  },
  {
    nom: "Rouleaux de printemps aux crevettes",
    prix: 7.00,
    description: "Rouleaux frais avec crevettes, salade, menthe fraîche et vermicelles de riz, sauce cacahuète",
    category: "Entrées",
    stock_quantity: 20,
    image_url: "https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=500"
  },
  {
    nom: "Salade de papaye verte",
    prix: 5.50,
    description: "Salade rafraîchissante de papaye verte râpée, tomates cerises, cacahuètes et herbes fraîches",
    category: "Entrées",
    stock_quantity: 15,
    image_url: "https://images.unsplash.com/photo-1551248429-40975aa4de74?w=500"
  },
  
  # Soupes
  {
    nom: "Pho Bo (soupe de bœuf)",
    prix: 12.50,
    description: "Soupe traditionnelle avec bouillon parfumé, nouilles de riz, lamelles de bœuf, oignons et herbes fraîches",
    category: "Soupes",
    stock_quantity: 30,
    image_url: "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=500"
  },
  {
    nom: "Pho Ga (soupe de poulet)",
    prix: 11.50,
    description: "Bouillon de poulet aromatique avec nouilles de riz, blanc de poulet effiloché et condiments frais",
    category: "Soupes",
    stock_quantity: 25,
    image_url: "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500"
  },
  {
    nom: "Soupe Tom Yum aux crevettes",
    prix: 10.50,
    description: "Soupe épicée et acidulée avec crevettes, champignons, citronnelle et feuilles de lime",
    category: "Soupes",
    stock_quantity: 20,
    image_url: "https://images.unsplash.com/photo-1604152135912-04a022e23696?w=500"
  },
  
  # Plats principaux
  {
    nom: "Bœuf sauté au lemongrass",
    prix: 16.50,
    description: "Lamelles de bœuf marinées et sautées à la citronnelle, servies avec riz parfumé",
    category: "Plats principaux",
    stock_quantity: 20,
    image_url: "https://images.unsplash.com/photo-1563379091213-c44d19d6fa44?w=500"
  },
  {
    nom: "Poulet au curry rouge",
    prix: 15.00,
    description: "Morceaux de poulet mijotés dans un curry rouge crémeux avec légumes de saison",
    category: "Plats principaux",
    stock_quantity: 18,
    image_url: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500"
  },
  {
    nom: "Porc caramélisé au gingembre",
    prix: 14.50,
    description: "Porc mijoté dans une sauce caramélisée au gingembre et sauce soja, accompagné de riz",
    category: "Plats principaux",
    stock_quantity: 22,
    image_url: "https://images.unsplash.com/photo-1512003867696-6d5ce6835040?w=500"
  },
  
  # Nouilles et Riz
  {
    nom: "Bun Bo Hue",
    prix: 13.50,
    description: "Nouilles de riz épaisses dans un bouillon épicé avec bœuf, porc et herbes aromatiques",
    category: "Nouilles et Riz",
    stock_quantity: 15,
    image_url: "https://images.unsplash.com/photo-1617096200347-cb04f5de4c3d?w=500"
  },
  {
    nom: "Pad Thai aux crevettes",
    prix: 14.00,
    description: "Nouilles de riz sautées avec crevettes, œuf, pousses de soja et cacahuètes grillées",
    category: "Nouilles et Riz",
    stock_quantity: 20,
    image_url: "https://images.unsplash.com/photo-1559314809-0f31657def5e?w=500"
  },
  {
    nom: "Riz sauté aux légumes",
    prix: 11.00,
    description: "Riz jasmin sauté avec mélange de légumes frais, œuf et sauce soja",
    category: "Nouilles et Riz",
    stock_quantity: 25,
    image_url: "https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500"
  },
  
  # Desserts
  {
    nom: "Che ba mau (dessert aux trois couleurs)",
    prix: 4.50,
    description: "Dessert traditionnel avec haricots rouges, gelée verte et lait de coco",
    category: "Desserts",
    stock_quantity: 12,
    image_url: "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=500"
  },
  {
    nom: "Perles de tapioca au lait de coco",
    prix: 4.00,
    description: "Perles de tapioca dans un lait de coco sucré et parfumé à la vanille",
    category: "Desserts",
    stock_quantity: 15,
    image_url: "https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=500"
  },
  
  # Boissons
  {
    nom: "Thé glacé au jasmin",
    prix: 3.50,
    description: "Thé vert au jasmin servi glacé avec une pointe de miel",
    category: "Boissons",
    stock_quantity: 30,
    image_url: "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500"
  },
  {
    nom: "Café vietnamien glacé",
    prix: 4.00,
    description: "Café fort vietnamien avec lait concentré sucré, servi sur glace",
    category: "Boissons",
    stock_quantity: 25,
    image_url: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500"
  },
  {
    nom: "Jus de fruit du dragon",
    prix: 3.50,
    description: "Jus frais de pitaya, rafraîchissant et riche en vitamines",
    category: "Boissons",
    stock_quantity: 20,
    image_url: "https://images.unsplash.com/photo-1557050543-4d5f4e07ef46?w=500"
  }
]

plats_data.each do |plat_data|
  category = Category.find_by(name: plat_data[:category])
  if category
    Plat.find_or_create_by(nom: plat_data[:nom]) do |plat|
      plat.prix = plat_data[:prix]
      plat.description = plat_data[:description]
      plat.category = category
      plat.stock_quantity = plat_data[:stock_quantity]
      plat.image_url = plat_data[:image_url]
      plat.available = true
    end
  else
    puts "Catégorie '#{plat_data[:category]}' non trouvée pour le plat '#{plat_data[:nom]}'"
  end
end

puts "#{Plat.count} plats créés."
puts "Base de données alimentée avec succès !"
puts ""
puts "=== RÉSUMÉ ==="
puts "Catégories: #{Category.count}"
puts "Plats disponibles: #{Plat.available.count}"
puts "Stock total: #{Plat.sum(:stock_quantity)} articles"

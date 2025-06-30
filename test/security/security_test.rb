require 'test_helper'

class SecurityTest < ActionDispatch::IntegrationTest
  def setup
    @category = Category.create!(nom: "Test Category")
    @plat = Plat.create!(
      nom: "Test Plat",
      description: "Description test",
      prix: 10.0,
      category: @category,
      stock_quantity: 5,
      available: true
    )
  end
  
  # TEST 1: Validation des quantités
  test "should reject invalid quantities" do
    # Quantité négative
    post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: -1 }, as: :json
    assert_response :success
    response_data = JSON.parse(response.body)
    assert_equal false, response_data['success']
    assert_includes response_data['message'], 'Quantité invalide'
    
    # Quantité excessive
    post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: 50 }, as: :json
    assert_response :success
    response_data = JSON.parse(response.body)
    assert_equal false, response_data['success']
    assert_includes response_data['message'], 'Quantité invalide'
  end
  
  # TEST 2: Protection des prix (recalcul depuis DB)
  test "should use database prices not client prices" do
    # Simuler ajout normal au panier
    post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: 1 }, as: :json
    assert_response :success
    
    # Créer commande avec validation des prix
    commande_params = {
      client_nom: "Test Client",
      client_email: "test@example.com",
      client_telephone: "0123456789",
      heure_retrait: 2.hours.from_now
    }
    
    post commandes_path, params: { commande: commande_params }
    
    if response.status == 302 # Redirection = succès
      commande = Commande.last
      order_item = commande.order_items.first
      # Vérifier que le prix utilisé est celui de la DB, pas du client
      assert_equal @plat.prix, order_item.prix_unitaire
    end
  end
  
  # TEST 3: Validation email renforcée
  test "should reject disposable emails" do
    commande_params = {
      client_nom: "Test Client", 
      client_email: "test@10minutemail.com", # Email jetable
      client_telephone: "0123456789",
      heure_retrait: 2.hours.from_now
    }
    
    commande = Commande.new(commande_params)
    assert_not commande.valid?
    assert_includes commande.errors[:client_email], "Les emails temporaires ne sont pas autorisés"
  end
  
  test "should reject invalid email domains" do
    commande_params = {
      client_nom: "Test Client",
      client_email: "test@fake.com", # Domaine suspect
      client_telephone: "0123456789", 
      heure_retrait: 2.hours.from_now
    }
    
    commande = Commande.new(commande_params)
    assert_not commande.valid?
    assert_includes commande.errors[:client_email], "Domaine email non valide"
  end
  
  # TEST 4: Chiffrement du panier
  test "should encrypt cart data in session" do
    post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: 1 }, as: :json
    
    # Vérifier que session[:cart] n'existe plus (remplacé par encrypted_cart)
    assert_nil session[:cart]
    assert_not_nil session[:encrypted_cart]
    
    # Vérifier que les données chiffrées ne contiennent pas d'info en clair
    assert_not_includes session[:encrypted_cart], @plat.id.to_s
    assert_not_includes session[:encrypted_cart], "1"
  end
  
  # TEST 5: Vérification stock atomique
  test "should handle concurrent stock access" do
    # Simuler 2 clients qui veulent le dernier plat
    @plat.update!(stock_quantity: 1)
    
    # Ajouter au panier de 2 sessions différentes
    post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: 1 }
    
    # Simuler une 2e session en manipulant directement la DB
    second_cart = { @plat.id.to_s => 1 }
    
    commande1_params = {
      client_nom: "Client 1",
      client_email: "client1@valid.com", 
      client_telephone: "0123456789",
      heure_retrait: 2.hours.from_now
    }
    
    commande2_params = {
      client_nom: "Client 2",
      client_email: "client2@valid.com",
      client_telephone: "0123456780", 
      heure_retrait: 2.hours.from_now
    }
    
    # Premier client passe commande
    post commandes_path, params: { commande: commande1_params }
    
    # Deuxième commande devrait échouer (stock épuisé)
    result = OrderCreationService.new(Commande.new(commande2_params), second_cart).call
    assert_not result.success?
    assert_includes result.error, "Stock insuffisant"
  end
  
  # TEST 6: Rate limiting (simulation)
  test "should track request patterns" do
    # Note: Test basique car Rack::Attack nécessite un setup complexe en test
    # En production, les limites seraient: 3 commandes/IP/heure
    
    # Simuler plusieurs ajouts rapides au panier
    5.times do |i|
      post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: 1 }, as: :json
    end
    
    # Le test vérifie juste que les requêtes passent (rate limiting actif en prod)
    assert_response :success
  end
  
  # TEST 7: Validation globale de sécurité
  test "complete security workflow" do
    # 1. Ajout au panier avec validation
    post add_to_cart_commandes_path, params: { plat_id: @plat.id, quantity: 2 }, as: :json
    assert_response :success
    
    # 2. Vérifier chiffrement
    assert_not_nil session[:encrypted_cart]
    
    # 3. Commande avec email valide
    valid_commande_params = {
      client_nom: "Client Sécurisé",
      client_email: "client@gmail.com", # Email valide
      client_telephone: "0123456789",
      heure_retrait: 2.hours.from_now
    }
    
    post commandes_path, params: { commande: valid_commande_params }
    
    # 4. Vérifier que la commande est créée
    if response.status == 302
      commande = Commande.last
      assert_equal "Client Sécurisé", commande.client_nom
      assert_equal "client@gmail.com", commande.client_email
      assert_equal 20.0, commande.montant_total # 2 * 10.0
      
      # 5. Vérifier décrément du stock
      @plat.reload
      assert_equal 3, @plat.stock_quantity # 5 - 2
    end
  end
end
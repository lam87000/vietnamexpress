document.addEventListener('DOMContentLoaded', function() {
  // Gestion des formulaires d'ajout au panier
  bindAddToCartForms();
  
  // Gestion des boutons de suppression
  bindRemoveButtons();
});

function bindAddToCartForms() {
  const forms = document.querySelectorAll('.add-to-cart-form');
  
  forms.forEach(form => {
    form.addEventListener('submit', handleAddToCart);
  });
}

function bindRemoveButtons() {
  const removeButtons = document.querySelectorAll('.btn-danger[href*="remove_from_cart"]');
  
  removeButtons.forEach(button => {
    button.addEventListener('click', function(e) {
      e.preventDefault();
      const platId = this.getAttribute('href').match(/plat_id=(\d+)/)?.[1];
      if (platId) {
        removeFromCart(platId);
      }
    });
  });
}

function handleAddToCart(event) {
  event.preventDefault();
  
  const form = event.target;
  const formData = new FormData(form);
  const submitBtn = form.querySelector('[type="submit"]');
  const originalText = submitBtn.textContent;
  
  submitBtn.disabled = true;
  submitBtn.textContent = 'Ajout...';
  
  fetch(form.action, {
    method: 'POST',
    body: formData,
    headers: {
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    }
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      updateCartDisplay(data);
      showMessage(data.message, 'success');
    } else {
      showMessage(data.message, 'error');
    }
  })
  .catch(error => {
    console.error('Erreur AJAX:', error);
    showMessage('Erreur lors de l\'ajout au panier', 'error');
  })
  .finally(() => {
    submitBtn.disabled = false;
    submitBtn.textContent = originalText;
  });
}

function removeFromCart(platId) {
  if (!confirm('Êtes-vous sûr de vouloir retirer ce plat du panier ?')) {
    return;
  }
  
  fetch('/commandes/remove_from_cart', {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json',
      'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
    },
    body: JSON.stringify({ plat_id: platId })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      updateCartDisplay(data);
      showMessage(data.message || 'Plat retiré du panier', 'success');
    } else {
      showMessage(data.message || 'Erreur lors de la suppression', 'error');
    }
  })
  .catch(error => {
    console.error('Erreur AJAX:', error);
    showMessage('Erreur lors de la suppression', 'error');
  });
}

function updateCartDisplay(data) {
  // Mettre à jour le compteur dans la navbar
  const cartCount = document.querySelector('.cart-count');
  if (cartCount) {
    cartCount.textContent = data.cart_count;
    const cartIndicator = cartCount.closest('.nav-item');
    if (cartIndicator) {
      cartIndicator.style.display = data.cart_count > 0 ? 'block' : 'none';
    }
  }
  
  // Remplacer le contenu du panier avec le HTML reçu
  const cartSection = document.querySelector('.cart-section');
  if (cartSection && data.cart_html) {
    cartSection.innerHTML = data.cart_html;
    
    // Re-binder les événements pour les nouveaux boutons
    bindRemoveButtons();
  }
  
  // Animation du panier pour feedback visuel
  animateCartIcon();
}

function animateCartIcon() {
  const cartIcon = document.querySelector('.fa-shopping-cart');
  if (cartIcon) {
    cartIcon.style.transform = 'scale(1.2)';
    cartIcon.style.transition = 'transform 0.2s ease';
    setTimeout(() => {
      cartIcon.style.transform = 'scale(1)';
    }, 200);
  }
}

function showMessage(message, type) {
  const messageDiv = document.createElement('div');
  messageDiv.className = `alert alert-${type === 'success' ? 'success' : 'danger'}`;
  messageDiv.textContent = message;
  messageDiv.style.cssText = `
    position: fixed; 
    top: 20px; 
    right: 20px; 
    z-index: 1050;
    min-width: 300px; 
    padding: 15px;
    border-radius: 4px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  `;
  
  document.body.appendChild(messageDiv);
  setTimeout(() => messageDiv.remove(), 3000);
}

// Fonction globale pour la suppression (pour compatibilité)
window.removeFromCart = removeFromCart;

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "cartSection"]

  connect() {
    this.bindAddToCartForms()
  }

  bindAddToCartForms() {
    const forms = document.querySelectorAll('.add-to-cart-form')
    
    forms.forEach(form => {
      form.addEventListener('submit', this.handleAddToCart.bind(this))
    })
  }

  handleAddToCart(event) {
    event.preventDefault()
    
    const form = event.target
    const formData = new FormData(form)
    const submitBtn = form.querySelector('[type="submit"]')
    const originalText = submitBtn.textContent
    
    submitBtn.disabled = true
    submitBtn.textContent = 'Ajout...'
    
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
        this.updateCartDisplayWithHTML(data)
        this.showMessage(data.message, 'success')
      } else {
        this.showMessage(data.message, 'error')
      }
    })
    .catch(error => {
      this.showMessage('Erreur lors de l\'ajout au panier', 'error')
    })
    .finally(() => {
      submitBtn.disabled = false
      submitBtn.textContent = originalText
    })
  }

  removeFromCart(platId) {
    if (!confirm('Êtes-vous sûr de vouloir retirer ce plat du panier ?')) {
      return
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
        this.updateCartDisplay(data)
        this.showMessage(data.message || 'Plat retiré du panier', 'success')
      } else {
        this.showMessage(data.message || 'Erreur lors de la suppression', 'error')
      }
    })
    .catch(error => {
      this.showMessage('Erreur lors de la suppression', 'error')
    })
  }

  updateCartDisplayWithHTML(data) {
    // Mettre à jour le compteur dans la navbar
    const cartCount = document.querySelector('.cart-count')
    if (cartCount) {
      cartCount.textContent = data.cart_count
      // Afficher/masquer l'indicateur selon le nombre d'articles
      const cartIndicator = cartCount.closest('.nav-item')
      if (cartIndicator) {
        cartIndicator.style.display = data.cart_count > 0 ? 'block' : 'none'
      }
    }
    
    // Remplacer le contenu du panier avec le HTML reçu
    const cartSection = document.getElementById('cart-section')
    if (cartSection && data.cart_html) {
      cartSection.outerHTML = data.cart_html
    }
    
    // Animation du panier pour feedback visuel
    this.animateCartIcon()
    
    // Scroll automatique vers le panier après ajout
    setTimeout(() => {
      const newCartSection = document.getElementById('cart-section')
      if (newCartSection) {
        newCartSection.scrollIntoView({ 
          behavior: 'smooth', 
          block: 'start' 
        })
      }
    }, 300)
  }

  updateCartDisplay(data) {
    // Mettre à jour le compteur dans la navbar
    const cartCount = document.querySelector('.cart-count')
    if (cartCount) {
      cartCount.textContent = data.cart_count
      const cartIndicator = cartCount.closest('.nav-item')
      if (cartIndicator) {
        cartIndicator.style.display = data.cart_count > 0 ? 'block' : 'none'
      }
    }
    
    // Remplacer le contenu du panier avec le HTML reçu
    const cartSection = document.getElementById('cart-section')
    if (cartSection && data.cart_html) {
      cartSection.innerHTML = data.cart_html
    }
    
    // Animation du panier pour feedback visuel
    this.animateCartIcon()
  }

  animateCartIcon() {
    const cartIcon = document.querySelector('.fa-shopping-cart')
    if (cartIcon) {
      cartIcon.style.transform = 'scale(1.2)'
      cartIcon.style.transition = 'transform 0.2s ease'
      setTimeout(() => {
        cartIcon.style.transform = 'scale(1)'
      }, 200)
    }
  }

  showMessage(message, type) {
    const messageDiv = document.createElement('div')
    messageDiv.className = `alert alert-${type === 'success' ? 'success' : 'danger'}`
    messageDiv.textContent = message
    messageDiv.style.cssText = `
      position: fixed; 
      top: 20px; 
      right: 20px; 
      z-index: 1050;
      min-width: 300px; 
      padding: 15px;
      border-radius: 4px;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    `
    
    document.body.appendChild(messageDiv)
    setTimeout(() => messageDiv.remove(), 3000)
  }
}

// Global function for cart removal (for existing cart buttons)
window.removeFromCart = function(platId) {
  const cartController = document.querySelector('[data-controller*="cart"]')
  if (cartController && cartController.application) {
    const controller = cartController.application.getControllerForElementAndIdentifier(cartController, "cart")
    if (controller) {
      controller.removeFromCart(platId)
    }
  }
}
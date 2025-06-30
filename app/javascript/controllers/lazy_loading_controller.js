import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.initializeLazyLoading()
  }
  
  initializeLazyLoading() {
    const images = document.querySelectorAll('img[data-src]')
    
    if ('IntersectionObserver' in window) {
      const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const img = entry.target
            img.src = img.dataset.src
            img.classList.remove('lazy')
            observer.unobserve(img)
          }
        })
      })
      
      images.forEach(img => imageObserver.observe(img))
    } else {
      // Fallback for older browsers
      images.forEach(img => {
        img.src = img.dataset.src
        img.classList.remove('lazy')
      })
    }
  }
}
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["navbar", "scrollBtn"]
  
  connect() {
    this.initializeScroll()
    this.initializeScrollToTop()
    this.initializeSmoothScrolling()
  }
  
  initializeScroll() {
    if (this.hasNavbarTarget) {
      window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
          this.navbarTarget.classList.add('navbar-scrolled')
        } else {
          this.navbarTarget.classList.remove('navbar-scrolled')
        }
      })
    }
  }
  
  initializeScrollToTop() {
    if (this.hasScrollBtnTarget) {
      window.addEventListener('scroll', () => {
        if (window.scrollY > 300) {
          this.scrollBtnTarget.style.display = 'block'
        } else {
          this.scrollBtnTarget.style.display = 'none'
        }
      })
    }
  }
  
  initializeSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', (e) => {
        e.preventDefault()
        const target = document.querySelector(anchor.getAttribute('href'))
        if (target) {
          target.scrollIntoView({ behavior: 'smooth', block: 'start' })
        }
      })
    })
  }
  
  scrollToTop() {
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
  
  scrollToCart(event) {
    event.preventDefault()
    const cartSection = document.getElementById('cart-section')
    if (cartSection) {
      cartSection.scrollIntoView({ behavior: 'smooth', block: 'start' })
    } else {
      window.location.href = '/commandes/new#cart-section'
    }
  }
}
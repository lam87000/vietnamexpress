import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tabButton", "tabPanel"]

  connect() {
    console.log('Dashboard controller connected')
    this.activateDefaultTab()
    this.startAutoRefresh()
  }

  switchTab(event) {
    const clickedButton = event.currentTarget
    const status = clickedButton.dataset.status
    
    // Update active tab button
    this.tabButtonTargets.forEach(btn => btn.classList.remove('active'))
    clickedButton.classList.add('active')
    
    // Update active tab panel
    this.tabPanelTargets.forEach(panel => panel.classList.remove('active'))
    const targetPanel = document.getElementById(status + '-orders')
    if (targetPanel) {
      targetPanel.classList.add('active')
    }
  }

  activateDefaultTab() {
    // Activer l'onglet "Confirmées" par défaut
    const confirmedTab = this.element.querySelector('[data-status="confirmed"]')
    const confirmedPanel = document.getElementById('confirmed-orders')
    
    if (confirmedTab && confirmedPanel) {
      // Désactiver tous les onglets
      this.tabButtonTargets.forEach(btn => btn.classList.remove('active'))
      this.tabPanelTargets.forEach(panel => panel.classList.remove('active'))
      
      // Activer l'onglet confirmées
      confirmedTab.classList.add('active')
      confirmedPanel.classList.add('active')
    }
  }

  startAutoRefresh() {
    // Actualisation automatique toutes les 60 secondes
    console.log('Auto-refresh activé - Dashboard admin')
    
    setInterval(() => {
      console.log('Rechargement automatique du dashboard...')
      window.location.reload()
    }, 60000)
  }
}
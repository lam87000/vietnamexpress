// Système de notifications pour l'admin
class AdminNotifications {
  constructor() {
    this.audio = null;
    this.serviceWorker = null;
    this.lastOrderTime = 0;
    this.isSetup = false;

    this.init();
  }

  async init() {
    try {
      // Initialiser le son
      this.setupAudio();

      // Enregistrer le Service Worker
      await this.registerServiceWorker();

      // Demander les permissions
      await this.requestPermissions();

      // Démarrer la surveillance
      this.startOrderMonitoring();

      this.isSetup = true;
      console.log('✅ Système de notifications activé');
    } catch (error) {
      console.error('❌ Erreur initialisation notifications:', error);
    }
  }

  setupAudio() {
    // Créer un son simple pour les nouvelles commandes
    this.audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+D2v2kcBD2H0fPQgTEGHm7A7+OZURE');
    this.audio.volume = 0.8;
  }

  async registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      this.serviceWorker = await navigator.serviceWorker.register('/sw.js');

      // Écouter les messages du Service Worker
      navigator.serviceWorker.addEventListener('message', (event) => {
        if (event.data.type === 'NEW_ORDER_NOTIFICATION') {
          this.handleNewOrderNotification(event.data.data);
        }
      });
    }
  }

  async requestPermissions() {
    // Demander permission pour les notifications
    if ('Notification' in window) {
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        console.warn('Permissions notifications refusées');
      }
    }

    // Interaction utilisateur pour débloquer l'audio
    document.addEventListener('click', () => {
      if (this.audio && this.audio.paused) {
        this.audio.play().then(() => {
          this.audio.pause();
          this.audio.currentTime = 0;
        }).catch(() => {});
      }
    }, { once: true });
  }

  startOrderMonitoring() {
    // Vérifier les nouvelles commandes toutes les 30 secondes
    setInterval(() => {
      this.checkNewOrders();
    }, 30000);

    // Vérification immédiate
    this.checkNewOrders();
  }

  async checkNewOrders() {
    try {
      const response = await fetch('/admin/api/new_orders', {
        credentials: 'include'
      });

      if (response.ok) {
        const data = await response.json();

        if (data.has_new_orders) {
          this.handleNewOrderNotification(data);
        }
      }
    } catch (error) {
      console.error('Erreur vérification commandes:', error);
    }
  }

  handleNewOrderNotification(data) {
    if (!data.latest_order) return;

    // Éviter les doublons
    const orderTime = new Date(data.latest_order.created_at).getTime();
    if (orderTime <= this.lastOrderTime) return;

    this.lastOrderTime = orderTime;

    // Jouer le son
    this.playNotificationSound();

    // Afficher notification visuelle sur la page
    this.showPageNotification(data.latest_order);

    // Animation du badge s'il existe
    this.animateBadge();
  }

  playNotificationSound() {
    if (this.audio) {
      this.playBeepSequence(4, 200);
    }
  }

  async playBeepSequence(count, intervalMs) {
    for (let i = 0; i < count; i++) {
      try {
        this.audio.currentTime = 0;
        await this.audio.play();

        // Attendre que le bip se termine
        await new Promise(resolve => {
          setTimeout(resolve, 300);
        });

        this.audio.pause();

        // Pause entre les bips (sauf pour le dernier)
        if (i < count - 1) {
          await new Promise(resolve => {
            setTimeout(resolve, intervalMs);
          });
        }
      } catch (error) {
        console.log('Audio bloqué par le navigateur');
        break;
      }
    }
  }

  showPageNotification(order) {
    // Créer une notification en haut de page
    const notification = document.createElement('div');
    notification.className = 'admin-notification-banner';
    notification.innerHTML = `
      <div class="notification-content">
        <span class="notification-icon">🔔</span>
        <div class="notification-text">
          <strong>Nouvelle commande !</strong><br>
          Commande #${order.id} de ${order.client_nom}
        </div>
        <button class="notification-close" onclick="this.parentElement.parentElement.remove()">×</button>
      </div>
    `;

    // Insérer en haut de la page admin
    const adminMain = document.querySelector('.admin-main');
    if (adminMain) {
      adminMain.insertBefore(notification, adminMain.firstChild);

      // Supprimer automatiquement après 10 secondes
      setTimeout(() => {
        if (notification.parentNode) {
          notification.remove();
        }
      }, 10000);
    }
  }

  animateBadge() {
    // Animer le badge rouge des commandes en attente s'il existe
    const badge = document.querySelector('.pending-badge');
    if (badge) {
      badge.style.animation = 'pulse 1s ease-in-out 3';
    }
  }
}

// Initialiser le système uniquement sur les pages admin
if (window.location.pathname.includes('/admin')) {
  document.addEventListener('DOMContentLoaded', () => {
    window.adminNotifications = new AdminNotifications();
  });
}
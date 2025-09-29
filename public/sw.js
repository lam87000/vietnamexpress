// Service Worker pour notifications nouvelles commandes
const CACHE_NAME = 'restaurant-notifications-v1';
let lastOrderCheck = 0;

// Installation du Service Worker
self.addEventListener('install', event => {
  console.log('Service Worker installé');
  self.skipWaiting();
});

// Activation du Service Worker
self.addEventListener('activate', event => {
  console.log('Service Worker activé');
  event.waitUntil(self.clients.claim());
});

// Écouter les messages du client
self.addEventListener('message', event => {
  if (event.data && event.data.type === 'CHECK_NEW_ORDERS') {
    checkNewOrders();
  }
});

// Fonction pour vérifier les nouvelles commandes
async function checkNewOrders() {
  try {
    const response = await fetch('/admin/api/new_orders', {
      credentials: 'include'
    });

    if (response.ok) {
      const data = await response.json();

      if (data.has_new_orders && data.latest_order) {
        // Envoyer notification push
        await self.registration.showNotification('Vietnam Express - Nouvelle commande !', {
          body: `Commande #${data.latest_order.id} de ${data.latest_order.client_nom}`,
          icon: '/favicon-32x32.png',
          badge: '/favicon-16x16.png',
          tag: 'new-order',
          requireInteraction: true,
          data: {
            orderId: data.latest_order.id,
            url: '/admin/commandes'
          }
        });

        // Notifier la page admin si elle est ouverte
        const clients = await self.clients.matchAll();
        clients.forEach(client => {
          client.postMessage({
            type: 'NEW_ORDER_NOTIFICATION',
            data: data
          });
        });
      }
    }
  } catch (error) {
    console.error('Erreur lors de la vérification des commandes:', error);
  }
}

// Gérer les clics sur les notifications
self.addEventListener('notificationclick', event => {
  event.notification.close();

  const url = event.notification.data.url || '/admin';

  event.waitUntil(
    self.clients.matchAll().then(clients => {
      // Vérifier si une fenêtre admin est déjà ouverte
      const adminClient = clients.find(client =>
        client.url.includes('/admin')
      );

      if (adminClient) {
        // Focuser sur la fenêtre existante
        return adminClient.focus();
      } else {
        // Ouvrir une nouvelle fenêtre
        return self.clients.openWindow(url);
      }
    })
  );
});

// Polling automatique toutes les 30 secondes
setInterval(() => {
  checkNewOrders();
}, 30000);
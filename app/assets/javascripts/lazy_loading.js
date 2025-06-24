// Lazy Loading Intelligent pour les images de plats
class SmartLazyLoader {
  constructor() {
    this.imageCache = new Map();
    this.observer = null;
    this.isEnabled = true;
    this.loadedImages = new Set();
    
    this.init();
  }

  init() {
    // Vérifier le support d'Intersection Observer
    if ('IntersectionObserver' in window) {
      this.setupIntersectionObserver();
    } else {
      // Fallback pour navigateurs anciens
      this.loadAllImages();
      return;
    }

    // Pré-charger les images critiques (Entrées)
    this.preloadCriticalImages();
    
    // Setup des événements
    this.setupEventListeners();
    
    console.log('🚀 Smart Lazy Loader initialisé');
  }

  setupIntersectionObserver() {
    const options = {
      root: null,
      rootMargin: '100px', // Charger 100px avant d'être visible
      threshold: 0.1
    };

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadImage(entry.target);
          this.observer.unobserve(entry.target);
        }
      });
    }, options);

    // Observer toutes les images lazy
    document.querySelectorAll('img[data-src]').forEach(img => {
      this.observer.observe(img);
    });
  }

  preloadCriticalImages() {
    // Charger immédiatement les images de la section Entrées
    const criticalImages = document.querySelectorAll('.category-entrees img[data-src]');
    
    console.log(`🔥 Pré-chargement de ${criticalImages.length} images critiques`);
    
    criticalImages.forEach(img => {
      this.loadImage(img, true);
    });
  }

  loadImage(imgElement, isCritical = false) {
    const src = imgElement.dataset.src;
    
    if (!src || this.loadedImages.has(src)) return;
    
    // Marquer comme en cours de chargement
    imgElement.classList.add('loading');
    
    // Créer une nouvelle image pour le pré-chargement
    const newImg = new Image();
    
    newImg.onload = () => {
      // Image chargée avec succès
      imgElement.src = src;
      imgElement.classList.remove('loading');
      imgElement.classList.add('loaded');
      
      // Ajouter au cache
      this.imageCache.set(src, newImg.src);
      this.loadedImages.add(src);
      
      // Animation de fondu
      this.animateImageIn(imgElement);
      
      if (isCritical) {
        console.log(`✅ Image critique chargée: ${src.split('/').pop()}`);
      }
    };
    
    newImg.onerror = () => {
      // Erreur de chargement
      imgElement.classList.remove('loading');
      imgElement.classList.add('error');
      imgElement.src = '/assets/placeholder-plat.jpg'; // Image par défaut
      
      console.warn(`❌ Erreur chargement: ${src}`);
    };
    
    // Démarrer le chargement
    newImg.src = src;
  }

  animateImageIn(imgElement) {
    // Animation smooth d'apparition
    imgElement.style.opacity = '0';
    imgElement.style.transform = 'scale(0.95)';
    
    requestAnimationFrame(() => {
      imgElement.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
      imgElement.style.opacity = '1';
      imgElement.style.transform = 'scale(1)';
    });
  }

  setupEventListeners() {
    // Pré-charger la section suivante au hover des onglets
    document.querySelectorAll('.category-tab').forEach(tab => {
      tab.addEventListener('mouseenter', () => {
        const category = tab.dataset.category;
        this.preloadCategoryImages(category);
      });
    });

    // Pré-charger au scroll vers le bas
    let ticking = false;
    window.addEventListener('scroll', () => {
      if (!ticking) {
        requestAnimationFrame(() => {
          this.handleScroll();
          ticking = false;
        });
        ticking = true;
      }
    });
  }

  preloadCategoryImages(category) {
    const categoryImages = document.querySelectorAll(`.category-${category} img[data-src]`);
    
    if (categoryImages.length > 0) {
      console.log(`🔮 Pré-chargement section ${category}: ${categoryImages.length} images`);
      
      categoryImages.forEach(img => {
        if (!this.loadedImages.has(img.dataset.src)) {
          setTimeout(() => this.loadImage(img), Math.random() * 1000);
        }
      });
    }
  }

  handleScroll() {
    // Si on scroll rapidement vers le bas, pré-charger plus agressivement
    const scrollPercent = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
    
    if (scrollPercent > 30) {
      // Charger toutes les images restantes après 30% de scroll
      this.loadRemainingImages();
    }
  }

  loadRemainingImages() {
    const remainingImages = document.querySelectorAll('img[data-src]:not(.loaded):not(.loading)');
    
    if (remainingImages.length > 0) {
      console.log(`🚀 Chargement des ${remainingImages.length} images restantes`);
      
      remainingImages.forEach((img, index) => {
        setTimeout(() => this.loadImage(img), index * 200);
      });
    }
  }

  loadAllImages() {
    // Fallback : charger toutes les images immédiatement
    console.log('📦 Fallback: chargement de toutes les images');
    
    document.querySelectorAll('img[data-src]').forEach(img => {
      this.loadImage(img);
    });
  }

  // Méthodes publiques pour contrôle externe
  disable() {
    this.isEnabled = false;
    if (this.observer) {
      this.observer.disconnect();
    }
  }

  enable() {
    this.isEnabled = true;
    this.init();
  }

  getStats() {
    return {
      totalImages: document.querySelectorAll('img[data-src]').length,
      loadedImages: this.loadedImages.size,
      cachedImages: this.imageCache.size
    };
  }
}

// CSS pour les transitions et états
const lazyLoadingCSS = `
  img[data-src] {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
    min-height: 200px;
  }
  
  img.loading {
    opacity: 0.7;
  }
  
  img.loaded {
    animation: none;
    background: none;
  }
  
  img.error {
    background: #f8f8f8;
    border: 2px dashed #ddd;
  }
  
  @keyframes shimmer {
    0% { background-position: -200% 0; }
    100% { background-position: 200% 0; }
  }
`;

// Injecter le CSS
const style = document.createElement('style');
style.textContent = lazyLoadingCSS;
document.head.appendChild(style);

// Initialiser quand le DOM est prêt
document.addEventListener('DOMContentLoaded', () => {
  window.smartLazyLoader = new SmartLazyLoader();
  
  // Debug en développement
  if (window.location.hostname === 'localhost') {
    setTimeout(() => {
      console.log('📊 Lazy Loading Stats:', window.smartLazyLoader.getStats());
    }, 5000);
  }
});
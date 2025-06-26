# Guide de déploiement Render

## Variables d'environnement à configurer sur Render

### Variables obligatoires :
- `DATABASE_URL` : Automatiquement configurée par Render PostgreSQL
- `SECRET_KEY_BASE` : Généré automatiquement par le render.yaml
- `RAILS_ENV` : production
- `RAILS_SERVE_STATIC_FILES` : true
- `RAILS_LOG_TO_STDOUT` : true

### Variables pour l'email (optionnelles) :
- `GMAIL_USERNAME` : Votre adresse Gmail pour l'envoi d'emails
- `GMAIL_PASSWORD` : Votre mot de passe d'application Gmail

## Étapes de déploiement

1. **Créer un nouveau service Web sur Render** :
   - Connecter votre repository GitHub
   - Utiliser le fichier `render.yaml` fourni

2. **Créer une base de données PostgreSQL** :
   - Nom : `restaurant-limoges-db`
   - La connexion sera automatiquement configurée

3. **Configurer les variables d'environnement** :
   - Les variables principales sont définies dans le render.yaml
   - Ajouter manuellement GMAIL_USERNAME et GMAIL_PASSWORD si nécessaire

4. **Déployer** :
   - Le déploiement se fera automatiquement via le render.yaml
   - Les migrations et seeds s'exécuteront automatiquement

## Corrections apportées

✅ **PostgreSQL configuré** pour la production
✅ **Initializer corrigé** pour éviter les erreurs au démarrage
✅ **Variables d'environnement sécurisées**
✅ **Configuration de production optimisée** pour Render
✅ **Serveur de fichiers statiques activé**
✅ **Compilation d'assets activée** en production

## Commandes de déploiement

```bash
# Build automatique sur Render :
bundle install
bundle exec rails assets:precompile
bundle exec rails db:migrate

# Démarrage automatique :
bundle exec rails server -p $PORT -e production
```

Le site devrait maintenant se déployer correctement sur Render sans erreurs d'initialisation.
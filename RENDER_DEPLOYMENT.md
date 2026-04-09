# Guide de déploiement Render

## Configuration manuelle sur Render (sans render.yaml)

### 1. Créer un service Web
- Repository : Connecter votre GitHub
- Branch : main
- Root Directory : (laisser vide)
- Environment : Ruby
- Region : Oregon (US West) ou Frankfurt (Europe)

### 2. Configuration Build & Deploy

**Build Command:**
```bash
bundle install && bundle exec rails assets:precompile
```

**Start Command:**
```bash
bundle exec rails db:migrate && bundle exec rails db:seed && bundle exec rails server -p $PORT -e production
```

### 3. Variables d'environnement obligatoires

- `DATABASE_URL` : (Automatique avec PostgreSQL Render)
- `SECRET_KEY_BASE` : (Générer une clé secrète : `rails secret`)
- `RAILS_ENV` : `production`
- `RAILS_SERVE_STATIC_FILES` : `true`
- `RAILS_LOG_TO_STDOUT` : `true`

### 4. Variables d'environnement optionnelles

- `GMAIL_USERNAME` : Votre adresse Gmail
- `GMAIL_PASSWORD` : Votre mot de passe d'application Gmail

### 5. Base de données PostgreSQL

1. Créer une nouvelle base PostgreSQL sur Render
2. Noter le nom de la base (ex: `restaurant-limoges-db`)
3. Dans les variables du service web, ajouter la connexion à cette base

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
# 📰 News App

## 📌 Description
Application Flutter affichant les dernières actualités par catégorie en utilisant l’API NewsAPI.org.

## ✨ Fonctionnalités
- 📂 Sélection de catégories d'actualités.
- 🔄 Chargement et actualisation dynamique des articles.
- 🌐 Lecture des articles dans un navigateur intégré (`WebView`).
- 🏆 Affichage des actualités tendances.

## 📁 Structure
- `main.dart` : Interface principale.
- `news_service.dart` : Récupération des articles via API.
- `article_model.dart` : Modèle des articles.
- `webview_screen.dart` : Affichage des articles dans `WebView`.

## 🔗 Dépendances
- `http` : Requêtes HTTP.
- `webview_flutter` : Affichage des articles dans un navigateur intégré.
- `url_launcher` : Ouverture des liens externes.
- `provider` : Gestion de l’état.

## 🌍 API
L'application utilise **NewsAPI** pour récupérer les actualités. Un `apiKey` est requis et doit être défini dans `news_service.dart`.

## ⚠️ Remarque
L'API actuelle est limitée et ne permet pas d'afficher des actualités au-delà d'un certain quota journalier.

## 🎨 Mascottes
Les mascottes utilisées dans l'application ont été créées par **@walfieee**. Retrouvez son travail sur internet.

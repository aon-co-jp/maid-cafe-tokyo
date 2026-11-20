# Ajouter une icône à l'écran d'accueil (Android/iPhone/iPad)

open-english est une application web statique ne nécessitant pas de serveur (avec prise en
charge du manifeste PWA), il n'est donc pas nécessaire d'installer une application native
dédiée depuis un magasin d'applications — vous pouvez placer une icône sur l'écran
d'accueil grâce à la fonction "Ajouter à l'écran d'accueil" du navigateur.

## Prérequis

- `index.html` doit être ouvert via un serveur web (ou via le serveur de téléchargement de
  `open-easy-web`) — en l'ouvrant directement en `file://`, de nombreux navigateurs
  bloquent le chargement de manifest.json/des icônes, et "Ajouter à l'écran d'accueil" peut
  ne pas apparaître. Pour tester localement, par exemple :
  ```
  cd open-english
  python3 -m http.server 8090
  ```
  puis ouvrir `http://<IP du PC>:8090/index.html` dans le navigateur du smartphone.

## Android (Chrome)

1. Ouvrir `index.html` dans Chrome.
2. Toucher le menu "⋮" en haut à droite → "Ajouter à l'écran d'accueil" (ou
   "Installer" depuis la bannière d'installation qui peut apparaître automatiquement).
3. Les `icons` de `manifest.json` (`icons/icon-192.png`, `icons/icon-512.png`) sont
   utilisées comme icône de l'écran d'accueil.

## iPhone / iPad (Safari)

1. Ouvrir `index.html` dans Safari.
2. Toucher le bouton Partager (l'icône carrée avec une flèche vers le haut).
3. Choisir "Sur l'écran d'accueil".
4. `<link rel="apple-touch-icon" ...>` (`icons/icon-180.png`) est utilisée comme icône de
   l'écran d'accueil.

## Divulgation honnête

- Les deux méthodes créent **un raccourci de navigateur (une PWA), pas une application
  native** — il ne s'agit pas d'une installation via un magasin d'applications.
- Le fonctionnement hors ligne (un Service Worker) n'est pas implémenté — une connexion
  réseau reste nécessaire (étant donné que dans la conception de la Phase 0, `aruaru-llm`
  est un serveur résident local, cette configuration ne suppose pas que `aruaru-llm`
  fonctionne de manière autonome sur le smartphone).

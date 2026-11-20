# Aggiungere un'icona alla schermata Home (Android/iPhone/iPad)

open-english è un'app web statica che non richiede un server (con supporto per il manifest
PWA), quindi non è necessario installare un'app nativa dedicata da uno store — è possibile
posizionare un'icona sulla schermata Home usando la funzione "Aggiungi a schermata Home"
del browser.

## Prerequisiti

- `index.html` deve essere aperto tramite un server web (oppure tramite il server di
  download di `open-easy-web`) — aprendolo direttamente come `file://`, molti browser
  bloccano il caricamento di manifest.json/icone e "Aggiungi a schermata Home" potrebbe non
  comparire. Per provarlo localmente, ad esempio:
  ```
  cd open-english
  python3 -m http.server 8090
  ```
  quindi aprire `http://<IP del PC>:8090/index.html` nel browser dello smartphone.

## Android (Chrome)

1. Aprire `index.html` in Chrome.
2. Toccare il menu "⋮" in alto a destra → "Aggiungi a schermata Home" (oppure
   "Installa" dal banner di installazione che potrebbe comparire automaticamente).
3. Le `icons` di `manifest.json` (`icons/icon-192.png`, `icons/icon-512.png`) vengono
   usate come icona della schermata Home.

## iPhone / iPad (Safari)

1. Aprire `index.html` in Safari.
2. Toccare il pulsante Condividi (l'icona quadrata con la freccia verso l'alto).
3. Scegliere "Aggiungi a Home".
4. `<link rel="apple-touch-icon" ...>` (`icons/icon-180.png`) viene usata come icona
   della schermata Home.

## Divulgazione onesta

- Entrambi i metodi creano **una scorciatoia del browser (una PWA), non un'app nativa** —
  non si tratta di un'installazione tramite store.
- Il funzionamento offline (un Service Worker) non è implementato — è comunque necessaria
  una connessione di rete (dato che nel design della Fase 0 `aruaru-llm` è un server
  residente localmente, questa configurazione non presuppone l'esecuzione autonoma di
  `aruaru-llm` sullo smartphone).

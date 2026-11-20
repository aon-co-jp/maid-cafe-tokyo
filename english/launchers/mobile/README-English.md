# Adding a home-screen icon on phones/tablets (Android/iPhone/iPad)

open-english is a server-free static web app (with PWA manifest support), so there's no
need to install a dedicated native app from a store — you can place an icon on the home
screen using the browser's "Add to Home Screen" feature.

## Prerequisites

- `index.html` needs to be opened via some web server (or via `open-easy-web`'s download
  server) — opening it directly as `file://` often blocks manifest.json/icon loading in
  many browsers, and "Add to Home Screen" may not appear. To try it locally, for example:
  ```
  cd open-english
  python3 -m http.server 8090
  ```
  then open `http://<PC's IP>:8090/index.html` in your phone's browser.

## Android (Chrome)

1. Open `index.html` in Chrome.
2. Tap the "⋮" menu in the top right → "Add to Home Screen" (or "Install" from the
   install banner that may appear automatically).
3. `manifest.json`'s `icons` (`icons/icon-192.png`, `icons/icon-512.png`) are used as the
   home-screen icon.

## iPhone / iPad (Safari)

1. Open `index.html` in Safari.
2. Tap the Share button (the square icon with an arrow pointing up).
3. Choose "Add to Home Screen".
4. The `<link rel="apple-touch-icon" ...>` (`icons/icon-180.png`) is used as the
   home-screen icon.

## Honest disclosure

- Both methods create **a browser shortcut (a PWA), not a native app** — this is not a
  store-based install.
- Offline operation (a Service Worker) is not implemented — a network connection is still
  required (given the Phase 0 design where `aruaru-llm` is a locally-resident server, this
  setup does not assume running `aruaru-llm` standalone on the phone itself).

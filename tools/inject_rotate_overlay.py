#!/usr/bin/env python3
"""Injeta o aviso "Gire seu celular" no index.html exportado pelo Godot.

O jogo só funciona bem na horizontal, mas o navegador não gira o celular
sozinho. Sem isso, quem abrir na vertical acha que o jogo travou. Este
script insere um overlay em CSS puro (aparece sozinho via media query
"orientation: portrait", sem precisar de JavaScript extra) logo antes de
</body> no HTML exportado.

Uso: rodar depois de cada `godot --export-release "Web" build/web/index.html`.
"""

import sys
from pathlib import Path

OVERLAY = """
<style>
  #rotate-overlay {
    display: none;
    position: fixed; inset: 0; z-index: 9999;
    background: #0b0e1a;
    color: #fff;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-family: -apple-system, system-ui, sans-serif;
    text-align: center;
    padding: 24px;
  }
  #rotate-overlay .row { display: flex; align-items: center; justify-content: center; gap: 18px; margin-bottom: 26px; }
  #rotate-overlay .arrow { animation: arrow-pulse 1.4s ease-in-out infinite; }
  @keyframes arrow-pulse {
    0%, 100% { opacity: 0.5; transform: translateX(0); }
    50% { opacity: 1; transform: translateX(4px); }
  }
  @media (orientation: portrait) {
    #rotate-overlay { display: flex; }
  }
</style>
<div id="rotate-overlay">
  <div class="row">
    <svg width="46" height="72" viewBox="0 0 32 50" fill="none" stroke="#ffffff" stroke-opacity="0.45" stroke-width="2.4">
      <rect x="3" y="3" width="26" height="44" rx="5"></rect>
      <line x1="13" y1="41" x2="19" y2="41"></line>
    </svg>
    <svg class="arrow" width="30" height="30" viewBox="0 0 24 24" fill="#ff8c1a">
      <path d="M4 12 L16 12 L11 7 L12.4 5.6 L20 12 L12.4 18.4 L11 17 L16 12"></path>
    </svg>
    <svg width="72" height="46" viewBox="0 0 50 32" fill="none" stroke="#ff8c1a" stroke-width="2.4">
      <rect x="3" y="3" width="44" height="26" rx="5"></rect>
      <line x1="41" y1="9" x2="41" y2="15"></line>
    </svg>
  </div>
  <div style="font-size:22px; font-weight:bold; margin-bottom:8px;">Gire seu celular</div>
  <div style="font-size:16px; opacity:0.75;">Deite o celular na horizontal para jogar</div>
</div>
""".strip()


def main() -> None:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web/index.html")
    html = path.read_text(encoding="utf-8")
    if 'id="rotate-overlay"' in html:
        print("rotate overlay already present, skipping")
        return
    if "</body>" not in html:
        raise SystemExit(f"</body> not found in {path}")
    html = html.replace("</body>", OVERLAY + "\n</body>")
    path.write_text(html, encoding="utf-8")
    print(f"rotate overlay injected into {path}")


if __name__ == "__main__":
    main()

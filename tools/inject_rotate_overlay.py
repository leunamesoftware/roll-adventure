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
  #rotate-overlay svg { width: 88px; height: 88px; margin-bottom: 22px; animation: rotate-hint 1.6s ease-in-out infinite; }
  @keyframes rotate-hint {
    0%, 100% { transform: rotate(0deg); }
    50% { transform: rotate(-90deg); }
  }
  @media (orientation: portrait) {
    #rotate-overlay { display: flex; }
  }
</style>
<div id="rotate-overlay">
  <svg viewBox="0 0 24 24" fill="none" stroke="#ff8c1a" stroke-width="1.6">
    <rect x="7" y="2" width="10" height="16" rx="2"></rect>
    <line x1="10" y1="20" x2="14" y2="20"></line>
  </svg>
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

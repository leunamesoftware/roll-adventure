#!/usr/bin/env python3
"""Pós-processa o build Web exportado pelo Godot (index.html e manifest.json).

O export do Godot sozinho deixa duas coisas erradas para um PWA mobile:

1. Não avisa o jogador para girar o celular (o jogo é só paisagem, mas o
   navegador não gira a tela sozinho) — sem isso, quem abre na vertical acha
   que travou. Corrigido injetando um overlay em CSS puro (aparece via media
   query "orientation: portrait", sem JavaScript) antes de </body>.
2. O manifest.json sai com "orientation":"portrait" (errado, o app é
   paisagem) e os ícones sem "purpose":"maskable" — por isso a tela de
   abertura do app instalado mostra o ícone quadrado "cru", diferente dos
   outros apps que aparecem arredondados/circulares.

Uso: rodar depois de cada `godot --export-release "Web" build/web/index.html`.
"""

import json
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
  <div style="font-size:16px; opacity:0.75; margin-bottom:22px;">Deite o celular na horizontal para jogar</div>
  <div style="font-size:13px; opacity:0.6; max-width:280px; margin-bottom:14px;">Se a tela não girar sozinha, ative a rotação automática nas configurações do celular.</div>
  <div id="rotate-skip" style="font-size:14px; text-decoration:underline; opacity:0.55; cursor:pointer;" onclick="document.getElementById('rotate-overlay').style.setProperty('display','none','important')">Jogar mesmo assim</div>
</div>
""".strip()


def inject_overlay(html_path: Path) -> None:
    html = html_path.read_text(encoding="utf-8")
    if 'id="rotate-overlay"' in html:
        print("rotate overlay already present, skipping")
        return
    if "</body>" not in html:
        raise SystemExit(f"</body> not found in {html_path}")
    html = html.replace("</body>", OVERLAY + "\n</body>")
    html_path.write_text(html, encoding="utf-8")
    print(f"rotate overlay injected into {html_path}")


def fix_manifest(manifest_path: Path) -> None:
    if not manifest_path.exists():
        print(f"{manifest_path} not found, skipping manifest fix")
        return
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    data["orientation"] = "landscape"
    for icon in data.get("icons", []):
        icon["purpose"] = "any maskable"
    manifest_path.write_text(json.dumps(data), encoding="utf-8")
    print(f"manifest fixed (orientation=landscape, maskable icons) in {manifest_path}")


def main() -> None:
    web_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "build/web")
    inject_overlay(web_dir / "index.html")
    fix_manifest(web_dir / "index.manifest.json")


if __name__ == "__main__":
    main()

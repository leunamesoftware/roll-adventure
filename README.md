# Trixo

Jogo de aventura/plataforma original para Android — controle o Trixo através de
mundos, fases, inimigos e desafios. Personagens, cenários, inimigos e obstáculos são
todos originais (ver `docs/REFERENCIA_VISUAL.md` sobre o uso de imagens de referência).

- **Engine**: Godot 4.3 (GDScript).
- **Estado atual**: primeira fatia jogável — menu, seleção de mundos, mapa de fases,
  3 fases completas no Mundo 1 (Floresta Verde), HUD, pausa, vitória, derrota, save/load.
- **Arquitetura**: ver `docs/ARQUITETURA.md` (como adicionar fases, mundos, inimigos).

## Como abrir

1. Instale o [Godot 4.3](https://godotengine.org/download).
2. Abra a pasta `roll-adventure/` no Godot (ele detecta o `project.godot`).
3. Aperte F5 para rodar.

## Estrutura

```
roll-adventure/
  project.godot
  scenes/Main.tscn
  scripts/          — todo o código (autoloads, gameplay, telas)
  data/             — catálogo de mundos e dados de cada fase (JSON)
  docs/             — arquitetura e referências do projeto
```

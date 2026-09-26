# Arquitetura — Trixo

## Stack

- **Engine**: Godot 4.3 (GDScript). Escolhida por ser gratuita/open-source sem taxas de
  licença mesmo com o jogo faturando, leve, exporta nativamente para Android (APK/AAB) e
  Web, e usa arquivos em texto (bom para Git).
- **Orientação**: paisagem (`sensor_landscape`). É um jogo de plataforma lateral (o Trixo
  corre para os lados), então a tela precisa ser mais larga que alta — diferente das
  imagens de referência (que são só mockups de composição, não screenshots reais de
  device). Viewport base: 1920x1080.

## Pastas

```
roll-adventure/
  project.godot
  icon.svg                 — ícone placeholder (trocar pela arte final do personagem)
  scenes/Main.tscn          — única cena "de verdade"; tudo mais é montado por código
  scripts/
    main.gd                 — boot: cria o container de UI e chama a primeira tela
    autoload/                — singletons (ver abaixo)
    gameplay/                — player, inimigos, obstáculos, coletáveis, level_builder
    ui/                      — telas (Control) e widgets (joystick)
  data/
    worlds.json              — catálogo de mundos e fases (metadados)
    levels/*.json             — layout de cada fase (plataformas, inimigos, etc.)
  docs/                      — esta pasta
```

## Autoloads (singletons)

| Autoload | Responsabilidade |
|---|---|
| `GameManager` | Estado da sessão atual (moedas da fase, vidas, objetivos), catálogo de mundos/fases mesclado com o progresso salvo, input map. |
| `SaveManager` | Único responsável por ler/escrever `user://save_data.json` (moedas, gemas, estrelas, poderes desbloqueados, progresso por fase, configurações). |
| `AudioManager` | Toca música/efeitos. Métodos são seguros mesmo sem nenhum `.ogg` carregado ainda — basta atribuir os streams depois, sem mexer no resto do código. |
| `SceneRouter` | Troca as "telas" (ver abaixo). |

## Telas por código (sem depender do editor)

Só existe uma cena real (`Main.tscn`). Cada tela (menu, seleção de mundos, mapa de fases,
gameplay...) é uma classe GDScript própria em `scripts/ui/` que estende `ScreenBase`
(`extends Control`) e monta sua própria UI dentro de `_ready()`/`setup(params)`.
`SceneRouter.go_to("nome_da_tela", {params})` troca a tela atual.

Vantagem: nada depende de cenas `.tscn` complexas feitas na mão sem o editor gráfico —
é só GDScript, fácil de revisar, testar e gerar automaticamente.

Para adicionar uma tela nova: criar `scripts/ui/minha_tela.gd extends ScreenBase` e
registrar em `scripts/autoload/scene_router.gd` no dicionário `_screens`.

## Sistema de fases orientado a dados

`LevelBuilder` (`scripts/gameplay/level_builder.gd`) lê um arquivo JSON e monta a fase
inteira em tempo de execução — plataformas, inimigos, obstáculos, coletáveis, bandeira de
chegada. **Isso é o que permite criar fases novas sem editar nada no editor**: basta
escrever um novo arquivo em `data/levels/`.

Esquema de uma fase (todos os campos são opcionais exceto os óbvios):

```jsonc
{
  "background_color": "#8fd3f4",
  "level_width": 2300, "level_height": 900,
  "player_start": [100, 600],

  "platforms": [ {"pos": [x, y], "size": [w, h]} ],
  "moving_platforms": [ {"pos": [x, y], "size": [w, h], "travel": [dx, dy], "speed": 90} ],
  "spikes": [ {"pos": [x, y], "width": 100, "count": 3} ],
  "swinging_spikes": [ {"pos": [x, y], "chain_length": 160} ],

  "coins": [ [x, y] ],
  "gems": [ [x, y] ],
  "secret_star": {"pos": [x, y]},

  "enemies": [
    {"type": "patrol", "style": "spike_ball|crawler|shelled", "pos": [x, y], "patrol_distance": 150, "speed": 80},
    {"type": "flyer", "pos": [x, y], "patrol_distance": 130, "speed": 90}
  ],

  "goal": {"pos": [x, y]}
}
```

E cada fase é registrada em `data/worlds.json`, dentro do mundo correspondente:

```jsonc
{"id": "fase_4", "name": "Fase 4", "order": 4, "coin_target": 12, "scene_data": "res://data/levels/floresta_fase_4.json"}
```

Para criar um **mundo novo**: adicionar uma entrada em `worlds.json` (ele já aparece na
tela de Seleção de Mundos, bloqueado até o anterior render pelo menos 1 estrela).

### Sistema de estrelas / objetivos

As 3 estrelas de cada fase = 3 objetivos independentes (igual ao HUD de referência):

1. Chegar ao final (sempre, é a condição de vitória).
2. Coletar `coin_target` moedas (definido em `worlds.json`).
3. Encontrar a estrela secreta (se a fase tiver uma).

## Camadas de física

Centralizadas em `scripts/gameplay/collision_layers.gd` para não espalhar números mágicos:

- `WORLD (1)`: plataformas — tudo que é sólido.
- `PLAYER (2)`: corpo do jogador.
- `ENEMY (4)`: corpo dos inimigos (colidem com o mundo, não fisicamente com o jogador).

Dano/pisão/coleta são detectados por `Area2D` (espinhos, moedas, inimigos, bandeira), não
por colisão física — isso evita empurrões estranhos entre jogador e inimigo.

## Visual atual (placeholder) vs. arte final

Todo o visual atual é desenhado em código (`_draw()`: círculos, polígonos, retângulos) —
zero dependência de arquivos de imagem. Isso deixa o **jogo de verdade** (física, telas,
progressão, save) pronto e testável agora. A arte final ilustrada (no estilo das imagens
de referência) é uma etapa separada: quando estiver pronta (sprites/spritesheets), ela
entra em cada entidade como um `Sprite2D`/`AnimatedSprite2D` sem precisar mexer na lógica.

## O que já funciona (v0.1 — primeira fatia jogável)

- Menu principal, seleção de 5 mundos (só Floresta Verde desbloqueada), mapa de fases.
- 3 fases completas e com dificuldade progressiva no Mundo 1 (Floresta Verde).
- Trixo: mover, pular, pulo duplo (desbloqueia ao terminar a Fase 1).
- Moedas, gemas, estrela secreta, 3 estilos de inimigo terrestre, inimigo voador,
  espinhos, armadilha giratória, plataforma móvel (horizontal e vertical), bandeira.
- HUD completo (vidas, moedas, gemas, tempo, objetivos), joystick virtual + pular + poder.
- Pausa, vitória (com estrelas/estatísticas/próxima fase), derrota (sem anúncio forçado).
- Save/load em JSON (progresso, moedas, gemas, poderes, configurações).

## Próximos passos (arquitetura já preparada para isso)

- Telas de Personagens, Loja, Conquistas, Ranking e Configurações (hoje mostram uma tela
  "em breve" para manter a navegação sempre funcional).
- Sistema de poderes ativáveis (botão "PODER" já existe no HUD, hoje desabilitado).
- Áudio final (`AudioManager` já tem os pontos de chamada prontos).
- Arte final (sprites) no lugar dos desenhos placeholder.
- Novos mundos (Cidade, Deserto, Gelo, Vulcão) — só precisam de fases em `data/levels/`.
- Export Android assinado para a Google Play (export web já cobre teste rápido no celular).

## Rodar / testar

1. Abrir a pasta `roll-adventure/` no Godot 4.3 e apertar F5 (roda `scenes/Main.tscn`).
2. Ou via terminal: `godot4 --path roll-adventure`.
3. Testar no celular: gerar o export Web (ver `docs/EXPORTAR.md` quando disponível) e abrir
   o link no navegador do celular — dá pra "instalar" como app (PWA).

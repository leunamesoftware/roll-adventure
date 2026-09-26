extends RefCounted
class_name CollisionLayers
## Camadas de física do jogo, centralizadas para evitar números mágicos espalhados.

const WORLD := 1   # plataformas e chão (StaticBody2D / AnimatableBody2D)
const PLAYER := 2  # corpo do jogador (CharacterBody2D)
const ENEMY := 4   # corpo dos inimigos (CharacterBody2D)

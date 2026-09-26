extends Node
## Gerencia música e efeitos sonoros. Os arquivos de áudio finais (.ogg) serão adicionados
## depois; os métodos abaixo são seguros mesmo sem nenhum AudioStream carregado, então o
## restante do jogo já pode chamar play_sfx()/play_music() desde já.

const SFX_POOL_SIZE := 6

var music_player: AudioStreamPlayer
var sfx_players: Array = []

var music_volume: float = 0.8
var sfx_volume: float = 1.0

func _ready() -> void:
	music_volume = SaveManager.get_setting("music_volume", 0.8)
	sfx_volume = SaveManager.get_setting("sfx_volume", 1.0)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	for i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	_apply_volumes()

func _apply_volumes() -> void:
	if music_player:
		music_player.volume_db = linear_to_db(clamp(music_volume, 0.001, 1.0))
	for p in sfx_players:
		p.volume_db = linear_to_db(clamp(sfx_volume, 0.001, 1.0))

func set_music_volume(value: float) -> void:
	music_volume = value
	SaveManager.set_setting("music_volume", value)
	_apply_volumes()

func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	SaveManager.set_setting("sfx_volume", value)
	_apply_volumes()

func play_music(stream: AudioStream) -> void:
	if stream == null or music_player == null:
		return
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.play()

func stop_music() -> void:
	if music_player:
		music_player.stop()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	sfx_players[0].stream = stream
	sfx_players[0].play()

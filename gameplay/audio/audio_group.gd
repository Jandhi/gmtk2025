class_name AudioGroup extends Resource

var name : String
var _cooldown : float = 0.0
var cooldown_time : float = 0.0
var max_players : int = 1
var players : Array[AudioStreamPlayer] = []
var fade_on_new_sound : bool = false
var volume_scaling : float = 1.0

static func make(new_name: String, new_cooldown_time: float, new_max_players: int, do_fade_on_new_sound : bool = false) -> AudioGroup:
	var group = AudioGroup.new()
	group.name = new_name
	group.cooldown_time = new_cooldown_time
	group.max_players = new_max_players
	group.fade_on_new_sound = do_fade_on_new_sound
	return group

func with_volume_scaling(new_volume_scaling: float) -> AudioGroup:
	volume_scaling = new_volume_scaling
	return self

func add_player(player: AudioStreamPlayer) -> void:
	_cooldown = cooldown_time
	players.append(player)

func is_available() -> bool:
	return _cooldown == 0.0 and players.size() < max_players

func update(delta: float) -> void:
	var players_to_remove = []

	for player in players:
		if not player.is_playing():
			players_to_remove.append(player)

	for player in players_to_remove:
		players.erase(player)

	_cooldown = max(0.0, _cooldown - delta)

func fade_out(skip_fade = false) -> void:
	if players.size() == 0:
		return

	if not skip_fade:
		var tween = AudioManager.get_tree().create_tween().set_parallel(true)
		
		for player in players:
			tween.tween_property(player, "volume_db", -80.0, 0.5)
		
		await tween.finished

	for player in players:
		player.stop()

	players.clear()
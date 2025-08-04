class_name AudioPlayerBank extends Node

@export var audio_stream_player_prefab : PackedScene = preload("res://gameplay/audio/audio_stream_player.tscn")
@export var player_count : int = 5

func _ready():
	AudioManager.players.clear()

	for player in range(player_count):
		var player_instance = audio_stream_player_prefab.instantiate()
		player_instance.name = "AudioStreamPlayer" + str(player)
		add_child(player_instance)
		player_instance.stream = null
		AudioManager.players.append(player_instance)

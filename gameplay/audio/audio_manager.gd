extends Node

var sounds : Dictionary[String, AudioStream] = {}
var group_by_sound : Dictionary[String, String] = {}
var multi_sounds : Dictionary[String, Array] = {}

var players : Array[AudioStreamPlayer] = []
var groups : Dictionary[String, AudioGroup] = {}

func _ready():
	load_audio()

func load_audio():
	groups = {
		"music" : AudioGroup.make("music", 0.0, 1, true).with_volume_scaling(0.3),
		"continuous" : AudioGroup.make("continuous", 1.0, 1, false).with_volume_scaling(2.0),
	}

	sounds = {
		"drop1": load("res://audio/drop/zapsplat_foley_tool_bag_fabric_with_tools_in_open_set_down_on_concrete_001_106888.wav"),
		"drop2": load("res://audio/drop/zapsplat_foley_tool_bag_fabric_with_tools_in_open_set_down_on_concrete_002_106889.wav"),
		"drop3": load("res://audio/drop/zapsplat_foley_tool_bag_fabric_with_tools_in_open_set_down_on_concrete_003_106890.wav"),
		"drop4": load("res://audio/drop/zapsplat_foley_tool_bag_fabric_with_tools_in_open_set_down_on_concrete_004_106891.wav"),
		"drop5": load("res://audio/drop/zapsplat_foley_tool_bag_fabric_with_tools_in_open_set_down_on_concrete_005_106893.wav"),

		"switch1" : load("res://audio/switch/zapsplat_household_switch_fan_click_001_110049.wav"),
		"switch2" : load("res://audio/switch/zapsplat_household_switch_fan_click_002_110050.wav"),
		"switch3" : load("res://audio/switch/zapsplat_household_switch_fan_click_003_110051.wav"),
		"switch4" : load("res://audio/switch/zapsplat_household_switch_fan_click_004_110052.wav"),

		"squeak1" : load("res://audio/squeak/zapsplat_foley_box_container_industrial_metal_small_hinge_squeak_001_52652.wav"),
		"squeak2" : load("res://audio/squeak/zapsplat_foley_box_container_industrial_metal_small_hinge_squeak_002_52502.wav"),
		"squeak3" : load("res://audio/squeak/zapsplat_foley_box_container_industrial_metal_small_hinge_squeak_003_52503.wav"),
		"squeak4" : load("res://audio/squeak/zapsplat_foley_box_container_industrial_metal_small_hinge_squeak_004_52504.wav"),
		"squeak5" : load("res://audio/squeak/zapsplat_foley_box_container_industrial_metal_small_hinge_squeak_005_52505.wav"),

		"pickup1" : load("res://audio/pickup/pickup1.wav"),

		"screw_in" : load("res://audio/screw_in/screw_in.wav"),
		"screw_done" : load("res://audio/screw_done/zapsplat_industrial_tool_driver_drill_cordless_direction_switch_click_rockwell_002_102928.wav"),

		"hammer" : load("res://audio/hammer/hammer.wav"),
		"hammer_done" : load("res://audio/hammer/hammer_done.wav"),

		"snap1" : load("res://audio/snap/Weapon Equipped 2.wav"),
		"snap2" : load("res://audio/snap/Weapon Equipped 3.wav"),
		"snap3" : load("res://audio/snap/Weapon Equipped 4.wav"),
		"snap4" : load("res://audio/snap/Weapon Equipped 5.wav"),

		"da_boss1" : load("res://audio/da_boss/da_boss1.wav"),
		"da_boss2" : load("res://audio/da_boss/da_boss2.wav"),
		"da_boss3" : load("res://audio/da_boss/da_boss3.wav"),
		"da_boss4" : load("res://audio/da_boss/da_boss4.wav"),
		"da_boss5" : load("res://audio/da_boss/da_boss5.wav"),
		"da_boss6" : load("res://audio/da_boss/da_boss6.wav"),
		"da_boss7" : load("res://audio/da_boss/da_boss7.wav"),

		"ennui" : load("res://audio/ennui.wav"),
		"belt" : load("res://audio/belt.wav"),
	}

	multi_sounds = {
		"drop": ["drop1", "drop2", "drop3", "drop4", "drop5"],
		"switch": ["switch1", "switch2", "switch3", "switch4"],
		"squeak": ["squeak1", "squeak2", "squeak3", "squeak4", "squeak5"],
		"pickup": ["pickup1"],
		"snap": ["snap1", "snap2", "snap3", "snap4"],
		"da_boss": ["da_boss1", "da_boss2", "da_boss3", "da_boss4", "da_boss5", "da_boss6", "da_boss7"],
	}

	group_by_sound = {
		"squeak" : "continuous",
		"ennui" : "music",
	}

func _process(delta):
	for group_name in groups:
		groups[group_name].update(delta)

func play(sound_name : String, pitch_randomness : float = 0.0, volume : float = 1.0, skip_fade : bool = false, pitch_shift : float = 0.0):
	var sound : AudioStream = null

	if sounds.has(sound_name):
		sound = sounds[sound_name]
	elif multi_sounds.has(sound_name):
		var sounds_array = multi_sounds[sound_name]
		sound = sounds[sounds_array[randi() % sounds_array.size()]]
	else:
		print("Sound not found: " + sound_name)
		return

	var group = null

	if group_by_sound.has(sound_name):
		var group_name = group_by_sound[sound_name]
		if groups.has(group_name):
			group = groups[group_name]


			if group.fade_on_new_sound:
				await group.fade_out(skip_fade)

			if not group.is_available():
				print("Group is not available: " + group_name)
				return
			
			volume *= group.volume_scaling
			print("volue scaling: " + str(group.volume_scaling))

	var player = get_next_free_player()

	if group != null:
		group.add_player(player)
	
	if player == null:
		print("No free player found")
		return

	if sound == null:
		print("WARNING: Sound is null for sound name: " + sound_name)

	player.stream = sound
	player.pitch_scale = 1.0 + pitch_shift + randf_range(-pitch_randomness, pitch_randomness)
	player.volume_db = linear_to_db(volume)
	player.play()

	

	
func get_next_free_player() -> AudioStreamPlayer:
	for player in players:
		if not player.is_playing():
			return player

	return null

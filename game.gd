class_name Game extends Node2D

signal finished_product

@export var da_boss : DaBoss
@export var day_sign : DaySign
@export var belt1 : Node2D
@export var belt2 : Node2D
@export var clock : Clock
var day : int = 0
const SKIP_MODE : bool = false

var tutorial_screw_car : PackedScene = preload("res://gameplay/products/screw_tutorial_car.tscn")
var lever_tutorial : PackedScene = preload("res://gameplay/products/lever_tutorial.tscn")
var day1_products : Array[PackedScene] = [
	preload("res://gameplay/products/day1/bot.tscn"),
	preload("res://gameplay/products/day1/car.tscn"),
	preload("res://gameplay/products/day1/puter.tscn"),
	preload("res://gameplay/products/day1/toaster.tscn"),
]

var day2_products : Array[PackedScene] = [
	preload("res://gameplay/products/day2/bot.tscn"),
	preload("res://gameplay/products/day2/car.tscn"),
	preload("res://gameplay/products/day2/puter.tscn"),
	preload("res://gameplay/products/day2/toaster.tscn"),
]

var day3_products : Array[PackedScene] = [
	preload("res://gameplay/products/day3/bot.tscn"),
	preload("res://gameplay/products/day3/car.tscn"),
	preload("res://gameplay/products/day3/puter.tscn"),
	preload("res://gameplay/products/day3/toaster.tscn"),
]

var day4_products : Array[PackedScene] = [
	preload("res://gameplay/products/day4/bot.tscn"),
	preload("res://gameplay/products/day4/car.tscn"),
	preload("res://gameplay/products/day4/puter.tscn"),
	preload("res://gameplay/products/day4/toaster.tscn"),
]

var day5_products : Array[PackedScene] = [
	preload("res://gameplay/products/day5/bot.tscn"),
	preload("res://gameplay/products/day5/car.tscn"),
	preload("res://gameplay/products/day5/puter.tscn"),
	preload("res://gameplay/products/day5/toaster.tscn"),
]

func _input(ev):
	if Input.is_key_pressed(KEY_Z) and SKIP_MODE:
		finished_product.emit()

	if Input.is_key_pressed(KEY_X) and SKIP_MODE:
		game_over()

func start_game():
	day = 0
	clock.time_hit.connect(game_over)
	
	if not SKIP_MODE:
		await day_sign.show_day(0)
		await get_tree().create_timer(0.5).timeout
		await da_boss.boss_sequence([
			"Welcome to the factory!",
			"Your job is to assemble our products in a timely manner.",
			"We'll start simple, with some screws.",
			"Click the screwdriver to pick it up.",
			"Then click on the screw to put it in.",
			"Once it's in, drag down to fasten the screw.",
			"I'm sure you can handle that.",
		])


	await do_products([tutorial_screw_car])
	
	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"Good job! Now let's see if you can finish a few products before the day is done.",
		])

	
	clock.start_clock()
	await do_products(day1_products)
	clock.stop_clock()

	await day_sign.show_day(1)

	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"Well done! You finished the first day.",
			"Let's see if you can keep up the pace.",
		])

	clock.start_clock()
	await do_products(day2_products)
	clock.stop_clock()

	await day_sign.show_day(2)

	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"Impressive! You managed to keep up.",
			"Now we're introducing the hammer.",
			"Figure it out yourself, it's not that hard.",
		])

	clock.start_clock()
	await do_products(day3_products)
	clock.stop_clock()

	await day_sign.show_day(3)

	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"Now that's what I call percussive maintenance!",
			"Now let's see you figure this one out.",
		])

	
	await do_products([lever_tutorial])

	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"You're a natural.",
			"Now get back to work!",
		])

	clock.start_clock()
	await do_products(day4_products)
	clock.stop_clock()

	await day_sign.show_day(4)

	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"You're doing great! But can you handle the pressure?",
			"Let's see how you do with the final day.",
		])

	clock.start_clock()
	await do_products(day5_products)
	clock.stop_clock()

	if not SKIP_MODE:
		await da_boss.boss_sequence([
			"Congratulations! You made it to the end of the week.",
			"You've proven yourself to be a valuable asset to the factory.",
			"However, due to restructing, we still have to replace you with an AI.",
			"Goodbye!",
		])

	get_tree().change_scene_to_file("res://gameplay/end.tscn")



func game_over():
	move_belts()
	await da_boss.boss_sequence([
		"You failed to finish the products in time.",
		"Time to replace you with an ai.",
		"Goodbye!",
	])
	get_tree().change_scene_to_file("res://gameplay/end.tscn")

func do_products(products : Array[PackedScene]):
	products.shuffle()
	for product in products:
		prepare_next_product(product)
		await move_belts()
		await finished_product
	await move_belts()

func move_belts():
	AudioManager.play("belt")
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(belt2, "position:x", 240, 1.0)
	tween.tween_property(belt1, "position:x", 720, 1.0)
	await tween.finished
	belt1.position.x = -240

	for child in belt1.get_children():
		child.queue_free()
	
	# swap belts
	var temp = belt1
	belt1 = belt2
	belt2 = temp

func on_finished():
	finished_product.emit()

func prepare_next_product(item : PackedScene):
	var instance : Product = item.instantiate()
	belt2.add_child(instance)
	instance.position = Vector2(0, -80)
	instance.finished.connect(on_finished)

class_name Product extends Sprite2D

signal finished

var is_finished : bool = false
var puzzle_count : int = 0

func puzzle_finished():
	puzzle_count -= 1

	if puzzle_count <= 0:
		finished.emit()
		is_finished = true

func puzzle_unfinished():
	puzzle_count += 1
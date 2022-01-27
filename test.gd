extends Node2D



func _ready() -> void:
	var array = []
	array.push_back([])
	array[0] = [["a", "b"], 1,2,3,4]

	print(array[0][0][1])


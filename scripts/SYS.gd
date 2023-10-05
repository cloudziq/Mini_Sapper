# Dziq 2022 - 2023
# v0.2





extends Node2D


export var rec          : bool


var tile_size_in_pixels := 32

# should be later affected by some kind of a performance setting?:
#var board_max_tiles_w    := 60
#var board_max_tiles_h    := 60


var BG1_amount  = countImages("res://assets/graphics/level_bg/main")
var BG2_amount  = countImages("res://assets/graphics/level_bg/additional")


var level  = preload("res://scenes/level_main.tscn")  ; var LEVEL : Node2D
var menu   = preload("res://scenes/main_menu.tscn")




# rotate type:
# 1: can be rotated only by 90 degree steps
# 2: full random rotation

#   0            1               2                   3
#   variants:    rotate_type:    ON/OFF_variants:    highlight brightness multiplier:
var theme_data = [
	[1,          1,              false,              1 ],               # 1
	[1,          1,              false,              1 ],               # 2
	[1,          1,              false,              1 ],               # 3
	[3,          1,              false,              2 ],               # 4
	[3,          1,              false,              1 ],               # 5
	[4,          1,              false,              .5],               # 6
	[1,          1,              false,              1 ],               # 7
	[1,          1,              false,              1 ],               # 8
	[1,          1,              true,               1 ],               # 9
	[1,          1,              false,              1 ],               # 10
	[1,          1,              true,               2 ],               # 11
	[1,          2,              false,              .5],               # 12
	[1,          1,              true,               2 ],               # 13
	[1,          2,              false,              2 ],               # 14
	[3,          1,              false,              2 ],               # 15
	[1,          2,              true,               1 ],               # 16
	[1,          2,              true,               2 ],               # 17
	[1,          2,              true,               2 ],               # 18
	[1,          2,              false,              1 ],               # 19
	[1,          2,              false,              .5],               # 20
	[1,          2,              false,              1 ],               # 21
	[1,          2,              false,              1 ],               # 22
	[1,          1,              false,              1 ],               # 23
	[1,          1,              true,               4 ],               # 24
	[1,          2,              true,               4 ],               # 25
	[1,          2,              false,              1 ],               # 26
	[1,          2,              true,               12],               # 27
]


#   board_x:  board_y:  bombs:  revealed tiles:
var level_data = [
	[3,        3,       1,      0],        # 1
	[4,        4,       1,      0],        # 2
	[5,        5,       1,      0],        # 3
	[5,        6,       1,      0],        # 4
	[6,        6,       1,      1],        # 5
	[6,        7,       1,      1],        # 6
	[7,        8,       1,      1],        # 7
	[7,        8,       1,      1],        # 8
	[8,        8,       1,      2],        # 9
	[8,        8,       0,      2],        # 10
	[8,        9,       1,      2],        # 11
	[8,        9,       1,      2],        # 12
	[8,       10,       1,      2],        # 13
	[8,       10,       1,      2],        # 14
	[8,       11,       1,      2],        # 15
	[8,       11,       1,      2],        # 16
	[8,       12,       1,      3],        # 17
	[8,       12,       1,      3],        # 18
	[9,       13,       1,      3],        # 19
	[9,       13,       1,      3],        # 20
	[9,       14,       1,      3],        # 21
	[9,       14,       1,      3],        # 22
	[10,      14,       1,      3],        # 23
	[10,      14,       1,      4],        # 24
	[10,      15,       1,      4],        # 25
	[10,      15,       1,      4],        # 26
	[10,      16,       1,      4],        # 27
	[10,      16,       1,      4],        # 28
	[10,      16,       1,      4],        # 29
	[10,      16,       1,      5],        # 30
	[10,      16,       1,      5],        # 31
	[10,      16,       1,      5],        # 32
	[10,      16,       1,      5],        # 33
	[10,      16,       1,      6],        # 34
	[10,      16,       1,      6],        # 35
]






func _ready() -> void:
	randomize()
	G.load_config()
	window_prepare()

	LEVEL  = level.instance()
	add_child(menu.instance())
	$AudioStreamPlayer.play()






func start_game() -> void:
	add_child(LEVEL)






func window_prepare() -> void:
	var display_size = OS.get_screen_size()
	var window_size  = G.window

	if rec == true:
		window_size *= Vector2(1.16, 1.16)
	else:
		window_size *= Vector2(4, 4)

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.y / (display_size.y - 80)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.window_size = window_size
	window_size.y += 78
	OS.window_position = display_size * .5 - window_size * .5






func countImages(path : String) -> int:
	var num       :=  0

	var dir       := Directory.new()
#	var path       = "res://assets/graphics/level_bg/OLD"

	if dir.open(path) == OK:
		var _nic  = dir.list_dir_begin()
		var file  = dir.get_next()

		while file != "":
			var startIndex  = file.find("_") + 1
			var endIndex    = file.find(".", startIndex)

			if file.begins_with("BG_") and file.ends_with(".png"):
				var digits  = file.substr(startIndex, endIndex - startIndex)
				if digits.is_valid_integer():
					num += 1
			file =  dir.get_next()

		dir.list_dir_end()

#	print("BG's in folder: "+str(num))
	return num






func _exit_tree():
#	$AudioStreamPlayer.playing = false
	G.save_config()

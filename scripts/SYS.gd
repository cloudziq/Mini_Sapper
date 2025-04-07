# Dziq 2022 - 2028
# v0.31





extends Node2D

enum screens {normal, small, mini}
export(screens) var screen  = screens.normal


var tile_size_in_pixels := 32
var window_size         :  Vector2

# should be later affected by some kind of a performance setting?:
#var board_max_tiles_w    := 60
#var board_max_tiles_h    := 60


var BG1_amount  = countImages("res://assets/graphics/level_bg/main")
var BG2_amount  = countImages("res://assets/graphics/level_bg/additional")

var level  = preload("res://scenes/level_main.tscn")  ; var LEVEL: Node2D
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


#   x:         y:       bombs:  revealed_tiles:
var level_data = [
	[3,        3,       2,      0],        # 1
	[3,        4,       1,      0],        # 2
	[4,        4,       1,      0],        # 3
	[4,        5,       1,      0],        # 4
	[5,        5,       1,      1],        # 5
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
	[11,      15,       1,      4],        # 26
	[11,      15,       1,      4],        # 27
	[12,      16,       1,      4],        # 28
	[12,      16,       1,      4],        # 29
	[12,      16,       1,      5],        # 30
	[13,      17,       1,      5],        # 31
	[13,      17,       1,      5],        # 32
	[13,      17,       1,      5],        # 33
	[14,      18,       1,      6],        # 34
	[14,      18,       1,      6],        # 35
	[14,      18,       1,      5],        # 36
	[15,      19,       1,      5],        # 37
	[15,      19,       1,      5],        # 38
	[15,      19,       1,      6],        # 39
	[16,      20,       1,      6],        # 40
]






func _ready() -> void:
	randomize()
	if G.save_version == -1: G.save_version  = 1    ##-save_reset thingy
	G.load_config()
	window_prepare()

	LEVEL  = level.instance()
	add_child(menu.instance())
#	$AudioStreamPlayer.play()






func start_game() -> void:
	add_child(LEVEL)






func window_prepare() -> void:
	var display_size = OS.get_screen_size()

	window_size  = G.window

	if screen == screens.normal:
		window_size *= Vector2(4, 4)
	elif screen == screens.small:
		window_size *= Vector2(.745, .745)
	else:
		window_size *= Vector2(.6, .6)

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.y /(display_size.y -100)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.window_size = window_size
	window_size.y += 64

	var pos  = G.CONFIG.window_pos
	if pos[0] == 0:
		OS.window_position = display_size *.5 -window_size *.5
	else:
		OS.window_position  = Vector2(pos[0], pos[1])

	var val  = lerp(.04, .6, G.CONFIG.BG_brightness *.2)
	var col  = Color(val, val, val, 1)
	VisualServer.set_default_clear_color(col)







func countImages(path : String) -> int:
	var num := 0
	var dir := Directory.new()

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
	G.CONFIG.window_pos  = [OS.window_position.x, OS.window_position.y]
	G.save_config()

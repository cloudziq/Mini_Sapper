extends Node2D


export(PackedScene)  var _LEVEL
export var rec           : bool

var tile_size_in_pixels  := 32
var board_max_tiles_w    := 60
var board_max_tiles_h    := 60






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
	[1,          1,              false,              1 ],               # 9
	[1,          1,              false,              1 ],               # 10
	[1,          1,              true,               2 ],               # 11
	[1,          2,              false,              .5],               # 12
	[1,          1,              true,               2 ],               # 13
	[1,          2,              false,              2 ],               # 14
	[3,          1,              false,              1 ],               # 15
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
	[4,       4,        2,      0],        # 1
	[5,       4,        1,      0],        # 2
	[5,       5,        1,      0],        # 3
	[5,       6,        1,      0],        # 4
	[6,       6,        0,      1],        # 5
	[6,       7,        1,      1],        # 6
	[7,       8,        1,      1],        # 7
	[7,       8,        1,      1],        # 8
	[8,       8,        1,      2],        # 9
	[8,       8,        0,      2],        # 10
	[8,       9,        1,      2],        # 11
	[8,       9,        1,      2],        # 12
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






func _ready():
	randomize()
	load_config()
	window_prepare()
	findBackgroundImages()

	yield(get_tree().create_timer(.4), "timeout")
	add_child(_LEVEL.instance())







var save_version = 0
var SETTINGS
var config_path

func save_config():
	var password = "87643287643876243876241"
	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	config.set_value("config", "save_version", save_version)
	config.set_value("config", "settings", SETTINGS)

#	config.save("user://config.cfg")
	config.save_encrypted(config_path, key)






func load_config():
	var password = "87643287643876243876241"
	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	var system = OS.get_name()
	match system:
		"Windows", "X11":
			config_path = OS.get_executable_path().get_base_dir() + "/Mini_Sapper.cfg"
		"Android":
			config_path = "user://Mini_Sapper.config.cfg"

#	var err = config.load("user://config.cfg")
	var err = config.load_encrypted(config_path, key)
	if err != OK:
		SETTINGS = {
			"sound_vol":     1,
			"music_vol":     0.5,
			"range_display": true,
			"theme":         17,
			"level":         1
		}
		return
	else:
		SETTINGS = config.get_value(config, "settings")






func window_prepare():
	var display_size = OS.get_screen_size()
	var window_size  = G.window

	if rec == true:
		window_size *= Vector2(.92, .92)
	else:
		window_size *= Vector2(4, 4)

	if display_size.y <= window_size.y:
		var scale_ratio = window_size.y / (display_size.y - 80)
		window_size.x /= scale_ratio ; window_size.y /= scale_ratio

	OS.window_size = window_size
	window_size.y += 78
	OS.window_position = display_size * .5 - window_size * .5






func gen_offscreen_pos(distance):
	var a      := randi() % 4 + 1
	var pos    := Vector2()
	var window := get_viewport_rect().size

	match a:
		1:    #### LEFT
			pos.x = -distance
			pos.y = rand_range(-distance, window.y + distance)
		2:    #### RIGHT
			pos.x = window.x + distance
			pos.y = rand_range(-distance, window.y + distance)
		3:    #### UP
			pos.x = rand_range(-distance, window.x + distance)
			pos.y = -distance
		4:    #### DOWN
			pos.x = rand_range(-distance, window.x + distance)
			pos.y = window.y + distance

	return pos






func findBackgroundImages():
	var num       :=  1

	var dir       := Directory.new()
	var path       = "res://assets/graphics/level_bg/OLD/"

	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file =  dir.get_next()

		while file != "":
			if file.begins_with("BG_") and file.ends_with(".png"):
				var number =  file.substr(3, file.find("_", 3) - 3)
#				print("NUMER: "+str(number))
				num += 1
			file =  dir.get_next()

		dir.list_dir_end()
	return num

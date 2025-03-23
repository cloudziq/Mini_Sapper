extends Node2D


var tiles_ready : int


var window := Vector2(
	ProjectSettings.get_setting("display/window/size/width" ),
	ProjectSettings.get_setting("display/window/size/height")
	)





var save_version  = 112211
var CONFIG
var config_path


func set_defaults():
	CONFIG = {
		"sound_vol":           1,
		"music_vol":          .6,
		"theme":               1,
		"zoom_level":          1,
		"level":               40,
		"BG_color":            Color(.1, 1, .2, 1),
		"BG_brightness":       2,  ##   1 - 5
		"tile_transparency":   .5,
		"tile_helper":         true,
		"window_pos":          [0, 0],
	}
##  Hidan's purple:    Color(.4, .1, 1, 1)  Brightness: 4





func save_config():
#	var password = "87643287643876243876241"
#	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	config.set_value("config", "save_version", save_version)
	config.set_value("config", "settings", CONFIG)

	config.save(config_path)
#	config.save_encrypted(config_path, key)






func load_config():
#	var password = "87643287643876243876241"
#	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	var system = OS.get_name()
	match system:
		"Windows", "X11":
			config_path = "res://game_config.cfg"
		"Android":
			config_path = "user://config.cfg"

	var check  = config.load(config_path)
#	var check  = config.load_encrypted(config_path, key)
	if check != OK:
		set_defaults()
	else:
		if config.get_value("config", "save_version") == save_version:
			CONFIG   = config.get_value("config", "settings")
		else:
			set_defaults()






func gen_offscreen_pos(add:float, pos:Vector2) -> Vector2:
	var a      := randi() % 4 + 1
	var dist_x :  float = (G.window.x * CONFIG.zoom_level) * .5
	var dist_y :  float = (G.window.y * CONFIG.zoom_level) * .5

	match a:
		1:    #### LEFT
			pos.x = pos.x - dist_x - add
			pos.y = rand_range(pos.y - dist_y -add, pos.y + dist_y + add)
		2:    #### RIGHT
			pos.x = pos.x + dist_x + add
			pos.y = rand_range(pos.y - dist_y -add, pos.y + dist_y + add)
		3:    #### UP
			pos.x = rand_range(pos.x - dist_x -add, pos.x + dist_x + add)
			pos.y = pos.y - dist_y - add
		4:    #### DOWN
			pos.x = rand_range(pos.x - dist_x -add, pos.x + dist_x + add)
			pos.y = pos.y + dist_y + add

	return pos






func rgb_smooth(color:Color, mod:float):
	var sum  := 0.0
	var col  := [color.r, color.g, color.b]

	for val in col:
		sum += val
	var avg = sum/col.size()

	for i in range(col.size()):
		col[i] = lerp(col[i], avg, mod)

	return Color(col[0], col[1], col[2], color.a)

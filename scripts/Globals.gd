extends Node2D


var tiles_ready : int


var window := Vector2(
	ProjectSettings.get_setting("display/window/size/width" ),
	ProjectSettings.get_setting("display/window/size/height")
	)





var save_version  = 12
var CONFIG
var config_path


func set_defaults():
	CONFIG = {
		"sound_vol":      1,
		"music_vol":      0.4,
		"theme":          1,
		"theme_style":    1,
		"zoom_level":     1,
		"level":          10,
		"tile_helper":    2,
		"BG_color":       Color(.16, .64, .98, .8),
		"tile_color":     Color(.22, .44, .66, .8)
	}






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
			CONFIG = config.get_value("config", "settings")
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

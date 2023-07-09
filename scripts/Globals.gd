extends Node2D


var tiles_ready  : int


var window := Vector2(
	ProjectSettings.get_setting("display/window/size/width" ),
	ProjectSettings.get_setting("display/window/size/height")
	)






var save_version = 2
var SETTINGS
var config_path

func save_config():
#	var password = "87643287643876243876241"
#	var key = password.sha256_buffer()
	var config = ConfigFile.new()

	config.set_value("config", "save_version", save_version)
	config.set_value("config", "settings", SETTINGS)

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

	var err  = config.load(config_path)
#	var err   = config.load(config_path)
#	var err = config.load_encrypted(config_path, key)
	if err != OK:
		set_defaults()
#		return
	else:
		if config.get_value("config", "save_version") == save_version:
			SETTINGS = config.get_value("config", "settings")
		else:
			set_defaults()


func set_defaults():
	SETTINGS = {
		"sound_vol":     1,
		"music_vol":     0.4,
		"range_display": true,
		"theme":         1,
		"zoom_level":    1,
		"level":         1
	}






func gen_offscreen_pos(distance):
	var a      := randi() % 4 + 1
	var pos    := Vector2()
#	var window := get_viewport_rect().size

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

extends Node




var window := Vector2(
	ProjectSettings.get_setting("display/window/size/width" ),
	ProjectSettings.get_setting("display/window/size/height")
	)






var save_version = 0
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
#	print(err)
#	var err   = config.load(config_path)
#	var err = config.load_encrypted(config_path, key)
	if err != OK:
		set_default_options()
#		return
	else:
#		print(config.get_value(config, save_version))
		if config.get_value("config", "save_version") == save_version:
			SETTINGS = config.get_value("config", "settings")
		else:
			set_default_options()






func set_default_options():
	SETTINGS = {
		"sound_vol":     1,
		"music_vol":     0.4,
		"range_display": true,
		"theme":         17,
		"level":         1
	}
extends Area2D

var test_num  := 0
export(PackedScene) var _particles ;  var PARTICLES


var path        := "res://assets/graphics/tiles/TILE_"
var dark_color  := Color(.24, .32, .36, 1)
var reduce_mov  := false    #for 'empty revealed' tiles only
var def_pos     :  Vector2
var def_sca     :  Vector2
var def_rot     :  float


var tween_idle  : SceneTreeTween
var tween_bump  : SceneTreeTween


onready var	theme       = G.SETTINGS.theme
onready var	theme_data  = $"../../".theme_data[theme-1]






func _ready() -> void:
#	$Sprite.z_index = -2
	tween_idle  = self.create_tween().set_trans(Tween.TRANS_LINEAR)

	$Sprite.flip_v =  true if randf() > .5 else  false
	$Sprite.flip_h =  true if randf() > .5 else  false

	yield(get_tree().create_timer(.004), "timeout")

	$Sprite.modulate = dark_color
	if theme_data[0] == 1:
		if theme_data[2] == false:
			$Sprite.texture = load(path + str(theme) + ".png")
		else:
			$Sprite.texture = load(path + str(theme) + "_OFF.png")
	else:
		var num = randi() % theme_data[0] + 1
		$Sprite.texture = load(path + str(theme) +"_"+ str(num) + ".png")

	if theme_data[1] == 1:
		rotation_degrees = 90 if randf() > .5 else 0
	else:
		rotation_degrees = rand_range(0, 360)


	#### START LEVEL TILES ANIMATION:
	def_pos  = position
	def_rot  = rotation_degrees
	def_sca  = scale * 0.92

	position          = G.gen_offscreen_pos(125)
	rotation_degrees  = randi() % 361
	var a             : float = rand_range(.8, 4.2)
	scale             = Vector2(a, a)

	#1
	a  = rand_range(.42, .88)
	tween_idle.set_parallel(true)
	tween_idle.tween_property(self, "position", def_pos, a
		).set_ease(Tween.EASE_IN)

	tween_idle.tween_callback($TileMain, "play").set_delay(a)

	tween_idle.tween_property(self, "rotation_degrees", def_rot, rand_range(.20, .32)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween_idle.tween_property(self, "scale", def_sca, .4
		).set_ease(Tween.EASE_OUT)

	#2
	tween_idle.tween_interval(.12)
	tween_idle.set_parallel(false)
	tween_idle.tween_property(self, "scale", def_sca * .4, .4
		).set_ease(Tween.EASE_IN)

	tween_idle.tween_property(self, "scale", def_sca, .6
		).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	tween_idle.set_parallel(true)
	tween_idle.tween_callback(self, "tile_finish").set_delay(.16)






func tile_finish() -> void:
	var num : Array  = $"../../".level_data[G.SETTINGS.level-1]

	G.tiles_ready  += 1
	if G.tiles_ready == (num[0] * num[1]):
		get_parent().allow_board_input  = true
#		animate_tile(-1)
		G.tiles_ready  = 0
#	else:
#		animate_tile()

	if theme_data[2] == false:
		$Sprite.modulate  = Color(1,1,1,1)
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	idle_animate(-1)
	yield(get_tree().create_tween().tween_interval(.2), "finished")
	idle_animate(1)






# type:
#  -1  : init
#	0  : position
#	1  : rotation

func idle_animate(type := 0) -> void:
	var pos        := def_pos
	var rot        := def_rot

	if tween_idle and type == -1:
		tween_idle.kill()
	tween_idle  = self.create_tween()

	if type <= 0:
		var distance  := 3.2 if not reduce_mov else 1.6
		pos.x         += rand_range(-distance, distance)
		pos.y         += rand_range(-distance, distance)

		tween_idle.tween_property(self, "position", pos, rand_range(6, 8)
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_idle.tween_callback(self, "idle_animate").set_delay(.2)


	elif type == 1:
		var angle := 22
		rot       += rand_range(-angle, angle)

		tween_idle.tween_property(self, "rotation_degrees", rot, rand_range(6, 10)
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween_idle.tween_callback(self, "idle_animate", [1]).set_delay(.2)






func bump_tile():
	var i  : float
	i  = rand_range(-.04, .02)
	var s_min  : Vector2  = def_sca * 0.40 + Vector2(i, i)
	i  = rand_range(-.02, .06)
	var s_max  : Vector2  = def_sca * 1.16 + Vector2(i, i)

	if tween_bump:  tween_bump.kill()
	tween_bump  = self.create_tween()

	tween_bump.tween_property(self, "scale", s_min, .16 + rand_range(-.02, .04)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween_bump.tween_property(self, "scale", s_max, .22 + rand_range(-.04, .04)
		).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(.12)
	tween_bump.tween_property(self, "scale", def_sca, .64 + rand_range(-.06, .04)
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.04)






func reveal(counter := 0) -> void:
	var col      :  Color
	var delay    := rand_range(.12, .28)
	var scale_to :  Vector2
	var trans    :  int
	var time_mod :  float

	if theme_data[2] == false:
		$Sprite.modulate  = dark_color
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	if tween_idle:  tween_idle.kill()
	tween_idle    = self.create_tween().set_parallel(true)

	if counter == 0:
	#if tile have 0 bomb count
		reduce_mov  = true
		scale_to    = Vector2(.1, .1)
		trans       = Tween.TRANS_BOUNCE
		col         = $Sprite.modulate
		time_mod    = rand_range(-.8, .8)

		if $Sprite.material.blend_mode == BLEND_MODE_MIX:
			col.a  *= .22
		else:
			col.a  *= .36

		tween_idle.tween_property($Sprite, "modulate", col, 3.24 + time_mod
			).set_trans(trans).set_ease(Tween.EASE_OUT).set_delay(delay)

	else:
	#if tile have any number
		var mult    = counter * .02
		scale_to    = Vector2(.125, .125) + Vector2(mult, mult)
		trans       = Tween.TRANS_ELASTIC
		time_mod    = rand_range(-.4, .4)

		PARTICLES = _particles.instance()
		add_child(PARTICLES)
#		PARTICLES.show(counter)

	#for any tile:
	tween_idle.tween_property(self, "scale", scale_to, 3.24 + time_mod
		).set_trans(trans).set_ease(Tween.EASE_OUT).set_delay(delay)






func _on_Area2D_area_shape_entered(_a, _b, _c, _d):
	get_parent().check_clicked_tile()
#	b.set_deferred("monitorable", false)






func _exit_tree():
	queue_free()

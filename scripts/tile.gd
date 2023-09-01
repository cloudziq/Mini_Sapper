extends Area2D


####  NOTES:
####  sprawdzić czy allow_idle_anim jest potrzebne w ogóle
####  i czy w idle_anim jest potrzebne match = -1


export(PackedScene) var _particles ;  var PARTICLES


var path        := "res://assets/graphics/tiles/TILE_"
var dark_color  := Color(.24, .32, .36, 1)
var reduce_mov  := false    #for 'empty revealed' tiles only
var reduce_rot  := false    #for revealed tiles with > 0 count only
var num_tiles   :  int
var def_pos     :  Vector2
var def_sca     :  Vector2
var def_col     :  Color
var def_rot     :  float


var tween_io    : SceneTreeTween
var tween_idle  : SceneTreeTween
var tween_bump  : SceneTreeTween
var tween_rev   : SceneTreeTween


var allow_idle_anim := false

onready var	theme       = G.SETTINGS.theme
onready var	theme_data  = $"../../".theme_data[theme-1]






func _ready() -> void:
	PARTICLES         = _particles.instance()

	$Sprite.flip_v    = true if randf() > .5 else  false
	$Sprite.flip_h    = true if randf() > .5 else  false

	$Sprite.modulate             = dark_color
	$Sprite.modulate.a           = 0
	$Sprite.material.blend_mode  = G.SETTINGS.theme_style

	if theme_data[0] == 1:
		if theme_data[2] == false:
			$Sprite.texture = load(path + str(theme) + ".png")
		else:
			$Sprite.texture = load(path + str(theme) + "_OFF.png")
	else:
		var a = randi() % theme_data[0] + 1
		$Sprite.texture = load(path + str(theme) +"_"+ str(a) + ".png")

	if theme_data[1] == 1:
		rotation_degrees = 90 if randf() > .5 else 0
	else:
		rotation_degrees = rand_range(0, 360)

	add_child(PARTICLES)
	io_anim()






func io_anim(type := 0) -> void:
	if type == 0:
		def_pos  = position
		def_rot  = rotation_degrees
		def_sca  = scale * 0.92

		var node : Camera2D = get_parent().get_node("ZoomCam")
		var a    := rand_range(.1, .6)

		position          = G.gen_offscreen_pos(60, node.position)
		rotation_degrees  = rand_range(-360, 360)
		scale             = Vector2(a, a)
		allow_idle_anim   = true


		#PHASE 1:
		tween_io  = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		tween_io.set_parallel(true)
		tween_io.tween_property(self, "rotation_degrees", def_rot, rand_range(.64, 1.22)
			).set_delay(.2)

		tween_io.tween_property(self, "scale", def_sca, .44)

		a  = rand_range(.62, 1.1)
		tween_io.tween_property(self, "position", def_pos, a)

		var col   = $Sprite.modulate  ;  col.a  = 1
		var time  =  1.1
		tween_io.tween_property($Sprite, "modulate", col, time - (time*.1))

		#tile spawn sound
		if OS.get_system_time_msecs() >= get_parent().sound_timeout:
			get_parent().sound_timeout  = OS.get_system_time_msecs() + 12
			tween_io.tween_callback(get_parent().get_node("TileMain"), "play").set_delay(a)


		#PHASE 2:
		tween_io.set_parallel(false)
		tween_io.tween_property(self, "scale", def_sca * .4, .22).set_ease(Tween.EASE_IN)

		tween_io.tween_property(self, "scale", def_sca, .16
			).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

		tween_io.tween_callback(self, "tile_ready").set_delay(.012)


	else:
		var time         = rand_range(.8, 1.2)
		var node         = get_parent().get_node("ZoomCam")
		def_pos          = G.gen_offscreen_pos(20, node.position)
		allow_idle_anim  = false

		tween_io  = self.create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween_io.tween_property(self, "position", def_pos, time)
		var col  = modulate ; col.a    = 0
		tween_io.parallel().tween_property(self, "modulate", col, time - (time*.1))
		tween_io.tween_callback(self, "tile_ready", [false])






# type:
# true   = intro
# false  = outro
func tile_ready(type := true) -> void:
	G.tiles_ready  += 1

	if type:
		if G.tiles_ready == get_parent().num_tiles:
			get_parent().allow_board_input  = true
			G.tiles_ready  = 0

		if theme_data[2] == false:
			var dist  = .1
			var col   = G.SETTINGS.tile_color

			col.r += rand_range(-dist, dist)
			col.g += rand_range(-dist, dist)
			col.b += rand_range(-dist, dist)
			$Sprite.modulate  = col
			def_col           = col
		else:
			$Sprite.texture   = load(path + str(theme) + "_ON.png")

		idle_anim([0, 1])
	else:
		if G.tiles_ready == get_parent().num_tiles:
			G.tiles_ready  = 0
			yield(get_tree().create_timer(.1), "timeout")
			get_parent()._ready()
		queue_free()






# type:
#  -1  : init
#	0  : position
#	1  : rotation

func idle_anim(type_list := [0]) -> void:
	var pos        := def_pos
	var rot        := def_rot

	for type in type_list:
		if allow_idle_anim:
			tween_idle = self.create_tween().set_trans(
				Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

			match type:
				0:
					var distance  := 3.2 if not reduce_mov else 1.6
					pos.x         += rand_range(-distance, distance)
					pos.y         += rand_range(-distance, distance)

					tween_idle.tween_property(self, "position", pos, rand_range(6, 8))
					tween_idle.tween_callback(self, "idle_anim").set_delay(.2)
				1:
					rot += rand_range(-22, 22)
					if reduce_rot:
						rot *= .46

					tween_idle.tween_property(self, "rotation_degrees", rot, rand_range(6, 10))
					tween_idle.tween_callback(self, "idle_anim", [[1]]).set_delay(.2)






func reveal(counter : int) -> void:
	var delay    := rand_range(.12, .28)
	var scale_to :  Vector2
	var trans    :  int
	var time_mod :  float

	if theme_data[2] == false:
		$Sprite.modulate  = dark_color
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	tween_rev  = self.create_tween().set_ease(Tween.EASE_OUT).set_parallel()

	if counter == 0:
		scale_to    = Vector2(.1, .1)
		trans       = Tween.TRANS_BOUNCE
		time_mod    = rand_range(-.8, .8)

		change_tile_alpha(.22, .36, time_mod, delay, trans)

	else:
		var mult    = counter * .02
		scale_to    = Vector2(.125, .125) + Vector2(mult, mult)
		trans       = Tween.TRANS_ELASTIC
		time_mod    = rand_range(-.4, .4)
		reduce_mov  = true
		reduce_rot  = true

		add_tile_particles(0)
		change_tile_alpha(.46, .92, time_mod, delay, trans)

	tween_rev.tween_property(self, "scale", scale_to, 3.24 + time_mod
		).set_trans(trans).set_delay(delay)






func change_tile_alpha(mix:float, add:float, time:float, delay:float, trans:int) -> void:
	var col : Color

	bump_tile(-1)
	col  = $Sprite.modulate

	if $Sprite.material.blend_mode == BLEND_MODE_MIX:
		col.a  *= mix
	else:
		col.a  *= add

	tween_rev.tween_property($Sprite, "modulate", col, 3.24 + time
		).set_trans(trans).set_delay(delay)




# type:
#  0: original tile
#  1: neighbour tile
# -1: recolour (in case tile become revealed)
func bump_tile(type := 0) -> void:

	match type:
		0:
			og_tile_shake_anim(4)
		1:
			var ttl    : float  = 3.2

			var i      : float
			i  = rand_range(-.04, .02)
			var s_min  : Vector2  = def_sca * 0.40 + Vector2(i, i)
			i  = rand_range(-.02, .06)
			var s_max  : Vector2  = def_sca * 1.16 + Vector2(i, i)

			if tween_bump:  tween_bump.kill()
			tween_bump  = self.create_tween()

			var col  = def_col
			col.r   *= 8
			col.g   *= 4.4
			col.b   *= .4

			tween_bump.tween_property(self, "scale", s_min, .16 + rand_range(-.02, .04)
				).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

			tween_bump.tween_property(self, "scale", s_max, .22 + rand_range(-.04, .04)
				).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(.06)

			tween_bump.tween_property(self, "scale", def_sca, .48 + rand_range(-.04, .02)
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.06)

			tween_bump.parallel().tween_property($Sprite, "modulate", col,
				.36 + rand_range(-.04, .04)
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)

			#### PARTICLES ####
			tween_bump.parallel().tween_callback(self, "add_tile_particles", [1])

			tween_bump.tween_property($Sprite, "modulate", def_col,
				ttl + rand_range(-ttl * .14 , ttl * .12)
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)
		-1:
			if tween_bump:  tween_bump.kill()






func og_tile_shake_anim(count : int):
	var x           := rand_range(-4, 4)
	var y           := rand_range(-4, 4)
	var new_pos     := position + Vector2(x, y)
	var speed_scale := .4

	tween_bump   = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_bump.tween_property(self, "position", new_pos, rand_range(.1, .16) * speed_scale
		)
	tween_bump.tween_property(self, "position", def_pos, rand_range(.06, .1) * speed_scale
		)

	if count > 0:
		tween_bump.tween_callback(self, "og_tile_shake_anim", [count-1])






func add_tile_particles(type := 0) -> void:
	var p_small : CPUParticles2D =  PARTICLES.get_node("particles_small")
	var p_blink : CPUParticles2D =  PARTICLES.get_node("particles_blink")

	if type == 0:
		p_small.one_shot    = true
		p_blink.one_shot    = true
		p_small.emitting    = true
		p_blink.emitting    = true
	else:
		p_small.preprocess  = 0.44
		p_small.one_shot    = true
		p_small.emitting    = true
		p_small.modulate.a  = .42
		p_small.speed_scale = .24
		p_small.restart()






func _on_Area2D_area_shape_entered(_a, _b, _c, _d):
	get_parent().check_clicked_tile()
#	b.set_deferred("monitorable", false)






func _exit_tree():
	G.SETTINGS.theme_style = $Sprite.material.blend_mode
#	if tween_idle : tween_idle.kill()
#	if tween_bump : tween_bump.kill()
#	if tween_rev1 : tween_rev1 .kill()
#	if tween_rev2 : tween_rev2 .kill()
#   chujicipatozgranaekipa


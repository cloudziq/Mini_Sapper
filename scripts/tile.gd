extends Area2D


####  NOTES:
####  sprawdzić czy allow_idle_anim jest potrzebne w ogóle
export(PackedScene) var _particles ;  var PARTICLES


var path        := "res://assets/graphics/tiles/TILE_"
var dark_color  := Color(.24, .32, .36, 1)
var reduce_mov  := false    #for 'empty revealed' tiles only
var reduce_rot  := false    #for revealed tiles with > 0 count only
var def_pos     :  Vector2
var def_sca     :  Vector2
var def_rot     :  float


var tween_idle  : SceneTreeTween
var tween_bump  : SceneTreeTween
var tween_rev   : SceneTreeTween


var allow_idle_anim := false

onready var	theme       = G.SETTINGS.theme
onready var	theme_data  = $"../../".theme_data[theme-1]






func _ready() -> void:
	PARTICLES         = _particles.instance()
	tween_idle        = self.create_tween().set_trans(Tween.TRANS_LINEAR)

	$Sprite.flip_v    = true if randf() > .5 else  false
	$Sprite.flip_h    = true if randf() > .5 else  false

	$Sprite.modulate             = dark_color
	$Sprite.material.blend_mode  = G.SETTINGS.theme_style

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

	allow_idle_anim  = true
	io_anim()





func io_anim(type := 0) -> void:
	if type == 0:
		def_pos  = position
		def_rot  = rotation_degrees
		def_sca  = scale * 0.92

		position          = G.gen_offscreen_pos(100, Vector2.ZERO)
		rotation_degrees  = randi() % 361
		var a            := rand_range(.1, .6)
		scale             = Vector2(a, a)


		#phase 1
		tween_idle.set_parallel(true)
		tween_idle.tween_property(self, "rotation_degrees", def_rot, rand_range(.44, .82)
			).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.2)

		tween_idle.tween_property(self, "scale", def_sca, .44
			).set_ease(Tween.EASE_OUT)

		a  = rand_range(.26, .68)
		tween_idle.tween_property(self, "position", def_pos, a
			).set_ease(Tween.EASE_OUT)

		#tile spawn sound:
		if OS.get_system_time_msecs() >= get_parent().sound_timeout:
			get_parent().sound_timeout  = OS.get_system_time_msecs() + 10
			tween_idle.tween_callback(get_parent().get_node("TileMain"), "play").set_delay(a)

		#phase 2
		tween_idle.set_parallel(false)
		tween_idle.tween_property(self, "scale", def_sca * .4, .22
			).set_ease(Tween.EASE_IN)

		tween_idle.tween_property(self, "scale", def_sca, .16
			).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

		tween_idle.tween_callback(self, "tile_ready").set_delay(.012)

	else:
		var time  = rand_range(.26, .68)
		def_pos   = G.gen_offscreen_pos(100, position)
		allow_idle_anim  = false

		if tween_idle:
			tween_idle.kill()
		tween_idle = self.create_tween().set_trans(
			Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

		tween_idle.tween_property(self, "position", def_pos, time)
		tween_idle.tween_callback(self, "queue_free")





func tile_ready() -> void:
	var num       : Array  = $"../../".level_data[G.SETTINGS.level-1]
	var num_tiles : int    = (num[0] * num[1]) * .1

	G.tiles_ready  += 1
	if G.tiles_ready >= num_tiles:
		get_parent().allow_board_input  = true
		G.tiles_ready  = 0

	if theme_data[2] == false:
		var dist  = .1
		var col   = G.SETTINGS.tile_color

		col.r += rand_range(-dist, dist)
		col.g += rand_range(-dist, dist)
		col.b += rand_range(-dist, dist)
		$Sprite.modulate  =  col
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	idle_anim([-1, 1])






# type:
#  -1  : init
#	0  : position
#	1  : rotation

func idle_anim(type_list := [0]) -> void:
	var pos        := def_pos
	var rot        := def_rot


	for type in type_list:
		if type == -1 and tween_idle:
			tween_idle.kill()
		tween_idle = self.create_tween().set_trans(
			Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		match type:
			0, -1:
				var distance  := 3.2 if not reduce_mov else 1.6
				pos.x         += rand_range(-distance, distance)
				pos.y         += rand_range(-distance, distance)

				tween_idle.tween_property(self, "position", pos, rand_range(6, 8)
					)
				tween_idle.tween_callback(self, "idle_anim").set_delay(.2)
			1:
				rot += rand_range(-22, 22)
				if reduce_rot:
					rot *= .46

				tween_idle.tween_property(self, "rotation_degrees", rot, rand_range(6, 10)
					)
				if allow_idle_anim:
					tween_idle.tween_callback(self, "idle_anim", [[1]]).set_delay(.2)






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

	tween_rev    = self.create_tween().set_parallel(true)

	if counter == 0:
		scale_to    = Vector2(.1, .1)
		trans       = Tween.TRANS_BOUNCE
		col         = $Sprite.modulate
		time_mod    = rand_range(-.8, .8)

		if $Sprite.material.blend_mode == BLEND_MODE_MIX:
			col.a  *= .22
		else:
			col.a  *= .36

		tween_rev.tween_property($Sprite, "modulate", col, 3.24 + time_mod
			).set_trans(trans).set_ease(Tween.EASE_OUT).set_delay(delay)

	else:
		var mult    = counter * .02
		scale_to    = Vector2(.125, .125) + Vector2(mult, mult)
		trans       = Tween.TRANS_ELASTIC
		time_mod    = rand_range(-.4, .4)

		add_tile_particles(0)
		reduce_mov  = true
		reduce_rot  = true


	tween_rev.tween_property(self, "scale", scale_to, 3.24 + time_mod
		).set_trans(trans).set_ease(Tween.EASE_OUT).set_delay(delay)






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

			var mod  = G.SETTINGS.tile_color
			var def  = mod
			mod.r   *= 8
			mod.g   *= 4.4
			mod.b   *= .4

			tween_bump.tween_property(self, "scale", s_min, .16 + rand_range(-.02, .04)
				).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

			tween_bump.tween_property(self, "scale", s_max, .22 + rand_range(-.04, .04)
				).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT_IN).set_delay(.06)

			tween_bump.tween_property(self, "scale", def_sca, .48 + rand_range(-.04, .02)
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.06)

			tween_bump.parallel().tween_property($Sprite, "modulate", mod,
				.36 + rand_range(-.04, .04)
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)

			#### PARTICLES ####
			tween_bump.parallel().tween_callback(self, "add_tile_particles", [1])

			tween_bump.tween_property($Sprite, "modulate", def,
				ttl + rand_range(-ttl * .14 , ttl * .12)
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(.01)
		-1:
			var col  = $Sprite.modulate

			if tween_bump:  tween_bump.kill()
			tween_bump  = self.create_tween()

			tween_bump.tween_property($Sprite, "modulate", col, 1
				).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)




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






func add_tile_particles(type := 0) ->void:
	add_child(PARTICLES)
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
		p_small.modulate.a  = .068
		p_small.speed_scale = .24
		p_small.restart()






func _on_Area2D_area_shape_entered(_a, _b, _c, _d):
	get_parent().check_clicked_tile()
#	b.set_deferred("monitorable", false)






func _exit_tree():
	G.SETTINGS.theme_style = $Sprite.material.blend_mode
	if tween_idle : tween_idle.kill()
	if tween_bump : tween_bump.kill()
	if tween_rev  : tween_rev .kill()
#   chujicipatozgranaekipa


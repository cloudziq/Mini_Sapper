extends Area2D




export(PackedScene) var _particles ;  var PARTICLES
export(PackedScene) var _bump      ;  var BUMP


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

onready var	theme       = G.CONFIG.theme
onready var	theme_data  = $"../../".theme_data[theme-1]






func _ready() -> void:
	$Sprite.flip_v    = true if randf() > .5 else  false
	$Sprite.flip_h    = true if randf() > .5 else  false

	$Sprite.modulate             = dark_color
	$Sprite.modulate.a           = 0
	$Sprite.material.blend_mode  = G.CONFIG.theme_style

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

	io_anim()






func io_anim(type := 0) -> void:
	if type == 0:
		var node : Camera2D = get_parent().get_node("ZoomCam")
		var a    := rand_range(.1, .6)

		var col   = $Sprite.modulate  ;  col.a  = def_col.a
		var time  =  .8

		def_pos  = position
		def_rot  = rotation_degrees
		def_sca  = scale * 0.92

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
		var time         = rand_range(.4, .6)
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
		if theme_data[2] == false:
			var dist  = .1
			var col   = G.CONFIG.tile_color

			col.r += rand_range(-dist, dist)
			col.g += rand_range(-dist, dist)
			col.b += rand_range(-dist, dist)
			$Sprite.modulate  = col
			def_col           = col

			if G.tiles_ready == get_parent().num_tiles:
				get_parent().reveal_starter_tiles()
				get_parent().allow_board_input  = true
				G.tiles_ready  = 0
		else:
			$Sprite.texture   = load(path + str(theme) + "_ON.png")

		idle_anim([0, 1])
	else:
		if G.tiles_ready == get_parent().num_tiles:
			G.tiles_ready  = 0
			yield(get_tree().create_timer(1), "timeout")
			for i in get_tree().get_nodes_in_group("tile"):
				i.queue_free()
			get_parent()._ready()    ## start the level in level_main






# type:
#  -1  : init
#	0  : position
#	1  : rotation

func idle_anim(type_list := [0]) -> void:
	var pos        := def_pos
	var rot        := def_rot

	if allow_idle_anim:
		tween_idle = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		for type in type_list:
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






func reveal(counter:int) -> void:
	var delay    : float
	var trans    : int
	var time_mod : float
	var scale_to : Vector2

	if theme_data[2] == false:
		$Sprite.modulate  = dark_color
	else:
		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	tween_rev  = self.create_tween().set_ease(Tween.EASE_OUT).set_parallel()

	if counter == 0:
		scale_to    = Vector2(.1, .1)
		trans       = Tween.TRANS_BOUNCE
		time_mod    = rand_range(-.8, .8)
		delay       = rand_range(.12, .28)

		change_alpha(.22, .36, time_mod, delay, trans)

	else:
		var mult    = counter * .02
		scale_to    = Vector2(.125, .125) + Vector2(mult, mult)
		trans       = Tween.TRANS_ELASTIC
		time_mod    = rand_range(-.6, .6)
		delay       = rand_range(.06, .1)
		reduce_mov  = true
		reduce_rot  = true

		change_alpha(.46, .92, time_mod, delay, trans)
		tile_particle_spawn()

	tween_rev.tween_property(self, "scale", scale_to, 3.24 + time_mod
		).set_trans(trans).set_delay(delay)






func change_alpha(mix:float, add:float, time:float, delay:float, trans:int) -> void:
	var col : Color

	col  = $Sprite.modulate

	if $Sprite.material.blend_mode == BLEND_MODE_MIX:
		col.a  *= mix
	else:
		col.a  *= add

	tween_rev.tween_property($Sprite, "modulate", col, 3.24 + time
		).set_trans(trans).set_delay(delay)






func tile_helper_spawn() -> void:
	BUMP  = _bump.instance()
	add_child(BUMP)
	tile_particle_spawn(true)






func tile_particle_spawn(type:=false) -> void:
	var node1 : CPUParticles2D
	var node2 : CPUParticles2D

	PARTICLES  = _particles.instance()
	add_child(PARTICLES)

	if type:    #### tile_helper
		node1              = PARTICLES.get_node("particles_small")
		node1.emitting     = true
		node1.modulate.a   = .40
		node1.speed_scale  = .22
		node1.scale        = Vector2(2,2)
	else:       #### normal reveal
		node1              = PARTICLES.get_node("particles_small")
		node1.emitting     = true
		node1.modulate.a   = .40
		node1.speed_scale  = 1.6
		node1.scale        = Vector2(2,2)

		node2              = PARTICLES.get_node("particles_blink")
		node2.emitting     = true
		node2.modulate.a   = .20
		node2.speed_scale  = .11







func og_tile_shake_anim(count:int, shake_speed:float):
	var dist        := 4
	var x           := rand_range(-dist, dist)
	var y           := rand_range(-dist, dist)
	var new_pos     := position + Vector2(x, y)

	tween_bump   = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween_bump.tween_property(self, "position", new_pos, rand_range(.1, .16) * shake_speed)
	tween_bump.tween_property(self, "position", def_pos, rand_range(.06, .1) * shake_speed)

	if count > 0:
		tween_bump.tween_callback(self, "og_tile_shake_anim", [count-1, shake_speed])






func tile_blast() -> void:
	var node      : Node2D = get_parent().get_node("bomb_explosion")
	var dir       = global_position.direction_to(node.global_position)
	var dist      = position.distance_to(node.global_position)
#	var strength  = .4
	var factor    = 1 - (dist / node.max_blast_range)
	var new_pos   = global_position -dir * factor * 260 * rand_range(factor*.6, factor)
	var t_pos     = self.create_tween()

	allow_idle_anim  = false
	tween_idle.kill()

	var time  = factor * (dist * .02) * rand_range(factor*.68, factor*.84)
	t_pos.tween_property(self, "position", new_pos, time)
	t_pos.tween_callback(self, "tile_ready", [false])






func _on_touch_collision(_a, _b, _c, _d):
		get_parent().check_clicked_tile()

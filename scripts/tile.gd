extends Area2D




export(PackedScene) var _particles ;  var PARTICLES
export(PackedScene) var _bump      ;  var BUMP

onready var shader_revealed  = preload("res://assets/shaders/blur.shader")


var velocity     = Vector2.ZERO
var v_velocity   = 0.0
var z_offset     = 0.0

var path        := "res://assets/graphics/tiles/TILE_"
#var dark_color  := Color(.24, .32, .36, .6)
var reduce_mov  := false    #for 'empty revealed' tiles only
var reduce_rot  := false    #for revealed tiles with > 0 count only
var num_tiles   :  int
var def_pos     :  Vector2
var def_sca     :  Vector2
var def_col     :  Color = G.CONFIG.BG_color * .62
var def_rot     :  float


var tween_io    : SceneTreeTween
var tween_idle  : SceneTreeTween
var tween_bump  : SceneTreeTween
var tween_rev   : SceneTreeTween
var tween_col   : SceneTreeTween


var allow_idle_anim  := false
var allow_color_anim := true

onready var	theme       = G.CONFIG.theme
onready var	theme_data  = $"../../".theme_data[theme-1]






func _ready() -> void:
	set_physics_process(false)
	def_col.a  = G.CONFIG.tile_transparency

	$Sprite.flip_v    = true if randf() > .5 else  false
	$Sprite.flip_h    = true if randf() > .5 else  false

	$Sprite.modulate             = Color(.4, .4, .4, 0)
#	$Sprite.modulate.a           = 0
#	$Sprite.material.blend_mode  = G.CONFIG.theme_style

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






func _physics_process(delta: float) -> void:
	var damp := 6
	var gravity       = -1600
	var max_scale     = 4
	var max_z_offset = 200.0

	global_position += velocity *delta
	velocity = velocity.linear_interpolate(Vector2.ZERO, damp *delta)

	v_velocity += gravity *delta
	z_offset   += v_velocity *delta

	if z_offset < 0:
		z_offset  = 0
		v_velocity  = -v_velocity *damp *.1

	var t            = clamp(z_offset /max_z_offset, 0, 1)
	var scale_factor = lerp(1, max_scale, t)
	$Sprite.scale = Vector2(scale_factor, scale_factor)






func io_anim(type := 0) -> void:
	if type == 0:
		var node : Camera2D = get_parent().get_node("ZoomCam")
		var a    := rand_range(.1, .8)

		var col   = $Sprite.modulate  ;  col.a  = def_col.a
#		var time  =  .8

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
		tween_io.tween_property(self, "rotation_degrees", def_rot,
			rand_range(.64, 1.82)).set_delay(.2)

		tween_io.tween_property(self, "scale", def_sca, .3)

		a  = rand_range(.62, 1.1)
		tween_io.tween_property(self, "position", def_pos, a)

#		col.a = .4
#		$Sprite.modulate  = col
#		tween_io.tween_property($Sprite, "modulate", col, time - (time*.1))
		tile_color_anim_accents(.22, .72, 3, true)


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
		var col  = modulate ; col.a  = 0
		tween_io.parallel().tween_property(self, "modulate", col, time - (time*.1))
		tween_io.tween_callback(self, "tile_ready", [false])






#### type:
#### true  = intro        false  = outro
func tile_ready(type := true) -> void:
	G.tiles_ready  += 1

	if type:
		if G.tiles_ready == get_parent().num_tiles:
			get_parent().reveal_starter_tiles()
			get_parent().allow_board_input  = true
			G.tiles_ready  = 0

		idle_anim([0, 1])
	else:
		if G.tiles_ready == get_parent().num_tiles:
			G.tiles_ready  = 0
			yield(get_tree().create_timer(2), "timeout")
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
	var time       := rand_range(4, 6)

	if allow_idle_anim:
		tween_idle = self.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		for type in type_list:
			match type:
				0:
					var scale_temp :  Vector2 = $Sprite.scale
					var distance   := 3.6 if not reduce_mov else 2.8
					pos.x         += rand_range(-distance, distance)
					pos.y         += rand_range(-distance, distance)

					tween_idle.tween_property(self, "position", pos, time)

					tween_idle.tween_property(
						$Sprite, "scale", $Sprite.scale *rand_range(.8, 1.1), time *.5)
					tween_idle.chain().tween_property(
						$Sprite, "scale", scale_temp, time *.5).set_delay(time *.2)

					tween_idle.tween_callback(self, "idle_anim").set_delay(time *.2)
				1:
					rot += rand_range(-28, 28)
					if reduce_rot:
						rot *= .4

					tween_idle.tween_property(self, "rotation_degrees", rot, time)
					tween_idle.tween_callback(self, "idle_anim", [[1]]).set_delay(time *.2)
#				2:
#					var col  = G.CONFIG.BG_color
#					tween_idle.tween_property($Sprite, "material:shader_param/aura_color", col, 2)






func tile_color_anim_accents(dist:float, smoothness:float, time:float, init:=false) -> void:
	var col  : Color = def_col
	var t    := time *.4

	tween_col  = self.create_tween().set_trans(1).set_ease(2)
	col.r   += rand_range(-dist *.6, dist)
	col.g   += rand_range(-dist *.6, dist)
	col.b   += rand_range(-dist *.6, dist)
	col.a   *= G.CONFIG.tile_transparency
	col      = G.rgb_smooth(col, smoothness)
	time     = rand_range(time -t, time +t)

	tween_col.tween_property($Sprite, "modulate", col, time)

	tween_col.tween_property(
		$Sprite, "material:shader_param/aura_width", int(rand_range(2, 10)), time *.5)
	tween_col.chain().tween_property(
		$Sprite, "material:shader_param/aura_width", 5, time *.5)

	time  *= 2 if not init else 1
	if allow_color_anim:
		tween_col.tween_callback(self, "tile_color_anim_accents", [dist, smoothness, time])






func reveal(counter:int) -> void:
	var delay    : float
	var trans    : int
	var time_mod : float
	var scale_to : Vector2

#	if theme_data[2] == false:
#		$Sprite.modulate  = dark_color
#	else:
#		$Sprite.texture   = load(path + str(theme) + "_ON.png")

	tween_rev  = self.create_tween().set_ease(Tween.EASE_OUT).set_parallel()

	if counter == 0:
		scale_to    = Vector2(.1, .1)
		trans       = Tween.TRANS_BOUNCE
		time_mod    = rand_range(-.8, .8)
		delay       = rand_range(.12, .28)

		change_alpha(time_mod, delay, trans, .28)

	else:
		var mult    = counter * .02
		scale_to    = Vector2(.125, .125) + Vector2(mult, mult)
		trans       = Tween.TRANS_ELASTIC
		time_mod    = rand_range(-.6, .6)
		delay       = rand_range(.06, .1)
		reduce_mov  = true
		reduce_rot  = true

		change_alpha(time_mod, delay, trans, .4)
		tile_particle_spawn()

	tween_rev.tween_property(self, "scale", scale_to, 3.24 + time_mod
		).set_trans(trans).set_delay(delay)

	## blur material applied:
	var mat  := ShaderMaterial.new()
	mat.shader = shader_revealed
	mat.set_shader_param("radius", 6)
	$Sprite.material  = mat

	if tween_col: tween_col.kill()






func change_alpha(time:float, delay:float, trans:int, mod:=1.0) -> void:
	var col := def_col
	col.a   *= mod

	tween_rev.tween_property($Sprite, "modulate", col, time
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






func tile_blast(pos:Vector2) -> void:
	var radius        = 600.0
	var power         = rand_range(600, 1200)
	var bounce_power  = rand_range(250, 600)

	var diff          = global_position -pos
	var distance      = diff.length()

	allow_idle_anim   = false
	allow_color_anim  = false
	tween_idle.kill()
	tile_ready(false)
	set_physics_process(true)

	if distance < radius:
		var factor  = 1.0 -(distance /radius)
		velocity    = diff.normalized() *power *factor
		v_velocity  = bounce_power *factor

		$Sprite.rotation_degrees  = rand_range(-40, 40)







func _on_touch_collision(_a, _b, _c, _d):
	get_parent().check_clicked_tile()

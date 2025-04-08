extends Area2D




export(PackedScene) var _particles_main ;  var PARTICLES_main
export(PackedScene) var _particles_move ;  var PARTICLES_move
export(PackedScene) var _bump      ;  var BUMP

onready var shader_revealed    = preload("res://assets/shaders/blur.shader")
onready var level              = get_parent()
onready var tile_bounce_sound  : AudioStreamPlayer = $"../sounds/TileBounce"

var velocity    := Vector2.ZERO
var v_velocity  := 0.0
var z_offset    := 0.0

var path        := "res://assets/graphics/tiles/TILE_"
var reduce_mov  := false    #for 'empty revealed' tiles only
var reduce_rot  := false    #for tiles with revealed numbers
var num_tiles   :  int
var def_pos     :  Vector2
var def_sca     :  Vector2
var def_col     :  Color = G.CONFIG.BG_color *.62
var def_rot     :  float


var tween_io    : SceneTreeTween
var tween_idle  : SceneTreeTween
var tween_bump  : SceneTreeTween
var tween_rev   : SceneTreeTween
var tween_col   : SceneTreeTween


var allow_idle_anim      := false
var allow_color_anim     := false
#var allow_move_particles := false

onready var	theme       = G.CONFIG.theme
onready var	theme_data  = $"../../".theme_data[theme-1]






func _ready() -> void:
	set_physics_process(false)
	def_col.a  = G.CONFIG.tile_transparency

#	allow_move_particles  = false

	$"%Sprite".flip_v    = true if randf() > .5 else  false
	$"%Sprite".flip_h    = true if randf() > .5 else  false
	$"%Sprite".modulate  = Color(.4, .4, .4, 0)

	if theme_data[0] == 1:
		if theme_data[2] == false:
			$"%Sprite".texture = load(path + str(theme) + ".png")
		else:
			$"%Sprite".texture = load(path + str(theme) + "_OFF.png")
	else:
		var a = randi() % theme_data[0] + 1
		$"%Sprite".texture = load(path + str(theme) +"_"+ str(a) + ".png")

	if theme_data[1] == 1:
		rotation_degrees = 90 if randf() > .5 else 0
	else:
		rotation_degrees = rand_range(0, 360)






# only for explosion handling:
func _physics_process(delta: float) -> void:
	var damp         := 4
	var gravity      := -2000
	var max_scale    := 4
	var max_z_offset := 200.0

	global_position += velocity *delta
	velocity = velocity.linear_interpolate(Vector2.ZERO, damp *delta)

	v_velocity += gravity *delta
	z_offset   += v_velocity *delta

	if z_offset < 0:
		z_offset    = 0
		v_velocity  = -v_velocity *damp *.1

		if v_velocity> 100:
			tile_bounce_sound.stream  = $"../".tile_bounce_sounds[randi() % 3]
			tile_bounce_sound.pitch_scale  = rand_range(1, 3)
			tile_bounce_sound.play()

	var t             = clamp(z_offset /max_z_offset, 0, 1)
	var scale_factor  = lerp(1, max_scale, t)
	$"%Sprite".scale  = Vector2(scale_factor, scale_factor)






func io_anim(type := 0) -> void:
	if type == 0:
		var node : Camera2D = level.get_node("ZoomCam")
		var val  : float
		var col  = $"%Sprite".modulate
		col.a  = def_col.a

		def_rot  = rotation_degrees
		def_sca  = scale * 0.92

		tween_io  = get_tree().create_tween().set_trans(1).set_ease(2)

		allow_color_anim  = true
		tile_color_anim_accents(.16, .64 , 4.4, true)


		if level.player_fail:
			val               = rand_range(.8, 1.4)
			tile_particle_spawn(2, 6)
			PARTICLES_move  = _particles_move.instance()
			add_child(PARTICLES_move)
			PARTICLES_move.get_node("particles_move").emitting  = true
		else:
			val               = rand_range(.32, .44)
			position          = G.gen_offscreen_pos(60, node.position)
			scale             = Vector2(0.01, 0.01)
			rotation_degrees  = rand_range(-360, 360)

		#PHASE ZERO:
		tween_io.tween_property(self, "position", def_pos, val)

		#PHASE 1:
		tween_io.set_parallel(true)
		tween_io.tween_property(self, "rotation_degrees", def_rot,
			rand_range(.44, .82)).set_delay(.1)

		tween_io.tween_property(self, "scale", def_sca, .3)

		#tile spawn sound
		if OS.get_system_time_msecs() >= level.sound_timeout:
			level.sound_timeout  = OS.get_system_time_msecs() + 12
			tween_io.tween_callback($"../sounds/TileMain", "play").set_delay(val)

		#PHASE 2:
		tween_io.set_parallel(false)
		tween_io.tween_property(self, "scale", def_sca * .4, .22).set_ease(Tween.EASE_IN)

		tween_io.tween_property(self, "scale", def_sca, .16
			).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

		tween_io.tween_callback(self, "tile_ready").set_delay(.04)


	else:
		pass
#		var time         = rand_range(.2, .6)
#		var node         = get_parent().get_node("ZoomCam")
#		def_pos          = G.gen_offscreen_pos(60, node.position)
#		allow_idle_anim  = false
#
#		tween_io  = self.create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
#		tween_io.tween_property(self, "position", def_pos, time)
##		var col  = modulate ; col.a  = 0
#		tween_io.parallel().tween_property(self, "modulate:a", 0, time - (time*.1))
#		tween_io.tween_callback(self, "tile_ready", [false])






# type:
#	0  : position
#	1  : rotation
#   2  : scale

func idle_anim() -> void:
	var pos        := def_pos
	var rot        := def_rot
	var sca        := def_sca
	var time       := rand_range(2, 3)

	if allow_idle_anim:
		tween_idle =  self.create_tween().set_trans(1).set_ease(2).set_parallel()

		var distance   := 2.8 if not reduce_mov else 2.2
		pos.x         += rand_range(-distance, distance)
		pos.y         += rand_range(-distance, distance)
		tween_idle.tween_property(
			self, "position", pos, time)

		rot += rand_range(-40, 40)
		if reduce_rot:
			rot *= .4
		tween_idle.tween_property(
			self, "rotation_degrees", rot, time *2.6)

		tween_idle.tween_property(
			self,"scale",
			sca *rand_range(.92, 1.04), time *.6)

		tween_idle.chain().tween_callback(
			self, "idle_anim")






#### type:
#### true  = intro (restart level)        false  = outro (after explosion)
func tile_ready(type:=true) -> void:
	G.tiles_ready += 1

	if type:
		if G.tiles_ready == level.num_tiles:
			G.tiles_ready  = 0
			level.reveal_starter_tiles()
			level.allow_board_input  = true
			level.player_fail        = false

		allow_idle_anim   = true
		idle_anim()
	else:
		if G.tiles_ready == level.num_tiles:
			G.tiles_ready  = 0
			yield(get_tree().create_timer(2), "timeout")
			level.player_fail  = true
			level.reset_board(true)






func tile_color_anim_accents(dist:float, smoothness:float, time:float, init:=false) -> void:
	var col  : Color = def_col
	var t    := time *.4

	tween_col  = self.create_tween().set_trans(1).set_ease(2).set_parallel()
	col.r   += rand_range(-dist *.6, dist)
	col.g   += rand_range(-dist *.6, dist)
	col.b   += rand_range(-dist *.6, dist)
	col.a   *= G.CONFIG.tile_transparency
	col      = G.rgb_smooth(col, smoothness)
	time     = rand_range(time -t, time +t)

	tween_col.tween_property($"%Sprite", "modulate", col, time)

	tween_col.tween_property(
		$"%Sprite", "material:shader_param/amount", rand_range(2, 3),  time *.5)
	tween_col.tween_property(
		$"%Sprite", "material:shader_param/radius", rand_range(-2, 2), time *.5)

	tween_col.chain().tween_property(
		$"%Sprite", "material:shader_param/amount", 2.5, time *.5)
	tween_col.tween_property(
		$"%Sprite", "material:shader_param/radius", 0.0, time *.5)

	time  *= 2 if not init else 1
	if allow_color_anim:
		tween_col.chain().tween_callback(self, "tile_color_anim_accents", [dist, smoothness, time])






func reveal(counter:int) -> void:
	var delay    : float
	var trans    : int
	var time_mod : float
	var scale_to : Vector2

	tweens_disable()
	tween_rev  = self.create_tween().set_ease(Tween.EASE_OUT).set_parallel()

	if counter == 0:
		scale_to    = Vector2(.04, .04)
		trans       = Tween.TRANS_BOUNCE
		time_mod    = rand_range(-.8, .8)
		delay       = rand_range(.12, .28)

		change_alpha(time_mod, delay, trans, .28)

	else:
		var add    := counter *.02
		scale_to    = Vector2(.06 +add, .06 +add)
		trans       = Tween.TRANS_ELASTIC
		time_mod    = rand_range(-.6, .6)
		delay       = rand_range(.06, .1)
		reduce_mov  = true
		reduce_rot  = true

		change_alpha(time_mod, delay, trans, .4)
		tile_particle_spawn(1, 4)

	tween_rev.tween_property(self, "scale", scale_to, 3.24 +time_mod
		).set_trans(trans)
	tween_rev.chain().tween_callback(self, "post_reveal")

	## blur material applied:
	var mat    := ShaderMaterial.new()
	mat.shader  = shader_revealed
	mat.set_shader_param("radius", 8)
	$"%Sprite".material  = mat






func post_reveal() -> void:
	def_sca          = scale
	allow_idle_anim  = true
	idle_anim()







func change_alpha(time:float, delay:float, trans:int, mod:=1.0) -> void:
	var col := def_col
	col.a   *= mod

	tween_rev.tween_property(
		$"%Sprite", "modulate", col, time).set_trans(trans).set_delay(delay)






func tile_helper_spawn() -> void:
	BUMP  = _bump.instance()
	add_child(BUMP)
	tile_particle_spawn(1, 6)






func tile_particle_spawn(type:int=0, lifetime:float=2) -> void:
	var node1 : CPUParticles2D
	var node2 : CPUParticles2D

	PARTICLES_main  = _particles_main.instance()
	add_child(PARTICLES_main)

	match type:
		0:    ## reveal
			node1              = PARTICLES_main.get_node("particles_small")
			node1.emitting     = true
			node1.modulate.a   = .40
			node1.speed_scale  = 1
#			node1.scale        = Vector2(2,2)

			node2              = PARTICLES_main.get_node("particles_blink")
			node2.emitting     = true
			node2.modulate.a   = .20
			node2.speed_scale  = 1
		1:    ## tile helper
			node1              = PARTICLES_main.get_node("particles_helper")
			node1.lifetime     = lifetime
			node1.modulate     = G.CONFIG.BG_color *rand_range(.2, .8)
			node1.emitting     = true
			node1.modulate.a   = .6
			node1.speed_scale  = .1
			node1.scale_amount = 3.6
			node1.z_index      = -1
		2:    ## respawn blink
			node1              = PARTICLES_main.get_node("particles_helper")
			node1.lifetime     = lifetime
			node1.emitting     = true
			node1.modulate.a   = 1
			node1.speed_scale  = 8
			node1.scale_amount = 5
			node1.z_index      = 2

	var lifetime_offset  = lifetime *node1.speed_scale
	PARTICLES_main.delay(lifetime + lifetime -lifetime_offset)






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






func tile_blast_motion(pos:Vector2) -> void:
	var radius        = 260.0
	var power         = rand_range(400, 600)
	var bounce_power  = rand_range(600, 1000)

	var diff          = global_position -pos
	var distance      = diff.length()

	if distance < radius:
		allow_idle_anim   = false
		allow_color_anim  = false
		tweens_disable()

		var factor        = 1.0 -(distance /radius)
		velocity          = diff.normalized() *power *factor
		v_velocity        = bounce_power *factor
		rotation_degrees  = rand_range(-40, 40)
		set_physics_process(true)

#		allow_move_particles  = true
	tile_ready(false)






func tweens_disable() -> void:
	allow_idle_anim   = false
	allow_color_anim  = false
	if tween_idle: tween_idle.kill()
	if tween_bump: tween_bump.kill()
	if tween_rev:  tween_rev.kill()
	if tween_col:  tween_col.kill()
	if tween_io:   tween_io.kill()






func _on_touch_collision(_a, _b, _c, _d):
	get_parent().check_clicked_tile()

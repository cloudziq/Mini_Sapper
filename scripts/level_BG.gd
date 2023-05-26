extends Node2D

var BG_amount     = 30    ## 64
var default_range = 2000


var ACTIVE
var ROTATE
var SCALE
var COLOR
var CHANGE




func _ready():
	ACTIVE    = false
	ROTATE    = false
	SCALE     = false
	COLOR     = false
	CHANGE    = false

	yield(get_tree().create_timer(.1), "timeout")
	$Sprite.self_modulate = Color(.20, .68, .92, .032)
	assign_tex()
	ACTIVE = true




func _process(_delta):
	var time ; var delay ; var rot ; var R ; var G ; var B ; var A ; var color

	if ACTIVE:
		if not ROTATE:
			ROTATE = true
			time  = rand_range(20, 60)
			delay = rand_range(2, 6)
			rot = rand_range(-360, 360)
			var rott = rot ; if rott <0: rott = -rot

			$anim_rotate.interpolate_property($Sprite, "rotation_degrees",
				$Sprite.rotation_degrees, rot, time + (rott * 1.1),
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_rotate.start()

		elif not COLOR and not CHANGE:
			COLOR = true
			time  = rand_range(18, 42)
			delay = rand_range(2, 6)
			R = rand_range(.12, .32)
			G = rand_range(.42, .96)
			B = rand_range(.36, .82)
			A = rand_range(.04, .062)
			$anim_color.interpolate_property($Sprite, "self_modulate",
				$Sprite.self_modulate, Color(R,G,B,A), time,
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_color.start()

		elif not SCALE:
			SCALE = true
			time  = rand_range(16, 32)
			delay = rand_range(4, 8)
			var scale = rand_range(5, 10)

			$anim_scale.interpolate_property($Sprite, "scale",
				$Sprite.scale, Vector2(scale, scale), time + (scale * 2.64),
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_scale.start()

		elif randi() % default_range + 1 == default_range and CHANGE == false:
			CHANGE = true
			var count = get_parent().bg_change_count + 1
			print("BG change start: "+str(count))
			get_parent().bg_change_count = count
			time  = rand_range(10, 16)
			delay = rand_range(6, 12)
			color = $Sprite.self_modulate ; color.a = 0

			$anim_color.remove($Sprite, "self_modulate")
			$anim_color.interpolate_property($Sprite, "self_modulate",
				$Sprite.self_modulate, color, time,
				Tween.TRANS_SINE, Tween.EASE_IN_OUT, delay)
			$anim_color.start()




func _on_anim_rotate_end():
	ROTATE = false


func _on_anim_scale_end():
	SCALE = false


func _on_anim_color_end():
	COLOR = false
	if CHANGE:
		assign_tex()
		CHANGE = false




func assign_tex():
	var num

	if rand_range(0, 100) < 65:
		num = $"../".last_bg
#		print("old: "+str(num))
	else:
		num  = ceil(rand_range(0, BG_amount))
#		print("new: "+str(num))

	$"../".last_bg = num
	var path = "res://assets/graphics/level_bg/bg" + str(num)

	$Sprite.texture    = load(path +".png")
	$Sprite.normal_map = load(path +"_n.png")

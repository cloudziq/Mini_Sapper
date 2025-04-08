extends Node2D



func _ready() -> void:
	$particles_move.one_shot  = true
	$particles_move.emitting  = false

	$particles_move.global_position  = get_parent().position

	var col: Color = G.CONFIG.BG_color *G.CONFIG.BG_brightness
	col.a  = .44
	$particles_move.modulate  = col

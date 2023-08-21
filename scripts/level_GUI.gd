extends CanvasLayer
# jebać PIS i PO forever

#signal restart






# random note:
# kratki zeby wypierdlało łańcuchowo ^.^  ??






func _on_Restart_Button_pressed():
#	$VBoxContainer/Lower/Button.disabled  = true
#	var _a     = get_tree().reload_current_scene()
	var tween  := get_tree().create_tween().set_trans(Tween.TRANS_SINE)
#	get_parent().allow_board_input  = false

	if get_parent().player_fail:
	#if player chooses to redraw:
		var node = $VBoxContainer
		tween.tween_property(node, "modulate", Color(1,1,1,0), .6)
#		$anim_color.interpolate_property(node, "modulate",
#			Color(1,1,1,1), Color(1,1,1,0), .6,
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_color.start()

		####  SHOW GUI AFTER SOME TIME:
		yield(get_tree().create_timer(2.6), "timeout")
		$VBoxContainer/Lower/Button.modulate.a = 0
		tween.tween_property(node, "modulate", Color(1,1,1,1), 1.8)
#		$anim_color.interpolate_property(node, "modulate",
#			Color(1,1,1,0), Color(1,1,1,1), 1.8,
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_color.start()

		yield(get_tree().create_timer(2), "timeout")
		$VBoxContainer/Lower/Button.disabled = false
		tween.tween_property($VBoxContainer/Lower/Button, "modulate", Color(1,1,1,1), .4)
#		$anim_color.remove_all()
#		$anim_color.interpolate_property($VBoxContainer/Lower/Button, "modulate",
#			Color(1,1,1,0), Color(1,1,1,1), .4,
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_color.start()
	else:
	#if player dies:
		var node = $VBoxContainer/Lower/Button
		tween.tween_property(node, "modulate", Color(1,1,1,0), .4)
		node.disabled = true
#		$anim_color.interpolate_property(node, "modulate",
#			Color(1,1,1,1), Color(1,1,1,0), .4,
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_color.start()

		####  SHOW BUTTON AFTER SOME TIME:
#		yield(get_tree().create_timer(1.6), "timeout")
#		$VBoxContainer/Lower/Button.disabled = false
#		tween.tween_property(node, "modulate", Color(1,1,1,1), .8)

#		$anim_color.remove_all()
#		$anim_color.interpolate_property(node, "modulate",
#			Color(1,1,1,0), Color(1,1,1,1), .8,
#			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		$anim_color.start()

	yield(get_tree().create_tween().tween_interval(.6), "finished")
	get_parent().restart_board()






#func show() -> void:
#	var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE)
#	var node   = $VBoxContainer/Lower/Button
#
#	tween.tween_property(node, "modulate", Color(1,1,1,1), .4)






func update(show := 0) -> void:
	var node = $VBoxContainer/Upper/Left/HBox/Level/num
	node.text = str(G.SETTINGS.level)

	node = $VBoxContainer/Upper/Left/HBox/Bombs/num
	node.text = str($"../".bombs_amount)

	node = $VBoxContainer/Upper/Left/HBox/Markers/num
	node.text = str($"../".marker_amount)

	node = $VBoxContainer/Upper/Left/HBox/Tiles/num
	node.text = str($"../".tiles_left)


	if show != 0:
		var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE)

		node   = $VBoxContainer/Lower/Button
		tween.tween_property(node, "modulate", Color(1,1,1,1), .4).set_delay(1)
		tween.tween_property(node, "disabled", false, 0)

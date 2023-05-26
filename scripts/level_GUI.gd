extends CanvasLayer

signal restart




func _on_Restart_Button_pressed():
	$VBoxContainer/Lower/Button.disabled = true
	emit_signal("restart")

	if get_parent().player_fail:
		var node = $VBoxContainer
		$anim_color.interpolate_property(node, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), .6,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_color.start()

		####  SHOW GUI AFTER SOME TIME:
		yield(get_tree().create_timer(2.6), "timeout")
		$VBoxContainer/Lower/Button.modulate.a = 0
		$anim_color.interpolate_property(node, "modulate",
			Color(1,1,1,0), Color(1,1,1,1), 1.8,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_color.start()

		yield(get_tree().create_timer(2), "timeout")
		$VBoxContainer/Lower/Button.disabled = false
		$anim_color.remove_all()
		$anim_color.interpolate_property($VBoxContainer/Lower/Button, "modulate",
			Color(1,1,1,0), Color(1,1,1,1), .4,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_color.start()
	else:
		var node = $VBoxContainer/Lower/Button
		$anim_color.interpolate_property(node, "modulate",
			Color(1,1,1,1), Color(1,1,1,0), .4,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_color.start()

		####  SHOW BUTTON AFTER SOME TIME:
		yield(get_tree().create_timer(1.6), "timeout")
		$VBoxContainer/Lower/Button.disabled = false
		$anim_color.remove_all()
		$anim_color.interpolate_property(node, "modulate",
			Color(1,1,1,0), Color(1,1,1,1), .8,
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$anim_color.start()




func _on_update_GUI():
	var node = $VBoxContainer/Upper/Left/HBox/Level/num
	node.text = str($"../".current_level+1)

	node = $VBoxContainer/Upper/Left/HBox/Bombs/num
	node.text = str($"../".bombs_amount)

	node = $VBoxContainer/Upper/Left/HBox/Markers/num
	node.text = str($"../".markers)

	node = $VBoxContainer/Upper/Left/HBox/Tiles/num
	node.text = str($"../".tiles_left)

extends CanvasLayer
# jebać PIS i PO forever






# random note:
# kratki zeby wypierdlało łańcuchowo ^.^  ??






func _on_Restart_Button_pressed():
	var node   := $VBoxContainer
	var button := $VBoxContainer/Lower/Button
	var tween  := get_tree().create_tween().set_trans(Tween.TRANS_SINE)

	button.disabled                 = true
	get_parent().allow_board_input  = false

	if get_parent().player_fail:
		tween.tween_property(node, "modulate", Color(1,1,1,0), .6)
	else:
		tween.tween_property(node, "modulate", Color(1,1,1,0), .4)

#	yield(get_tree().create_tween().tween_interval(.1), "finished")
	get_parent().reset_board()






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
		tween.tween_property($VBoxContainer, "modulate", Color(1,1,1,1), .4).set_delay(1)
		tween.tween_property(node, "disabled", false, 0)

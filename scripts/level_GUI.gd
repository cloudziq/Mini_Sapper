extends CanvasLayer
# jebać PIS i PO forever






func _ready() -> void:
	$VBoxContainer.modulate               = Color(1,1,1,0)
	$VBoxContainer/Lower/Button.disabled  = true






func _on_Restart_Button_pressed() -> void:
	var node   := $VBoxContainer
	var button := $VBoxContainer/Lower/Button
	var tween  := get_tree().create_tween().set_trans(Tween.TRANS_SINE)

	button.disabled  = true

	if get_parent().player_fail:
		tween.tween_property(node, "modulate", Color(1,1,1,0), .8)
	else:
		tween.tween_property(node, "modulate", Color(1,1,1,0), .2)

	get_parent().reset_board()






func update(show := false) -> void:
	var node = $VBoxContainer/Upper/Left/HBox/Level/num
	node.text = str(G.CONFIG.level)

	node = $VBoxContainer/Upper/Left/HBox/Bombs/num
	node.text = str($"../".bombs_amount)

	node = $VBoxContainer/Upper/Left/HBox/Markers/num
	node.text = str($"../".marker_amount)

	node = $VBoxContainer/Upper/Left/HBox/Tiles/num
	node.text = str($"../".tiles_left)

	# restart button:
	if show:
		var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE)

		node   = $VBoxContainer/Lower/Button
		tween.tween_property($VBoxContainer, "modulate", Color(1,1,1,1), .4).set_delay(1.6)
		tween.tween_property(node, "disabled", false, 0)

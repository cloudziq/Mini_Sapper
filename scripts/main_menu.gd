extends CanvasLayer




#func _on_Start_Button_pressed() -> void:
func _ready() -> void:
	hide()
	get_parent().start_game()

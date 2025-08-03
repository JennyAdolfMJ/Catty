extends Control

func _on_btn_new_game_pressed() -> void:
	var dialog = Dialogic.start("res://chapter1.dtl");
	dialog.layer = 0
	get_parent().add_game_node(dialog)
	pass # Replace with function body.

extends CanvasLayer
@export var Game: NodePath

func add_game_node(node):
	get_node("../Game").add_child(node)
	$MainMenu.hide()
	$InGameMenu.show()

func show_storyline():
	$StorylineMenu.show()

extends Node

func _ready() -> void:
	print("Hello World")
	pass

func start_dialogue():
	Dialogic.start("res://dialogue/main_story.dtl")

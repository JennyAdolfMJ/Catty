extends Node2D

func _ready():
	start_dialogue()  # 场景加载后立即触发对话

func start_dialogue():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start("res://chapter1.dtl")
	
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	print("Called")
	Dialogic.end_timeline()
	Dialogic.start("res://chapter1.dtl")
	# do something else here

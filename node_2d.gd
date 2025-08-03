extends Node2D

func _ready():
	$Button.connect("pressed", _on_open_graph_pressed)
	start_dialogue()  # 场景加载后立即触发对话

func _on_open_graph_pressed():
	var dialog_graph_scene = load("res://scenes/dialog_graph.tscn").instantiate()
	get_tree().root.add_child(dialog_graph_scene)  # 添加到场景树
	get_tree().current_scene.queue_free()          # 移除当前场景（可选）
	get_tree().current_scene = dialog_graph_scene  # 更新当前场景引用

func start_dialogue():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.start("res://chapter1.dtl")
	
func _on_timeline_ended():
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	print("Called")
	Dialogic.end_timeline()
	Dialogic.start("res://chapter1.dtl")
	# do something else here

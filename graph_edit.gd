extends GraphEdit
func _ready():
	var connections = get_label_connections("res://dialogue/main_story.tres")
	draw_label_graph(connections)

# 绘制节点和连线
func draw_label_graph(connections: Dictionary):
	var node_pos = Vector2(0, 0)
	var node_gap = Vector2(200, 100)
	
	# 创建所有节点
	for label in connections.keys():
		var node = GraphNode.new()
		node.title = label
		node.position = node_pos
		node_pos += node_gap
		add_child(node)
	
	# 创建连线
	for from_label in connections:
		var from_node = get_node(from_label)
		if not from_node:
			continue
			
		for to_label in connections[from_label]:
			var to_node = get_node(to_label)
			if to_node:
				connect_node(from_node.name, 0, to_node.name, 0)

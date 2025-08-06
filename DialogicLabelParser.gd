# DialogicLabelParser.gd
extends Node

class_name DialogicLabelParser

# 节点数据结构
class TimelineNode:
	var id: String
	var label_name: String = ""
	var position: Vector2
	var jumps: Array = [] # [{label: String, condition: String}]
	var is_start: bool = false
	var is_end: bool = false

var nodes: Dictionary = {}
var start_node: String = ""

func parse_timeline(timeline_path: String) -> void:
	var timeline: DialogicTimeline = Dialogic.preload_timeline(timeline_path)
	if not timeline:
		push_error("Failed to load timeline: " + timeline_path)
		return
	
	var events = timeline.events
	var current_label: String = ""
	var has_label: bool = false
	
	# 第一遍：收集所有Label
	for i in range(events.size()):
		var event = events[i]
		if event is DialogicLabelEvent:
			var label_name = event['name']
			var node_id = "label_" + label_name
			nodes[node_id] = TimelineNode.new()
			nodes[node_id].id = node_id
			nodes[node_id].label_name = label_name
			current_label = node_id
			has_label = true
			
		if i == 0 && nodes.size() == 0:
			var node_id = "label_start"
			nodes[node_id] = TimelineNode.new()
			nodes[node_id].id = node_id
			nodes[node_id].label_name = "start"
			nodes[node_id].is_start = true
			start_node = node_id
			print(node_id)
			print(start_node)
	
	# 第二遍：处理Jump关系
	current_label = start_node
	for event in events:
		if event is DialogicLabelEvent:
			current_label = "label_" + event['name']
		elif event is DialogicJumpEvent:
			var target_label = event.label_name
			var condition = "null"
			
			nodes[current_label].jumps.append({
				"label": target_label,
				"condition": condition
			})
		elif event is DialogicEndTimelineEvent:
			nodes[current_label].is_end = true
	
	# 自动布局
	_arrange_nodes()

func _arrange_nodes() -> void:
	var x = 100
	var y = 100
	var col_height = 0
	
	# 先排列所有Label节点
	for node_id in nodes:
		var node = nodes[node_id]
		if node.label_name != "":
			node.position = Vector2(x, y)
			y += 150
			col_height = max(col_height, y)
			
			if y > 800: # 换列
				x += 300
				y = 100
	
	# 排列没有Label的节点
	for node_id in nodes:
		var node = nodes[node_id]
		if node.label_name == "":
			node.position = Vector2(x, y)
			y += 150
			col_height = max(col_height, y)
			
			if y > 800: # 换列
				x += 300
				y = 100
	
	# 调整Jump目标节点位置
	for node_id in nodes:
		var node = nodes[node_id]
		if node.jumps.size() > 0:
			var offsetY = 0;
			for jump in node.jumps:
				var target_id = "label_" + jump['label']
				if nodes.has(target_id):
					var target_node = nodes[target_id]
					# 确保目标节点在右侧
					if target_node.position.x <= node.position.x:
						target_node.position.x = node.position.x + 300
						target_node.position.y = node.position.y + offsetY
						offsetY += 300

func get_connections() -> Array:
	var connections = []
	for node_id in nodes:
		var node = nodes[node_id]
		for jump in node.jumps:
			var target_id = "label_" + jump['label']
			if nodes.has(target_id):
				connections.append({
					"from": node_id,
					"to": target_id,
					"condition": ""
				})
			elif node.is_end:
				connections.append({
					"from": node_id,
					"to": "end",
					"condition": ""
				})
	return connections

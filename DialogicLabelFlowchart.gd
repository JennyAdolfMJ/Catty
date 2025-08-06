# DialogicLabelFlowchart.gd
extends Control

class_name DialogicLabelFlowchart

@export var timeline_path: String = "":
	set(value):
		timeline_path = value
		if is_inside_tree():
			_parse_and_draw()

var parser: DialogicLabelParser
var selected_node: String = ""
var connections: Array = []

func _ready() -> void:
	parser = DialogicLabelParser.new()
	_parse_and_draw()

func _parse_and_draw() -> void:
	if timeline_path.is_empty():
		return
	
	parser.parse_timeline(timeline_path)
	connections = parser.get_connections()
	queue_redraw()
	
func draw_label(pos: Vector2, text: String):
	var to_pos = pos
	
	# 圆角矩形样式
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.7)
	# style_box.border_color = Color.RED
	style_box.set_border_width_all(2)
	style_box.set_corner_radius_all(10)
	style_box.set_content_margin_all(10)
	
	# 矩形大小和位置
	var rect_size = Vector2(100, 60)
	var rect_position = to_pos - rect_size / 2
	var rect = Rect2(rect_position, rect_size)
	
	# 绘制圆角矩形
	draw_style_box(style_box, rect)
	
	# 标签设置
	var label_text = "END"
	var font = get_theme_default_font()
	var text_size = font.get_string_size(label_text)
	
	# 标签背景
	var label_bg_rect = Rect2(
		rect_position + Vector2(5, rect_size.y - 25),
		Vector2(text_size.x + 10, 20))
	
	var label_style = StyleBoxFlat.new()
	label_style.bg_color = Color(0, 0, 0, 0.7)
	label_style.corner_radius_bottom_left = 5
	draw_style_box(label_style, label_bg_rect)
	
	# 标签文字
	draw_string(
		font,
		rect_position + Vector2(10, rect_size.y - 10),
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		16,
		Color.WHITE
	)

func _draw() -> void:
	if not parser:
		return
	
	# 绘制连接线
	for conn in connections:
		var from_node = parser.nodes.get(conn['from'])
		var to_node = parser.nodes.get(conn['to']) if conn['to'] != "end" else null
		
		if from_node:
			var from_pos = from_node.position
			var to_pos = Vector2.ZERO
			var draw_arrow = true
			
			if to_node:
				to_pos = to_node.position
			else: # 结束节点
				to_pos = from_pos + Vector2(200, 0)
				draw_arrow = false
				draw_circle(to_pos, 20, Color.RED)
				draw_string(
					get_theme_default_font(),
					to_pos + Vector2(25, 10),
					"END",
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					16,
					Color.WHITE
				)
			
			# 绘制线
			draw_line(from_pos, to_pos, Color.WHITE, 2)
			
			# 绘制条件文本
			if conn['condition'] != "":
				var mid_point = (from_pos + to_pos) / 2
				draw_string(
					get_theme_default_font(),
					mid_point - Vector2(50, 0),
					conn['condition'],
					HORIZONTAL_ALIGNMENT_CENTER,
					-1,
					14,
					Color.YELLOW
				)
			
			# 绘制箭头
			if draw_arrow and to_node:
				var dir = (to_pos - from_pos).normalized()
				var arrow_size = 10
				var arrow1 = to_pos - dir * arrow_size + dir.rotated(PI/4) * arrow_size
				var arrow2 = to_pos - dir * arrow_size + dir.rotated(-PI/4) * arrow_size
				draw_line(to_pos, arrow1, Color.WHITE, 2)
				draw_line(to_pos, arrow2, Color.WHITE, 2)
	
	# 绘制节点
	for node_id in parser.nodes:
		var node = parser.nodes[node_id]
		var pos = node.position
		var radius = 40
		
		# 设置节点颜色
		var color: Color
		if node.is_start:
			color = Color.GREEN
		elif node.is_end:
			color = Color.RED
		elif node.label_name != "":
			color = Color.SKY_BLUE
		else:
			color = Color.GRAY
		
		# 高亮选中节点
		if node_id == selected_node:
			color = color.lightened(0.3)
			draw_circle(pos, radius + 5, Color.WHITE)
		
		# 绘制节点文本
		var text = node.label_name if node.label_name else "Start" if node.is_start else "Node"
		
		draw_label(pos, text)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# 检查是否点击了节点
			for node_id in parser.nodes:
				var node = parser.nodes[node_id]
				if event.position.distance_to(node.position) < 40:
					selected_node = node_id
					queue_redraw()
					_show_node_details(node)
					break

func _show_node_details(node: DialogicLabelParser.TimelineNode) -> void:
	var details = "节点ID: %s\n" % node.id
	if node.label_name != "":
		details += "Label名称: %s\n" % node.label_name
	
	if node.is_start:
		details += "类型: 开始节点\n"
	elif node.is_end:
		details += "类型: 结束节点\n"
	else:
		details += "类型: %s\n" % ("Label节点" if node.label_name != "" else "普通节点")
	
	if node.jumps.size() > 0:
		details += "\n跳转关系:"
		for jump in node.jumps:
			details += "\n→ %s" % jump['label']
			if jump['condition'] != "":
				details += " (条件: %s)" % jump['condition']
	
	print(details) # 或者显示在UI上

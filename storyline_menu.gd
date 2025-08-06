# LabelFlowchartViewer.gd
extends Control

@onready var flowchart: DialogicLabelFlowchart = $DialogicLabelFlowchart
#@onready var info_label: Label = $ControlPanel/InfoLabel
#@onready var file_dialog: FileDialog = $TimelineFileDialog

func _ready() -> void:
	flowchart.timeline_path = "res://Dialogic//chapter1.dtl" # 默认时间线

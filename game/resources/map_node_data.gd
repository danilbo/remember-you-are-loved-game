extends Resource
class_name MapNodeData

@export var title: String
@export var description: String
@export var icon: Texture2D

func get_tooltip_data() -> TooltipData:
	var data : TooltipData = TooltipData.new()
	data.title = title
	data.description = description
	data.icon = icon
	return data
